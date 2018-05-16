classdef InstrumentInfo < robotics.ros.Message
    %InstrumentInfo MATLAB implementation of irob_msgs/InstrumentInfo
    %   This class was automatically generated by
    %   robotics.ros.msg.internal.gen.MessageClassGenerator.
    
    %   Copyright 2014-2018 The MathWorks, Inc.
    
    %#ok<*INUSD>
    
    properties (Constant)
        MessageType = 'irob_msgs/InstrumentInfo' % The ROS message type
    end
    
    properties (Constant, Hidden)
        MD5Checksum = 'e8902f4d4984e565375de70196323917' % The MD5 Checksum of the message definition
    end
    
    properties (Access = protected)
        JavaMessage % The Java message object
    end
    
    properties (Constant)
        GRIPPER = int8(1)
        SCISSORS = int8(2)
    end
    
    properties (Constant, Access = protected)
        IrobMsgsInstrumentJawPartClass = robotics.ros.msg.internal.MessageFactory.getClassForType('irob_msgs/InstrumentJawPart') % Dispatch to MATLAB class for message type irob_msgs/InstrumentJawPart
    end
    
    properties (Dependent)
        Name
        BasicType
        JawLength
        JawParts
    end
    
    properties (Access = protected)
        Cache = struct('JawParts', []) % The cache for fast data access
    end
    
    properties (Constant, Hidden)
        PropertyList = {'BasicType', 'JawLength', 'JawParts', 'Name'} % List of non-constant message properties
        ROSPropertyList = {'basic_type', 'jaw_length', 'jaw_parts', 'name'} % List of non-constant ROS message properties
    end
    
    methods
        function obj = InstrumentInfo(msg)
            %InstrumentInfo Construct the message object InstrumentInfo
            import com.mathworks.toolbox.robotics.ros.message.MessageInfo;
            
            % Support default constructor
            if nargin == 0
                obj.JavaMessage = obj.createNewJavaMessage;
                return;
            end
            
            % Construct appropriate empty array
            if isempty(msg)
                obj = obj.empty(0,1);
                return;
            end
            
            % Make scalar construction fast
            if isscalar(msg)
                % Check for correct input class
                if ~MessageInfo.compareTypes(msg(1), obj.MessageType)
                    error(message('robotics:ros:message:NoTypeMatch', obj.MessageType, ...
                        char(MessageInfo.getType(msg(1))) ));
                end
                obj.JavaMessage = msg(1);
                return;
            end
            
            % Check that this is a vector of scalar messages. Since this
            % is an object array, use arrayfun to verify.
            if ~all(arrayfun(@isscalar, msg))
                error(message('robotics:ros:message:MessageArraySizeError'));
            end
            
            % Check that all messages in the array have the correct type
            if ~all(arrayfun(@(x) MessageInfo.compareTypes(x, obj.MessageType), msg))
                error(message('robotics:ros:message:NoTypeMatchArray', obj.MessageType));
            end
            
            % Construct array of objects if necessary
            objType = class(obj);
            for i = 1:length(msg)
                obj(i,1) = feval(objType, msg(i)); %#ok<AGROW>
            end
        end
        
        function name = get.Name(obj)
            %get.Name Get the value for property Name
            name = char(obj.JavaMessage.getName);
        end
        
        function set.Name(obj, name)
            %set.Name Set the value for property Name
            validateattributes(name, {'char'}, {}, 'InstrumentInfo', 'Name');
            
            obj.JavaMessage.setName(name);
        end
        
        function basictype = get.BasicType(obj)
            %get.BasicType Get the value for property BasicType
            basictype = int8(obj.JavaMessage.getBasicType);
        end
        
        function set.BasicType(obj, basictype)
            %set.BasicType Set the value for property BasicType
            validateattributes(basictype, {'numeric'}, {'nonempty', 'scalar'}, 'InstrumentInfo', 'BasicType');
            
            obj.JavaMessage.setBasicType(basictype);
        end
        
        function jawlength = get.JawLength(obj)
            %get.JawLength Get the value for property JawLength
            jawlength = double(obj.JavaMessage.getJawLength);
        end
        
        function set.JawLength(obj, jawlength)
            %set.JawLength Set the value for property JawLength
            validateattributes(jawlength, {'numeric'}, {'nonempty', 'scalar'}, 'InstrumentInfo', 'JawLength');
            
            obj.JavaMessage.setJawLength(jawlength);
        end
        
        function jawparts = get.JawParts(obj)
            %get.JawParts Get the value for property JawParts
            if isempty(obj.Cache.JawParts)
                javaArray = obj.JavaMessage.getJawParts;
                array = obj.readJavaArray(javaArray, obj.IrobMsgsInstrumentJawPartClass);
                obj.Cache.JawParts = feval(obj.IrobMsgsInstrumentJawPartClass, array);
            end
            jawparts = obj.Cache.JawParts;
        end
        
        function set.JawParts(obj, jawparts)
            %set.JawParts Set the value for property JawParts
            if ~isvector(jawparts) && isempty(jawparts)
                % Allow empty [] input
                jawparts = feval([obj.IrobMsgsInstrumentJawPartClass '.empty'], 0, 1);
            end
            
            validateattributes(jawparts, {obj.IrobMsgsInstrumentJawPartClass}, {'vector'}, 'InstrumentInfo', 'JawParts');
            
            javaArray = obj.JavaMessage.getJawParts;
            array = obj.writeJavaArray(jawparts, javaArray, obj.IrobMsgsInstrumentJawPartClass);
            obj.JavaMessage.setJawParts(array);
            
            % Update cache if necessary
            if ~isempty(obj.Cache.JawParts)
                obj.Cache.JawParts = [];
                obj.Cache.JawParts = obj.JawParts;
            end
        end
    end
    
    methods (Access = protected)
        function resetCache(obj)
            %resetCache Resets any cached properties
            obj.Cache.JawParts = [];
        end
        
        function cpObj = copyElement(obj)
            %copyElement Implements deep copy behavior for message
            
            % Call default copy method for shallow copy
            cpObj = copyElement@robotics.ros.Message(obj);
            
            % Clear any existing cached properties
            cpObj.resetCache;
            
            % Create a new Java message object
            cpObj.JavaMessage = obj.createNewJavaMessage;
            
            % Iterate over all primitive properties
            cpObj.Name = obj.Name;
            cpObj.BasicType = obj.BasicType;
            cpObj.JawLength = obj.JawLength;
            
            % Recursively copy compound properties
            cpObj.JawParts = copy(obj.JawParts);
        end
        
        function reload(obj, strObj)
            %reload Called by loadobj to assign properties
            obj.Name = strObj.Name;
            obj.BasicType = strObj.BasicType;
            obj.JawLength = strObj.JawLength;
            JawPartsCell = arrayfun(@(x) feval([obj.IrobMsgsInstrumentJawPartClass '.loadobj'], x), strObj.JawParts, 'UniformOutput', false);
            obj.JawParts = vertcat(JawPartsCell{:});
        end
    end
    
    methods (Access = ?robotics.ros.Message)
        function strObj = saveobj(obj)
            %saveobj Implements saving of message to MAT file
            
            % Return an empty element if object array is empty
            if isempty(obj)
                strObj = struct.empty;
                return
            end
            
            strObj.Name = obj.Name;
            strObj.BasicType = obj.BasicType;
            strObj.JawLength = obj.JawLength;
            strObj.JawParts = arrayfun(@(x) saveobj(x), obj.JawParts);
        end
    end
    
    methods (Static, Access = {?matlab.unittest.TestCase, ?robotics.ros.Message})
        function obj = loadobj(strObj)
            %loadobj Implements loading of message from MAT file
            
            % Return an empty object array if the structure element is not defined
            if isempty(strObj)
                obj = robotics.ros.custom.msggen.irob_msgs.InstrumentInfo.empty(0,1);
                return
            end
            
            % Create an empty message object
            obj = robotics.ros.custom.msggen.irob_msgs.InstrumentInfo;
            obj.reload(strObj);
        end
    end
end
