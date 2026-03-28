# Pansou API Proxy
# 在 Windows 主机上代理 Docker 容器的 API

$containerIP = "172.17.0.2"
$containerPort = 8888
$localPort = 9999

Write-Host "Starting Pansou API Proxy..."
Write-Host "Docker Container: $containerIP:$containerPort"
Write-Host "Local Access: http://localhost:$localPort"
Write-Host ""

# 创建 HTTP 监听器
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$localPort/")
$listener.Start()

Write-Host "Proxy listening on http://localhost:$localPort"
Write-Host "Press Ctrl+C to stop"
Write-Host ""

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # 构建目标 URL
        $targetUrl = "http://$containerIP`:$containerPort$($request.Url.PathAndQuery)"
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($request.HttpMethod) $($request.Url.PathAndQuery)"
        
        try {
            # 转发请求到容器
            $webRequest = [System.Net.HttpWebRequest]::Create($targetUrl)
            $webRequest.Method = $request.HttpMethod
            $webRequest.Timeout = 30000
            
            # 复制请求头
            foreach ($header in $request.Headers.Keys) {
                if ($header -notin @("Host", "Connection")) {
                    $webRequest.Headers.Add($header, $request.Headers[$header])
                }
            }
            
            # 如果有请求体，复制它
            if ($request.ContentLength64 -gt 0) {
                $webRequest.ContentLength64 = $request.ContentLength64
                $requestStream = $webRequest.GetRequestStream()
                $request.InputStream.CopyTo($requestStream)
                $requestStream.Close()
            }
            
            # 获取响应
            $webResponse = $webRequest.GetResponse()
            $response.StatusCode = [int]$webResponse.StatusCode
            
            # 复制响应头
            foreach ($header in $webResponse.Headers.Keys) {
                $response.Headers.Add($header, $webResponse.Headers[$header])
            }
            
            # 复制响应体
            $responseStream = $webResponse.GetResponseStream()
            $responseStream.CopyTo($response.OutputStream)
            $responseStream.Close()
            
            Write-Host "  -> $([int]$webResponse.StatusCode)"
        } catch {
            $response.StatusCode = 502
            $response.ContentType = "text/plain"
            $errorMsg = "Bad Gateway: $_"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMsg)
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            Write-Host "  -> ERROR: $_"
        }
        
        $response.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
