function find_diff_subsystems(ori, obf)
    ori = get_param(ori, 'handle');
    obf = get_param(obf, 'handle');
    while 1
        continues = 0;
        oris = find_system(ori, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem');
        obfs = find_system(obf, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem');
        for x = 1:min(length(oris), length(obfs))
            [ori_bl, ori_bt, ori_si, ori_ss] = count_elements(oris(x));
            [obf_bl, obf_bt, obf_si, obf_ss] = count_elements(obfs(x));
            if (ori_bl ~= obf_bl || ori_bt ~= obf_bt || ori_si ~= obf_si || ori_ss ~= obf_ss)  && obf ~= obfs(x) && ori ~= oris(x)
                obf = obfs(x);
                ori = oris(x);
                continues = 1;
                break
            end
        end
        if continues
            continue
        end
        open_system(obf)
        open_system(ori)
        break
    end

    fprintf("blocks: %i %i\n", ori_bl, obf_bl)
    fprintf("blocktypes: %i %i\n", ori_bt, obf_bt)
    fprintf("signals: %i %i\n", ori_si, obf_si)
    fprintf("subsystems: %i %i\n", ori_ss, obf_ss)
    return
end

function [blocks, blocktypes, signals, subsystems] = count_elements(sys)
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants);
    blocktypes = length(unique(get_param(blocks(2:end), 'BlockType')));
    blocks = length(blocks);
    signals = length(find_system(sys, 'FindAll', 'on', 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Line'));
    subsystems = length(find_system(sys, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem'));
end