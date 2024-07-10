function removeMasks(sys)
% REMOVEMASKS Clear the MaskDisplay parameter on blocks. Masks are commonly
% used for custom blocks, which the user may not want to reveal.

    sys = get_param(sys, 'handle');
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    mask_params = {'MaskDisplay' 'Mask' 'MaskInitialization' 'MaskCallbackString'};
    for i = 1:length(blocks)
        try
            m = Simulink.Mask.get(blocks(i));
            m.delete();
            %set_param(blocks(i), mask_params{m}, '');
        catch ME
            %if ~ismember(ME.identifier, {'Simulink:SampleTime:InvTsParamSetting_No_Continuous' 'SimulinkBlock:Foundation:BadSetParamValue' 'Simulink:Masking:CannotMaskReferenceBlock' 'Simulink:Commands:InvSimulinkObjectName' 'Simulink:Masking:CannotMaskInportShadowBlock' 'Simulink:Masking:InvalidParameterSettingWithPrompt' 'Simulink:Masking:Bad_Init_Commands' 'Simulink:blocks:SystemBlockInvalidModification' 'Simulink:Libraries:RefViolation'})
            if ~ismember(ME.identifier, {'Simulink:Masking:Methods_Invalid_InputTypes' 'Simulink:Masking:CannotExecuteMethodOnLinkBlk' 'Simulink:blocks:SystemBlockInvalidModification'})
                rethrow(ME)
            end
        end
    end
end