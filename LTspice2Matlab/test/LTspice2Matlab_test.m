function LTspice2Matlab_test;

	base_path = fileparts(mfilename('fullpath'));
    addpath( base_path );   %This puts the base directory for LTspice2Matlab in the path.
    
    
    h_error = dir( sprintf( 'example_error\\*.*' ) );
    for k=1:length(h_error),
        if h_error(k).isdir,  continue;  end
        the_file_name = sprintf( 'example_error\\%s', h_error(k).name );
        

        try,
            data1_info = LTspice2Matlab( the_file_name, [] );
            disp( sprintf( '--> FILE "%s" SHOULD HAVE TERMINATED IN AN ERROR BUT DID NOT.', the_file_name ) );
            return;
        catch,
            %disp(lasterr);    
            ref_file = sprintf( '%s.mat', strrep( the_file_name(1:end-4), 'example_error', 'example_error_ref' ) );
            if length(dir(ref_file))==0,
                error_created = lasterr;
                save( ref_file, 'error_created' );
            else,
                error_created_now = lasterr;
				error_created_now = strrep( regexprep( error_created_now, '\(line \d+\)', '' ), '==>', '' );
				error_created_now = strrep( error_created_now, [base_path,'\'], '' );
				error_created_now = strrep( error_created_now, base_path, '' );
				
                load( ref_file );  %loads error_created
				error_created = strrep( regexprep( error_created, '\(line \d+\)', '' ), '==>', '' );
				error_created = strrep( error_created, [base_path,'\'], '' );
				error_created = strrep( error_created, base_path, '' );

                values_match = exhaustive_match( lower(strtrim(regexprep(error_created_now,'\s+',' '))), lower(strtrim(regexprep(error_created,'\s+',' '))) );
                if values_match==0,
                    disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s" ...', the_file_name  ) );
                    disp( 'ERROR_CREATED_REF = ' );
                    disp( error_created );
                    disp( 'ERROR_CREATED_NOW = ' );
                    disp( error_created_now );
                    return;
                end
            end
            disp( sprintf( 'OK:  "%s"', the_file_name ) );
            %disp( '***' );
        end
        
    end    
    
    
    h_noerror = dir( sprintf( 'example_noerror\\*.*' ) );
    for k=1:length(h_noerror),
        if h_noerror(k).isdir,  continue;  end
        the_file_name = sprintf( 'example_noerror\\%s', h_noerror(k).name );
        
        %disp( sprintf( 'WORKING ON --> "%s"', the_file_name ) );
        
        data1_info = LTspice2Matlab( the_file_name, [] );
        data2_info = LTspice2Matlab( the_file_name.', [] );
        
        
        num_var = data1_info.num_variables;
        num_tpnts = data1_info.num_data_pnts;
        
        data1 = LTspice2Matlab( the_file_name );
        assert( length(data1.selected_vars)==num_var, the_file_name, 'data1.num_variables==num_var', 1 );
        %assert( data1.num_data_pnts==num_tpnts, the_file_name, 'data1.num_data_pnts==num_tpnts', 2 );
        
        data2 = LTspice2Matlab( the_file_name, 1:num_var );
        assert( length(data2.selected_vars)==num_var, the_file_name, 'data2.num_variables==num_var', 3 );
        %assert( data2.num_data_pnts==num_tpnts, the_file_name, 'data2.num_data_pnts==num_tpnts', 4 );

        data3 = LTspice2Matlab( the_file_name, 2 );
        assert( length(data3.selected_vars)==1, the_file_name, 'data3.num_variables==1', 2 );
        
        data4 = LTspice2Matlab( the_file_name, 1:2:num_var );
        assert( length(data4.selected_vars)==length(1:2:num_var), the_file_name, 'data4.num_variables==length(1:2:num_var)', 5 );
        %assert( data4.num_data_pnts==num_tpnts, the_file_name, 'data4.num_data_pnts==num_tpnts', 6 );

        data5 = LTspice2Matlab( the_file_name, fliplr([2:3:(num_var-1)]) );
        assert( length(data5.selected_vars)==length([2:3:(num_var-1)]), the_file_name, 'data5.num_variables==length([2:3:(num_var-1)])', 7 );
        %assert( data5.num_data_pnts==num_tpnts, the_file_name, 'data5.num_data_pnts==num_tpnts', 8 );
        
        data6 = LTspice2Matlab( the_file_name, 'All' );
        data7 = LTspice2Matlab( the_file_name, 'All', 1 );
        assert( data7.num_data_pnts==data6.num_data_pnts, the_file_name, 'data7.num_data_pnts==data6.num_data_pnts', 9 );

        data8 = LTspice2Matlab( the_file_name, 'All', 2 );
        %assert( data8.num_data_pnts==floor(num_tpnts/2), the_file_name, 'data8.num_data_pnts==floor(num_tpnts/2)', 10 );
        
        
        ref_file = sprintf( '%s.mat', strrep( the_file_name(1:end-4), 'example_noerror', 'example_noerror_ref' ) );
        
        if length(dir(ref_file))==0,
            save( ref_file, 'data1_info', 'data2_info', 'data1', 'data2', 'data3', 'data4', 'data5', 'data6', 'data7', 'data8' );
        else,
            data1_info_now = data1_info;
            data2_info_now = data2_info;
            data1_now = data1;
            data2_now = data2;
            data3_now = data3;
            data4_now = data4;
            data5_now = data5;
            data6_now = data6;
            data7_now = data7;
            data8_now = data8;
            
            data1_info = [];  data2_info = [];  data1 = [];  data2 = [];  data3 = [];  data4 = [];  data5 = [];  data6 = [];  data7 = [];  data8 = [];

            load( ref_file );
            vminfo1 = exhaustive_match( data1_info_now, data1_info );
            vminfo2 = exhaustive_match( data2_info_now, data2_info );
            vm1 = exhaustive_match( data1_now, data1 );
            vm2 = exhaustive_match( data2_now, data2 );
            vm3 = exhaustive_match( data3_now, data3 );
            vm4 = exhaustive_match( data4_now, data4 );
            vm5 = exhaustive_match( data5_now, data5 );
            vm6 = exhaustive_match( data6_now, data6 );
            vm7 = exhaustive_match( data7_now, data7 );
            vm8 = exhaustive_match( data8_now, data8 );
            
            if ~vminfo1,  disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data1_info")', the_file_name  ) );  return;  end
            if ~vminfo2,  disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data2_info")', the_file_name  ) );  return;  end
            if ~vm1,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data1")',      the_file_name  ) );  return;  end
            if ~vm2,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data2")',      the_file_name  ) );  return;  end
            if ~vm3,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data3")',      the_file_name  ) );  return;  end
            if ~vm4,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data4")',      the_file_name  ) );  return;  end
            if ~vm5,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data5")',      the_file_name  ) );  return;  end
            if ~vm6,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data6")',      the_file_name  ) );  return;  end
            if ~vm7,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data7")',      the_file_name  ) );  return;  end
            if ~vm8,      disp( sprintf( '--> INCONSISTENCY FOUND IN FILE "%s"  (var "data8")',      the_file_name  ) );  return;  end
        end
            
        disp( sprintf( 'OK:  "%s"', the_file_name ) );

    end            
    
    disp( '****** DONE -- NO ERRORS FOUND ******' );


    
    
    
    
function assert( value_in, file_name, str_in, num_in );

    if ~value_in,  error( sprintf('--> ASSERTION FAILED ... %s ... %s ... %.0f', file_name, str_in, num_in) );  end
    return;
    
    
    
    
    
function values_match = exhaustive_match( valA, valB );
    %returns 1 if the two values are an exact match, 0 otherwise.

    err_verbose = 0;
    values_match = 0;
    if iscell(valA) & iscell(valB),
        if ~exhaustive_match( size(valA), size(valB) ),  if err_verbose, disp('A'); end;  return;  end
        for k=1:prod(size(valA)),
            if ~exhaustive_match( valA{k}, valB{k} ),  if err_verbose, disp('B'); end;  return;  end
        end
    elseif isstruct(valA) & isstruct(valB),
        A_names = fieldnames(valA);
        B_names = fieldnames(valB);
        if length(A_names)~=length(B_names),  if err_verbose, disp('C'); end;  return;  end
        Asize = size(valA);  Bsize = size(valB);
        if ~exhaustive_match(size(valA), size(valB)),  if err_verbose, disp('D'); end;  return;  end
        for q=1:prod(size(valA)),
            for k=1:length(A_names),
                if ~strcmp( A_names{k}, B_names{k} ),  if err_verbose, disp('DD');  end;  return;  end
                subvalA = getfield( valA(q), A_names{k} );
                subvalB = getfield( valB(q), B_names{k} );
                if ~exhaustive_match( subvalA, subvalB ),  if err_verbose, disp('E'); end;  return;  end
            end
        end
        
    elseif ischar(valA) & ischar(valB),
        if ~exhaustive_match( size(valA), size(valB) ),  if err_verbose,  disp('F1'); end;  return;  end
        if ~strcmp( valA, valB ),  if err_verbose, disp('F2'); end;  return;  end
        
    elseif isnumeric(valA) & isnumeric(valB),
        sizeA = size(valA);
        sizeB = size(valB);
        if length(sizeA)~=length(sizeB) | sum(abs(sizeA-sizeB))~=0,  if err_verbose, disp('G'); end;  return;  end
        %Okay ... dimensions appear to be equal.
        %Now check the actual values ...
        valA_flat = valA(:);
        valB_flat = valB(:);
        
        non_match = find( ~((isnan(valA_flat) & isnan(valB_flat)) | (valA_flat==valB_flat)) );
        if length(non_match)~=0,  if err_verbose, disp('H'); end;  return;  end

    elseif islogical(valA) & islogical(valB),
        valA = double(valA);  valB = double(valB);
        sizeA = size(valA);
        sizeB = size(valB);
        if length(sizeA)~=length(sizeB) | sum(abs(sizeA-sizeB))~=0,  if err_verbose, disp('J'); end;  return;  end
        valA_flat = valA(:);
        valB_flat = valB(:);
        non_match = find( ~((isnan(valA_flat) & isnan(valB_flat)) | (valA_flat==valB_flat)) );
        if length(non_match)~=0,  if err_verbose, disp('H'); end;  return;  end
        
    else,
        if err_verbose, disp('I'); end;  return;  %The two values are not even the same type.
    end
    
    values_match = 1;
    return;
    
