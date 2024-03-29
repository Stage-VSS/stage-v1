classdef TcpServer < handle
    
    properties (SetAccess = private)
        port
    end
    
    properties (Access = private)
        stopRequested
    end
    
    events
        clientConnected
        clientDisconnected
        eventReceived
        timedOut
    end
    
    methods
        
        function obj = TcpServer(port)            
            if nargin < 1
                port = 5678;
            end
            
            obj.port = port;
        end
        
        % Starts listening for connections and serving clients. This method will block the serving Matlab session.
        function start(obj)
            obj.stopRequested = false;
            socket = [];
            
            while ~obj.stopRequested
                if isempty(socket) || socket.isClosed
                    socket = java.net.ServerSocket(obj.port);
                    socket.setSoTimeout(10);
                    closeSocket = onCleanup(@()socket.close());
                end
                
                try
                    client = TcpClient(socket.accept());
                catch x
                    if isa(x.ExceptionObject, 'java.net.SocketTimeoutException')
                        notify(obj, 'timedOut');
                        continue;
                    else
                        rethrow(x);
                    end
                end
                
                delete(closeSocket);
                
                notify(obj, 'clientConnected', NetEventData(client));
                obj.serve(client);
                
                client.close();
            end
        end
        
        function requestStop(obj)
            obj.stopRequested = true;
        end
        
        function serve(obj, client)
            client.setReceiveTimeout(10);
            
            while ~obj.stopRequested
                try
                    value = client.receive();
                catch x
                    if strcmp(x.identifier, 'TcpClient:ReceiveTimeout')
                        notify(obj, 'timedOut');
                        continue;
                    else
                        rethrow(x);
                    end
                end
                
                if ~iscell(value)                    
                    value = {value};
                end
                
                if length(value) == 1 && isscalar(value{1}) && value{1} == -1
                    notify(obj, 'clientDisconnected', NetEventData(client));
                    break;
                end
                
                notify(obj, 'eventReceived', NetEventData(client, value));
            end
        end
        
    end
    
end