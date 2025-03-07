function [encrypted] = rotational_cipher(text, key, mode)
  text_numbers = int32(text); % Convert text to ASCII
  key = mod(key, 256); % Key within 0-255 range

  if strcmp(mode, 'e')
    encrypted_numbers = mod(text_numbers + key, 256); % Reminder after division - sort of loop
  elseif strcmp(mode, 'd')
    encrypted_numbers = mod(text_numbers - key, 256);
  else
    error('Unknown mode. Use "e - encrypt" or "d - decrypt".');
  end

  encrypted = uint8(encrypted_numbers); % Returning int [0, 255] 
  % I have tried to return char, but this caused errors 
  % within image encryption
end

function [encrypted] = one_time_pad_cipher(text, key, mode)
    text_numbers = int32(text); % Convert text to numbers (ASCII codes), size must be equal to key 
    key_numbers = int32(key);

    text_length = length(text_numbers);
    key_length = length(key_numbers);
    encrypted_numbers = zeros(text_length, 1, 'uint8'); % Creating one-dimentional matrix

    for i = 1:text_length
        key_index = mod(i - 1, key_length) + 1;
        if strcmp(mode, 'e')
            encrypted_numbers(i) = mod(text_numbers(i) + key_numbers(key_index), 256);
        elseif strcmp(mode, 'd')
            encrypted_numbers(i) = mod(text_numbers(i) - key_numbers(key_index), 256);
        else
            error('Unknown mode. Use "e" or "d".');
        end
    end
    
    encrypted = uint8(encrypted_numbers); % Returning int [0, 255]
end

% Most issues i've had was caused due to wrong data types. For example
% text_numbers = uint8(text); in rotational_cipher
% caused error in signs distriubutions
% text_numbers = uint8(text); in one_time_pad_cipher
% caused error when combining with other types of integers

function test()
    disp('------------------ Rotational Cipher ------------------');
    key = 512;

    plaintext = 'MyOriginalPassword123';
    encrypted = rotational_cipher(plaintext, key, 'e');
    decrypted = rotational_cipher(encrypted, key, 'd');

    disp(['key: ', num2str(key)]);
    disp(['Plaintext: ', plaintext, ' || In ASCII: ', num2str(uint8(plaintext(1:10)))]);
    disp(['Encrypted: ', char(encrypted), ' || In ASCII: ', num2str(encrypted)]);
    disp(['Decrypted: ', char(decrypted)]);

    disp('------------------ One Time Cipher ------------------');

    key_20 = randi([0, 255], 1, 20);
    disp(['key length 20: ', num2str(key_20(1:10)), ' ...']);

    plaintext = 'MySecretMessage';
    encrypted = one_time_pad_cipher(plaintext, key_20, 'e');
    decrypted = one_time_pad_cipher(encrypted, key_20, 'd');

    disp(['Plaintext: ', plaintext, ' || In ASCII: ', num2str(uint8(plaintext(1:10)))]);
    disp(['Encrypted: ', char(encrypted'), ' || In ASCII: ', num2str(encrypted')]);
    disp(['Decrypted: ', char(decrypted'), ' || In ASCII: ', num2str(decrypted')]);

    key_65536 = randi([0, 255], 1, 65536);
    disp(['key length 65536: ', num2str(key_65536(1:10)), ' ...']);

    plaintext = 'MySecretMessage';
    encrypted = one_time_pad_cipher(plaintext, key_65536, 'e');
    decrypted = one_time_pad_cipher(encrypted, key_65536, 'd');

    disp(['Plaintext: ', plaintext, ' || In ASCII: ', num2str(uint8(plaintext(1:10)))]);
    disp(['Encrypted: ', char(encrypted'), ' || In ASCII: ', num2str(encrypted')]);
    disp(['Decrypted: ', char(decrypted'), ' || In ASCII: ', num2str(decrypted')]);
end

