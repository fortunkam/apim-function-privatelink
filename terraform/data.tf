data "http" "httpbin" {
    url = "http://httpbin.org/ip"
    
    request_headers = {
        Accept = "application/json"
    }
}

data "azurerm_client_config" "current" {
}