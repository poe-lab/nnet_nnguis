classdef (Sealed) FittingScriptGenerator < nnet.genscript.ScriptGenerator
    % FITTINGSCRIPTGENERATOR - This class is used to generate training
    % scripts for the "nftool" when clicking the "Simple Script" or
    % "Advanced Script" buttons on the "Save Results" page.
    
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
        CodeForPlotFunctionsForFittingNetwork = {
            'net.plotFcns = {''plotperform'',''plottrainstate'',''ploterrhist'', ...', ...
            '  ''plotregression'', ''plotfit''};', ...
            ''
            };
        CodeForPlotsForFittingNetwork = {
            '%figure, plotperform(tr)', ...
            '%figure, plottrainstate(tr)', ...
            '%figure, ploterrhist(e)', ...
            '%figure, plotregression(t,y)', ...
            '%figure, plotfit(net,x,t)', ...
            ''
            };
    end
    
    properties(Access = private, Dependent)
        CodeForInputDataForFittingNetwork
        CodeForCreationOfFittingNetwork
        AdvancedCodeForTrainingFittingNetwork
    end
    
    methods
        function this = FittingScriptGenerator( state )
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
                this.CodeForInputDataForFittingNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfFittingNetwork, ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'sample', false), ...
                this.CodeForTrainingAndTestingStaticNetwork, ...
                {''}, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForFittingNetwork
                ];
        end
        
        function code = generateAdvancedScript(this)            
            code = [
                this.CodeForInputDataForFittingNetwork, ...
                this.generateCodeForTrainingFunction(this.TrainingFunction), ...
                this.CodeForCreationOfFittingNetwork, ...
                this.AdvancedCodeForProcessFunctions, ...
                this.generateCodeForDataDivision(this.TrainPercent, this.TestPercent, this.ValidatePercent, 'sample', true), ...
                this.AdvancedCodeForTrainingFittingNetwork, ...
                this.CodeForTrainingAndTestingStaticNetwork, ...
                {''}, ...
                this.AdvancedCodeForRecalculatedPerformanceForStaticNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForFittingNetwork, ...
                this.AdvancedCodeForDeploymentForStaticNetwork
                ];
        end
        
        function code = get.CodeForInputDataForFittingNetwork(this)
            code = [
                {
                '% Solve an Input-Output Fitting problem with a Neural Network', ...
                '% Script generated by Neural Fitting app', ...
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
        
        function code = get.CodeForCreationOfFittingNetwork(this)
            code = {
                '% Create a Fitting Network', ...
                ['hiddenLayerSize = ' mat2str(this.HiddenLayerSize) ';'], ...
                'net = fitnet(hiddenLayerSize,trainFcn);', ...
                ''
                };
        end
        
        function code = get.AdvancedCodeForTrainingFittingNetwork(this)
            code = [
                this.generateCodeForPerformanceFunction(this.PerformFunction), ...
                this.CommentForPlotFunctions, ...
                this.CodeForPlotFunctionsForFittingNetwork
                ];
        end
    end
end