function encrypt_txt_file()
    % Loading text from file
    try
        fid = fopen('PolishHistory.txt', 'r'); % Typing UTF-8 causes errors
        if fid == -1
            error('Could not open file polishHistory.txt.');
        end
        plaintext = fread(fid, '*char')';
        fclose(fid);
    catch ME
        disp(['An error occurred: ', ME.message]);
        return;
    end

    % Rotational cipher encryption
    shifts = [20, 152, 498]; 
    % choosing those to show whole spectrum of shifts [0, 255]. 
    % 498 = 255 + 243, i wanted to show that it works for numbers > 255

    encrypted_rotational = cell(1, length(shifts));
    for i = 1:length(shifts)
        encrypted_rotational{i} = rotational_cipher(plaintext, shifts(i), 'e');
    end

    % One-time pad cipher encryption
    key_20 = randi([0, 255], 1, 20);
    key_65536 = randi([0, 255], 1, 65536);
    encrypted_one_time1 = one_time_pad_cipher(plaintext, key_20, 'e');
    encrypted_one_time2 = one_time_pad_cipher(plaintext, key_65536, 'e');

    % -----------Plot histograms-------------
    figure;
    
    % Plaintext Histogram
    subplot(2, 3, 1);
    [counts, values] = histcounts(uint8(plaintext), 0:255);
    bar(values(1:end-1), counts);
    title('Plaintext Histogram');
    
    % Rotational cipher histograms
    for i = 1:length(shifts)
        subplot(2, 3, i + 1);
        [counts, values] = histcounts(uint8(encrypted_rotational{i}), 0:255);
        bar(values(1:end-1), counts);
        title(['Rotational, shift ', num2str(shifts(i))]);
    end
    
    % One-time pad cipher histograms
    subplot(2, 3, 5);
    [counts, values] = histcounts(uint8(encrypted_one_time1), 0:255);
    bar(values(1:end-1), counts);
    title('One-time pad key_20');
    
    subplot(2, 3, 6);
    [counts, values] = histcounts(uint8(encrypted_one_time2), 0:255);
    bar(values(1:end-1), counts);
    title('One-time pad key_65536');
end

function encrypt_images()
    % Load images
    image_a = imread('a.png');
    image_b = imread('b.png');

    % Rotational cipher encryption
    shifts = [20, 152, 498];
    encrypted_rotational_a = cell(1, length(shifts));
    encrypted_rotational_b = cell(1, length(shifts));
    for i = 1:length(shifts)
        encrypted_rotational_a{i} = rotational_cipher_image(image_a, shifts(i), 'e');
        encrypted_rotational_b{i} = rotational_cipher_image(image_b, shifts(i), 'e');
    end

    % One-time pad cipher encryption
    key_20 = randi([0, 255], 1, 20);
    key_65536 = randi([0, 255], 1, 65536);
    encrypted_one_time_a_20 = one_time_pad_cipher_image_key(image_a, key_20, 'e');
    encrypted_one_time_b_20 = one_time_pad_cipher_image_key(image_b, key_20, 'e');
    encrypted_one_time_a_65536 = one_time_pad_cipher_image_key(image_a, key_65536, 'e');
    encrypted_one_time_b_65536 = one_time_pad_cipher_image_key(image_b, key_65536, 'e');

    % Original images
    figure;
    n = length(shifts); % for more flexible arrangment
    subplot(3, 4, 1); imshow(image_a); title('Original "a"');
    subplot(3, 4, n + 2); imshow(image_b); title('Original "b"');

    % Rotational cipher images
    for i = 1:n
        subplot(3, 4, i + 1); imshow(encrypted_rotational_a{i}); title(['Rotational "a", shift ', num2str(shifts(i))]);
        subplot(3, 4, i + 2 + n); imshow(encrypted_rotational_b{i}); title(['Rotational "b", shift ', num2str(shifts(i))]);
    end

    % One-time pad cipher images (using your keys)
    subplot(3, 4, 2 * n + 3); imshow(encrypted_one_time_a_20); title('One-time pad "a" key 20');
    subplot(3, 4, 2 * n + 4); imshow(encrypted_one_time_a_65536); title('One-time pad "a" key 65536');
    subplot(3, 4, 2 * n + 5); imshow(encrypted_one_time_b_20); title('One-time pad "b" key 20');
    subplot(3, 4, 2 * n + 6); imshow(encrypted_one_time_b_65536); title('One-time pad "b" key 65536');

    % Decrypted images
    figure;
    subplot(3, 4, 1); imshow(image_a); title('Original "a"');
    subplot(3, 4, n + 2); imshow(image_b); title('Original "b"');

    % Decrypted rotational cipher images
    decrypted_rotational_a = cell(1, length(shifts));
    decrypted_rotational_b = cell(1, length(shifts));
    for i = 1:length(shifts)
        decrypted_rotational_a{i} = rotational_cipher_image(encrypted_rotational_a{i}, shifts(i), 'd');
        decrypted_rotational_b{i} = rotational_cipher_image(encrypted_rotational_b{i}, shifts(i), 'd');
        subplot(3, 4, i + 1); imshow(decrypted_rotational_a{i}); title(['Decrypted Rotational "a", shift ', num2str(shifts(i))]);
        subplot(3, 4, i + 2 + n); imshow(decrypted_rotational_b{i}); title(['Decrypted Rotational "b", shift ', num2str(shifts(i))]);
    end

    % Decrypted one-time pad cipher images
    decrypted_one_time_a_20 = one_time_pad_cipher_image_key(encrypted_one_time_a_20, key_20, 'd');
    decrypted_one_time_b_20 = one_time_pad_cipher_image_key(encrypted_one_time_b_20, key_20, 'd');
    decrypted_one_time_a_65536 = one_time_pad_cipher_image_key(encrypted_one_time_a_65536, key_65536, 'd');
    decrypted_one_time_b_65536 = one_time_pad_cipher_image_key(encrypted_one_time_b_65536, key_65536, 'd');
    subplot(3, 4, 2 * n + 3); imshow(decrypted_one_time_a_20); title('Decrypted One-time pad "a" key 20');
    subplot(3, 4, 2 * n + 4); imshow(decrypted_one_time_a_65536); title('Decrypted One-time pad "a" key 65536');
    subplot(3, 4, 2 * n + 5); imshow(decrypted_one_time_b_20); title('Decrypted One-time pad "b" key 20');
    subplot(3, 4, 2 * n + 6); imshow(decrypted_one_time_b_65536); title('Decrypted One-time pad "b" key 65536');
