classdef (Sealed) TimeDelayScriptGenerator < nnet.genscript.ScriptGenerator
    % TIMEDELAYSCRIPTGENERATOR - This class is used to generate training
    % scripts for nonlinear input-output networks in "ntstool" when
    % clicking the "Simple Script" or "Advanced Script" buttons on the
    % "Save Results" page.
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Access = private)
        InputName
        TargetName
        TimestepInCell
        SampleByColumn
        TrainPercent
        ValidatePercent
        TestPercent
        HiddenLayerSize
        NumDelayLines
        TrainingFunction
        PerformFunction
    end
    
    properties(Access = private, Dependent)
        CodeForInputDataForTimeDelayNetwork
        CodeForCreationOfTimeDelayNetwork
    end
    
    methods
        function this = TimeDelayScriptGenerator( state )
            this.InputName = state.inputName;
            this.TargetName = state.targetName;
            this.TimestepInCell = state.timeInCell;
            this.SampleByColumn = state.sampleByColumn;
            this.TrainPercent = state.net2.divideParam.trainRatio*100;
            this.ValidatePercent = state.net2.divideParam.valRatio*100;
            this.TestPercent = state.net2.divideParam.testRatio*100;
            this.HiddenLayerSize = state.layerSize;
            this.NumDelayLines = state.delaySize;
            this.TrainingFunction = state.net2.trainFcn;
            this.PerformFunction = state.net2.performFcn;
        end
        
        function code = generateSimpleScript(this)
            code = [
                this.CodeForInputDataForTimeDelayNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfTimeDelayNetwork, ...
                this.generateCodeForDataPreparation('X'), ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'time', false), ...
                this.CodeForTrainingAndTestingDynamicNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForDynamicNetwork, ...
                this.generateCodeForStepAheadPrediction('x', 'X')
                ];
        end
        
        function code = generateAdvancedScript(this)
            code = [
                this.CodeForInputDataForTimeDelayNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfTimeDelayNetwork, ...
                this.AdvancedCodeForProcessFunctions, ...
                this.generateCodeForDataPreparation('X'), ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'time', true), ...
                this.generateAdvancedCodeForTrainingDynamicNetwork(this.PerformFunction), ...
                this.CodeForTrainingAndTestingDynamicNetwork, ...
                this.AdvancedCodeForRecalculatedPerformanceForDynamicNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForDynamicNetwork, ...
                this.generateCodeForStepAheadPrediction('x', 'X'), ...
                this.AdvancedCodeForDeploymentForNAROrTimeDelayNetwork
                ];
        end
        
        function code = get.CodeForInputDataForTimeDelayNetwork(this)
            code = [
                {
                '% Solve an Input-Output Time-Series Problem with a Time Delay Neural Network', ...
                '% Script generated by Neural Time Series app.', ...
                this.generateCommentForDateOfCreation(), ...
                '%', ...
                '% This script assumes these variables are defined:', ...
                '%', ...
                ['%   ' this.InputName ' - input time series.'], ...
                ['%   ' this.TargetName ' - target time series.'], ...
                ''
                }, ...
                this.generateCodeForDataDefinitionForNARXOrTimeDelayNetwork(this.SampleByColumn, ...
                    this.TimestepInCell, this.InputName, this.TargetName), ...
                {''}
                ];
        end
        
        function code = get.CodeForCreationOfTimeDelayNetwork(this)
            code = {
                '% Create a Time Delay Network', ...
                ['inputDelays = 1:' mat2str(this.NumDelayLines) ';'], ...
                ['hiddenLayerSize = ' mat2str(this.HiddenLayerSize) ';'], ...
                'net = timedelaynet(inputDelays,hiddenLayerSize,trainFcn);', ...
                ''
                };
        end
    end
end