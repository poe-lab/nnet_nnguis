classdef (Sealed) PatternRecognitionScriptGenerator < nnet.genscript.ScriptGenerator
    % PATTERNRECOGNITIONSCRIPTGENERATOR - This class is used to generate
    % training scripts for the "nprtool" when clicking the "Simple Script"
    % or "Advanced Script" buttons on the "Save Results" page.
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Access = private)
        InputName
        TargetName
        SampleByColumn
        HiddenLayerSize
        TrainPercent
        ValidatePercent
        TestPercent
        TrainingFunction
        PerformFunction
    end
    
    properties(Access = private, Constant)
        CodeForPlotFunctionsForPatternRecognitionNetwork = {
            'net.plotFcns = {''plotperform'',''plottrainstate'',''ploterrhist'', ...', ...
            '  ''plotconfusion'', ''plotroc''};', ...
            ''
            };
        CodeForPercentageErrorForPatternRecognitionNetwork = {
            'tind = vec2ind(t);', ...
            'yind = vec2ind(y);', ...
            'percentErrors = sum(tind ~= yind)/numel(tind);', ...
            ''
            };
        CodeForPlotsForPatternRecognitionNetwork = {
            '%figure, plotperform(tr)', ...
            '%figure, plottrainstate(tr)', ...
            '%figure, ploterrhist(e)', ...
            '%figure, plotconfusion(t,y)', ...
            '%figure, plotroc(t,y)', ...
            ''
            };
    end
    
    properties(Access = private, Dependent)
        CodeForInputDataForPatternRecognitionNetwork
        CodeForCreationOfPatternRecognitionNetwork
        AdvancedCodeForTrainingPatternRecognitionNetwork
    end
    
    methods
        function this = PatternRecognitionScriptGenerator( state )
            this.InputName = state.inputName;
            this.TargetName = state.targetName;
            this.SampleByColumn = state.sampleByColumn;
            this.HiddenLayerSize = state.net2.layers{1}.size;
            this.TrainPercent = state.net2.divideParam.trainRatio*100;
            this.ValidatePercent = state.net2.divideParam.valRatio*100;
            this.TestPercent = state.net2.divideParam.testRatio*100;
            this.TrainingFunction = state.net2.trainFcn;
            this.PerformFunction = state.net2.performFcn;
        end
        
        function code = generateSimpleScript(this)
            code = [
                this.CodeForInputDataForPatternRecognitionNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfPatternRecognitionNetwork, ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'sample', false), ...
                this.CodeForTrainingAndTestingStaticNetwork, ...
                this.CodeForPercentageErrorForPatternRecognitionNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForPatternRecognitionNetwork
                ];
        end
        
        function code = generateAdvancedScript(this)
            code = [
                this.CodeForInputDataForPatternRecognitionNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfPatternRecognitionNetwork, ...
                this.AdvancedCodeForProcessFunctions, ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'sample', true), ...
                this.AdvancedCodeForTrainingPatternRecognitionNetwork, ...
                this.CodeForTrainingAndTestingStaticNetwork, ...
                this.CodeForPercentageErrorForPatternRecognitionNetwork, ...
                this.AdvancedCodeForRecalculatedPerformanceForStaticNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForPatternRecognitionNetwork, ...
                this.AdvancedCodeForDeploymentForStaticNetwork
                ];
        end
        
        function code = get.CodeForInputDataForPatternRecognitionNetwork(this)
            code = [
                {
                '% Solve a Pattern Recognition Problem with a Neural Network', ...
                '% Script generated by Neural Pattern Recognition app', ...
                this.generateCommentForDateOfCreation(), ...
                '%', ...
                '% This script assumes these variables are defined:', ...
                '%', ...
                ['%   ' this.InputName ' - input data.'], ...
                ['%   ' this.TargetName ' - target data.'], ...
                ''
                }, ...
                this.generateCodeForDataDefinitionForStaticNetwork(this.SampleByColumn, ...
                    this.InputName, this.TargetName), ...
                {''}
                ];
        end
        
        function code = get.CodeForCreationOfPatternRecognitionNetwork(this)
            code = {
                '% Create a Pattern Recognition Network', ...
                ['hiddenLayerSize = ' mat2str(this.HiddenLayerSize) ';'], ...
                'net = patternnet(hiddenLayerSize, trainFcn);', ...
                ''
                };
        end
        
        function code = get.AdvancedCodeForTrainingPatternRecognitionNetwork(this)
            code = [
                this.generateCodeForPerformanceFunction(this.PerformFunction), ...
                this.CommentForPlotFunctions, ...
                this.CodeForPlotFunctionsForPatternRecognitionNetwork
                ];
        end
    end
end