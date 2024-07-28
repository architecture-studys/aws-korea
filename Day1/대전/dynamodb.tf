resource "aws_dynamodb_global_table" "global" {
  provider = aws.seoul
  name     = "order"

  replica {
    region_name = "ap-northeast-2"
  }

  replica {
    region_name = "us-east-1"
  }

  depends_on = [
    aws_dynamodb_table.ap_northeast_2,
    aws_dynamodb_table.us_east_1,
  ]
}

resource "aws_dynamodb_table" "ap_northeast_2" {
    provider = aws.seoul

    name             = "order"
    billing_mode     = "PAY_PER_REQUEST"
    hash_key         = "id"
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
        name = "id"
        type = "S"
    }

    tags = {
        Name = "order"
    }
}
resource "aws_dynamodb_table" "us_east_1" {
    provider = aws.usa

    name             = "order"
    billing_mode     = "PAY_PER_REQUEST"
    hash_key         = "id"
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
        name = "id"
        type = "S"
    }

    tags = {
        Name = "order"
    }
}