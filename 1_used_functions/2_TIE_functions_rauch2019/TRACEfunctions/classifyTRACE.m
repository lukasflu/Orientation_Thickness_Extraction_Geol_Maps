

function TRACE = classifyTRACE(TRACE,pth)

% CLASSIFY TRACE
% Trace classification based on TIE
%
% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
%               could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.matrix   = matrix size of BED or TEC
%               -> TRACE.length   = index array of length (in m) between
%                                   two individual points. Sum of the
%                                   array corresponds to the trace length
%               -> TRACE.Segment  = structure of trace segments. Fields needed:
%                       Segment.Chords    = sturcture of connecting chord information
%                               -> Chords.alpha     = alpha for each connecting chord
%
%                       Segment.ChordsR   = sturcture of connecting chord information
%                                           based on reverse orientation analysis
%                                           same structure as Segment.Chords
%
%                       Segment.ChdPlane  = structure of Chord plane information
%                               -> ChdPlane.beta    = beta through each chord plane
%                      
%                       Segment.ChdPlaneR = structure of Chord plane information 
%                                           based on reverse orientation analysis
%                                           same structure as Segment.ChdPlane
% pth       -> planarity thresholds: [p1, p2, p3]. Typically p = [3,9,18]; 
%
% ----------
% OUTPUT
% TRACE     -> structure containing TRACE information (as input) with added fields:
%                       Segment.signalheight  = [signalheight alpha, % signalheight beta                    
%                       Segment.classID       = ID of classification zone.
%                       Segment.classcode     = colorcode[r,g,b] according to % classID
                        

%%

    cmapblue    = flipud([0 1 1; 0 0.7 1; 0 0.4 1; 0.3 0 0.8]);
    cmapred     = flipud([0.98 0.7 0.9; 0.953 0.557 0.718; 0.933 0.247 0.463; 0.616 0.106 0.286]);    
    p1          = pth(1);
    p2          = pth(2);
    p3          = pth(3);
    
for t = 1:length(TRACE)
    Seg     = TRACE(t).Segment;
    
    for s = 1:length(Seg)
        l       = length(Seg(s).index);
        aN      = [Seg(s).Chords.alpha];
        aN      = aN(~isnan(aN));
        aR      = [Seg(s).ChordsR.alpha];
        aR      = aR(~isnan(aR));
        bN      = [Seg(s).ChdPlane.beta];
        bN      = bN(~isnan(bN));
        bR      = [Seg(s).ChdPlaneR.beta];
        bR      = bR(~isnan(bR));

        alpS    = sum(aN + aR);
        alpD    = abs(sum(aN)-sum(aR));
        alp     = alpS - alpD;
        meana   = alp/length(Seg(s).Chords);

        if ~isempty(bN) && ~isempty(bR) 
            betS    = sum(bN + bR);
            betD    = abs(sum(bN)-sum(bR));
            bet     = betS - betD;
            meanb   = bet/length(Seg(s).ChdPlane);
        else
            meanb   = 180;
        end
        meanr   = meana/meanb;

        fcurb1a = 180./(meana-p1)+p1;
        fcurb2a = 180./(meana-p2)+p2;
        fcurb3a = 180./(meana-p3)+p3;

        fcurb1b = 180./(meanb-p1)+p1;
        fcurb2b = 180./(meanb-p2)+p2;
        fcurb3b = 180./(meanb-p3)+p3;

        if meanr < 1
            cmap    = cmapred;
            if meana > fcurb3b
                g   = 4;
            end
            if meana > fcurb2b && meana <= fcurb3b
                g   = 3;
            end
            if meana > fcurb1b && meana <= fcurb2b
                g   = 2;
            end
            if meana <= fcurb1b
                g   = 1;
            end

            Seg(s).classID = -g;
        else
            cmap    = cmapblue;
            if meanb > fcurb3a
                g   = 4;
            end
            if meanb > fcurb2a && meanb <= fcurb3a
                g   = 3;
            end
            if meanb > fcurb1a && meanb <= fcurb2a
                g   = 2;
            end
            if meanb <= fcurb1a
                g   = 1;
            end
            Seg(s).classID = g;
        end
        
        if l > 50
            Seg(s).classcode = cmap(g,:);
        else
            Seg(s).classcode = [0.4 0.4 0.4];
        end       
        Seg(s).signalheight = [meana,meanb];  
    end    
    TRACE(t).Segment = Seg;
end

