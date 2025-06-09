package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
)

type ErrorResponse struct {
	Error struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

type StatementResponse struct {
	Status struct {
		Phase  string `json:"phase"`
		Detail string `json:"detail"`
	} `json:"status"`
}

func main() {
	organisationId := os.Getenv("confluent_cloud_organisation_id")
	environmentId := os.Getenv("confluent_cloud_environment_id")
	computePoolId := os.Getenv("flink_compute_pool_id")
	environmentName := os.Getenv("confluent_cloud_environment_name")
	clusterName := os.Getenv("confluent_cloud_cluster_name")
	provider := os.Getenv("confluent_cloud_environment_provider")
	region := os.Getenv("confluent_cloud_environment_region")
	flinkKey := os.Getenv("flink_api_key")
	flinkSecret := os.Getenv("flink_api_secret")
	flinkServiceAccount := os.Getenv("flink_statement_principal")
	flinkStatements := os.Getenv("flink_statements")

	flinkStatementsSplit := strings.Split(flinkStatements, "~~")

	for statement := range flinkStatementsSplit {
		statementName := uuid.New().String()

		err := executeFlinkStatements(organisationId, environmentId, region, provider, flinkKey, flinkSecret, environmentName, clusterName, computePoolId, flinkServiceAccount, statementName, flinkStatementsSplit[statement])
		if err != nil {
			log.Fatalf("Error executing Flink statement: %s \n\nFlink Statement: %s", err, flinkStatementsSplit[statement])
		}

		err = waitForStatementCompletion(organisationId, environmentId, region, provider, statementName, flinkKey, flinkSecret)
		if err != nil {
			log.Fatalf("Error executing Flink statement: %s \n\n%v", flinkStatementsSplit[statement], err)
		}

	}

	fmt.Printf("Executed %d Flink statements succesfully", len(flinkStatementsSplit))
}

func executeFlinkStatements(organisationId, environmentId, region, provider, flinkKey, flinkSecret, environmentName,
	clusterName, computePoolId, flinkServiceAccount, statementName, statement string) error {

	url := fmt.Sprintf("https://flink.%s.%s.confluent.cloud/sql/v1/organizations/%s/environments/%s/statements", region, provider, organisationId, environmentId)
	payloadData := map[string]interface{}{
		"name":            statementName,
		"organization_id": organisationId,
		"environment_id":  environmentId,
		"spec": map[string]interface{}{
			"statement": statement,
			"properties": map[string]interface{}{
				"sql.current-catalog":  environmentName,
				"sql.current-database": clusterName,
			},
			"compute_pool_id": computePoolId,
			"principal":       flinkServiceAccount,
			"stopped":         false,
		},
	}

	payloadJSON, err := json.Marshal(payloadData)
	if err != nil {
		fmt.Println("Error marshaling payload:", err)
		return err
	}

	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(payloadJSON))

	req.Header.Add("content-type", "application/json")
	req.SetBasicAuth(flinkKey, flinkSecret)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("error reading response body - %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		var errResp ErrorResponse
		fmt.Println(string(body))

		err := json.Unmarshal(body, &errResp)
		if err != nil {
			return fmt.Errorf("error parsing error response - %v", err)
		}

		return fmt.Errorf("%d - %s", errResp.Error.Code, errResp.Error.Message)
	}

	return nil
}

func waitForStatementCompletion(organisationId, environmentId, region, provider, statementName, flinkKey, flinkSecret string) error {
	for {
		statementStatus, err := getFlinkStatementStatus(organisationId, environmentId, region, provider, statementName, flinkKey, flinkSecret)
		if err != nil {
			return fmt.Errorf("error checking statement status: %s", err)
		}

		switch statementStatus.Status.Phase {
		case "RUNNING":
			time.Sleep(5 * time.Second)
			return nil
		case "COMPLETED":
			time.Sleep(5 * time.Second)
			return nil
		case "PENDING":
			fmt.Printf("Statement: %s | Status: Pending\n", statementName)
			time.Sleep(5 * time.Second)
		case "FAILING":
			return errors.New(statementStatus.Status.Detail)
		case "FAILED":
			return determineFlinkStatementFailure(statementStatus.Status.Detail)
		default:
			return fmt.Errorf("unknown statement status: %s", statementStatus)
		}
	}
}

func getFlinkStatementStatus(organisationId, environmentId, region, provider, statementName, flinkKey, flinkSecret string) (StatementResponse, error) {
	url := fmt.Sprintf("https://flink.%s.%s.confluent.cloud/sql/v1/organizations/%s/environments/%s/statements/%s", region, provider, organisationId, environmentId, statementName)

	req, _ := http.NewRequest("GET", url, nil)

	req.SetBasicAuth(flinkKey, flinkSecret)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return StatementResponse{}, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return StatementResponse{}, fmt.Errorf("error reading response body: %v", err)
	}

	var response StatementResponse
	err = json.Unmarshal(body, &response)
	if err != nil {
		return StatementResponse{}, fmt.Errorf("error parsing response body: %v", err)
	}

	return response, nil
}

/*
	Strictly for determining if the error is caused by the topic already exists. If it does, it will skip the statement instead
	of having the user tear down their environment and start over.
*/
func determineFlinkStatementFailure(flinkError string) error {
	if strings.Contains(flinkError, "already exists") {
		fmt.Printf("%s | Skipping statement and continuing.\n\n", flinkError)
		return nil
	}

	return errors.New(flinkError)
}
