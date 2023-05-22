module "template_files_common" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/../../common"
  template_vars = {
    # Pass in any values that you wish to use in your templates.
    #vpc_id = "vpc-abc123"
  }
}

resource "aws_s3_object" "common_files" {
  for_each = module.template_files_common.files

  bucket = aws_s3_bucket.games.bucket
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}

locals {
  # Env vars file from template
  env_vars_js = templatefile("${path.module}/../../common/templates/env-vars.js", {
        cloud_provider = "AWS"
        ksqldb_endpoint = "/${aws_api_gateway_stage.event_handler_v1.stage_name}${aws_api_gateway_resource.event_handler_resource.path}"
        games_list =jsonencode(var.games_list)
    })

  # Nested loop over both lists, and flatten the result.
  game_files_to_upload = distinct(flatten([
    for game_module_key, game_module in module.template_files_game : [
      //game = game_module.key
    
      for game_files_key, game_files in game_module.files : {
        //game = game_module_key
        //game_files    = game_files
        game_module = game_module_key
        file_key="${game_module_key}/${game_files_key}"
        file_type = game_files.content_type
        file_source  = game_files.source_path
        file_content = game_files.content
        file_etag   = game_files.digests.md5
      }
    ]
  ]))

 /* game_files_to_upload = distinct(flatten([
    for game_module_key in keys(module.template_files_game) : [
    
      for game_files_keys in keys(module.template_files_game[game_module_key].files) : {
        game = game_module_key
        file_key    = module.template_files_game[game_module_key].files[game_files_keys]
      }
    ]
  ]))*/
} 

/* UPLOAD ONLY SELECTED GAMES*/

module "template_files_game" {
  for_each = var.games_list
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/../../games/${each.value}"
  template_vars = {
    # Pass in any values that you wish to use in your templates.
    #vpc_id = "vpc-abc123"
  }
}


resource "aws_s3_object" "game_files" {
  depends_on = [local.game_files_to_upload]
  for_each = { for entry in local.game_files_to_upload : "${entry.file_key}" => entry }

  bucket = aws_s3_bucket.games.bucket
  key          = each.key
  content_type = each.value.file_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.file_source
  content = each.value.file_content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.file_etag
}

/*output "game_list" {
    value = local.game_files_to_upload
    sensitive = false
}*/

resource "aws_s3_object" "env_vars_js" {
  depends_on = [aws_s3_object.common_files]
  bucket = aws_s3_bucket.games.bucket
  key = "js/env-vars.js"
  content_type = "text/javascript"
  content = local.env_vars_js
  etag  = md5(local.env_vars_js)
}