end

function encrypted_image = rotational_cipher_image(image, shift, mode)
    image_bytes = image(:);                                         % Convertion to byte stream
    encrypted_bytes = rotational_cipher(image_bytes, shift, mode);  % Encrypt byte stream
    encrypted_image = reshape(uint8(encrypted_bytes), size(image)); % Convert encrypted byte stream back to image
end

function encrypted_image = one_time_pad_cipher_image_key(image, key, mode)
    image_bytes = image(:);                                         % Convertion to byte stream
    encrypted_bytes = one_time_pad_cipher(image_bytes, key, mode);  % Initialization of encrypted bytes
    encrypted_image = reshape(uint8(encrypted_bytes), size(image)); % Conversion back to image
end

function decrypt_data(decrypted_image_filename, encrypted_text_filename, passwords_filename)
    % Load passwords
    load(passwords_filename, 'hasla');
    num_passwords = length(hasla);

    % Load encrypted text
    openedFile = fopen(encrypted_text_filename, 'r');
    if openedFile == -1
        error(['Cannot open file: ', encrypted_text_filename]);
    end
    encrypted_text_bin = fread(openedFile, 'uint8');
    fclose(openedFile);

    % Decrypting text
    for i = 1:num_passwords
        key = hasla{i};
        decrypted_text_bytes = one_time_pad_cipher(encrypted_text_bin, key, 'd');
        % Check if decrypted text is readable
        if all(decrypted_text_bytes >= 32 & decrypted_text_bytes <= 126)
            disp(['Key found for text: hasla{' num2str(i) '}']);
            disp(['Decrypted text: ', char(decrypted_text_bytes(:))']);
        end
    end

    % Load encrypted image
    encrypted_image = imread(decrypted_image_filename);

    % Decrypting image
    best_std = Inf;
    best_key = [];
    best_decrypted_image = [];

    for i = 1:num_passwords
        key = hasla{i};
        decrypted_image = one_time_pad_cipher_image_key(encrypted_image, key, 'd');

        % Calculate standard deviation
        std_dev = std2(decrypted_image); % Returns standard deviation of an image

        if std_dev < best_std % Looking for best Standard deviation of matrix elements
            best_std = std_dev;
            best_key = key;
            best_decrypted_image = decrypted_image;
        end
    end

    if ~isempty(best_key)
        disp(['Best key found for image. std: ', num2str(best_std)]);
        figure;
        subplot(1, 2, 1); imshow(encrypted_image, []); title('Encrypted image');
        subplot(1, 2, 2); imshow(best_decrypted_image, []); title('Decrypted image');
    else
        disp('Key not found for image.');
    end
end

test();
encrypt_txt_file();
encrypt_images();
%decrypt_data('dane zaszyfrowane/3.png', 'dane zaszyfrowane/3_tekst.txt', 'dane zaszyfrowane/hasla.mat');
