window.onerror = function(err) {
    log('window.onerror: ' + err)
}

function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

setupWebViewJavascriptBridge(function(bridge) {
                             var uniqueId = 1
                             function log(message, data) {
                             var log = document.getElementById('log')
                             var el = document.createElement('div')
                             el.className = 'logLine'
                             el.innerHTML = uniqueId++ + '. ' + message + ':<br/>' + JSON.stringify(data)
                             if (log.children.length) { log.insertBefore(el, log.children[0]) }
                             else { log.appendChild(el) }
                             }
                             
                             bridge.registerHandler('testJavascriptHandler', function(data, responseCallback) {
                                                    log('ObjC called testJavascriptHandler with', data)
                                                    var responseData = { 'Javascript Says':'Right back atcha!' }
                                                    log('JS responding with', responseData)
                                                    responseCallback(responseData)
                                                    })
                             
                             document.body.appendChild(document.createElement('br'))
                             
                             var callbackButton = document.getElementById('buttons').appendChild(document.createElement('button'))
                             callbackButton.innerHTML = 'Fire testObjcCallback'
                             callbackButton.onclick = function(e) {
                             e.preventDefault()
                             log('JS calling handler "testObjcCallback"')
                             bridge.callHandler('testObjcCallback', {'foo': 'bar'}, function(response) {
                                                log('JS got response', response)
                                                })
                             }
                             })
