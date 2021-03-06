% Ponto de visão
e = [10 10 10];

objetos = {};
objetos{1} = struct();
objetos{1}.cor = [50 0 255];
objetos{1}.tipo = 'esfera';
objetos{1}.centro = [0 0 0];
objetos{1}.raio = 3;

objetos{2} = struct();
objetos{2}.cor = [255 100 100];
objetos{2}.tipo = 'esfera';
objetos{2}.centro = [5 7 0];
objetos{2}.raio = 2;

% Iluminação
% l = kd * 
% normal = (centro - pt) / norma

% Ponto de iluminação
ponto_iluminacao = [7 0 -1];

% Distância focal
d = 5;

% Vetor unitário w
w = e / norm(e);
[~,t_aux] = min(abs(e));
t = e;
t(t_aux) = 1;

% Vetor unitário u
u = (cross(t, w)) / (norm(cross(t, w)));

% Vetor unitário v
v = cross(u, w);

linhas = 420;
colunas = 400;
matriz = zeros(linhas, colunas);

r_param = 20;
l_param = -20;
j_param = 20;
b_param = -20;

matriz_p = zeros(linhas, colunas);

% Ponto da esfera 1
c1 = objetos{1}.centro;

% Ponto da esfera 2
c2 = objetos{2}.centro;

% Raio da esfera 1
r1 = objetos{1}.raio;

% Raio da esfera 2
r2 = objetos{2}.raio;

% Matriz de t da esfera 1 (p(t) = e + t * d)
vetor_t_1 = zeros(linhas, colunas);

% Matriz de t da esfera 1 (p(t) = e + t * d)
vetor_t_2 = zeros(linhas, colunas);

imagem = zeros(linhas, colunas, 3);

ii = 1;

for i = 1:linhas
    for j = 1:colunas
        u_value = l_param + (r_param - l_param) * (i + 0.5) / linhas;
        v_value = b_param + (j_param - b_param) * (j + 0.5) / colunas;
        
        % Oblíquo
        % origem = e;
        % direcao = -d * w + u_value * u + v_value * v
        
        % Ortográfico
        origem = e + u_value * u + v_value * v;
        direcao = -w;
        min_t = 200000000;
        indice_min = -1;

        for index = 1 : size(objetos, 2)
            
            if(strcmp(objetos{index}.tipo, 'esfera'))
                centro = objetos{index}.centro;
                raio = objetos{index}.raio; 
                delta = ((dot((2 * direcao), (origem - centro))) * (dot((2 * direcao), (origem - centro)))) - (4 * dot(direcao, direcao) * (dot((origem - centro), (origem - centro)) - (raio * raio)));
                
                if(delta >= 0)
                    % Computa o t
                    t_1 = (dot(-direcao, (origem - centro)) + sqrt(delta)) / (dot(direcao, direcao));
                    t_2 = (dot(-direcao, (origem - centro)) - sqrt(delta)) / (dot(direcao, direcao));
                    objetos{index}.mt(i,j) = t_1;

                    if(abs(t_1) < abs(t_2))
                       min_t_iteration = t_1;
                    else
                       min_t_iteration = t_2;
                    end
                    
                    if(min_t_iteration < min_t)
                        min_t = min_t_iteration;
                        indice_min = index;
                    end
                    
                    % 
%                     objetos{index}.p = origem + direcao * min_t_iteration;
%                     n = (p - centro) / norm(p - centro);
%                     l = (p - ponto_iluminacao) / norm(p - ponto_iluminacao);
%                     h = (w + l) / norm(w + l);
% %                     kd = objetos{index}.cor;
%                     ks = [50 0 255]; 
%                     iluminacao_value = kd * ii * max(0, dot(n, l)) + ks * ii * max(0, dot(n, h));
                end       
            end
        end
        
        if(indice_min ~= -1)
            p = origem + direcao * min_t;
            n = (p - objetos{indice_min}.centro) / norm(p - objetos{indice_min}.centro);
            l = (p - ponto_iluminacao) / norm(p - ponto_iluminacao);
            vi = (p - e) /norm(p - e);
            h = (vi + l) / norm(vi + l);

            % Cor da luz
            ks = [50 0 255]; 
            
            % Cor do ambiente
            ka = [30 0 0];
            
            % Intensidade do luz do ambiente
            ia = 2;
            
            % Intensidade da cor da luz
            pp = 0.5;
            
            % Definição da cor considerando o blinn phong
            imagem(i, j, 1) = ka(1)*ia + objetos{indice_min}.cor(1)* ii * max(0, dot(n, l)) + ks(1) * ii * max(0, dot(n, h)^pp);
            imagem(i, j, 2) = ka(2)*ia + objetos{indice_min}.cor(2)* ii * max(0, dot(n, l)) + ks(2) * ii * max(0, dot(n, h)^pp);
            imagem(i, j, 3) = ka(3)*ia + objetos{indice_min}.cor(3)* ii * max(0, dot(n, l)) + ks(3) * ii * max(0, dot(n, h)^pp);
            
% Definição da cor considerando apenas lambert
%             imagem(i, j, 1) = objetos{indice_min}.cor(1)* ii * max(0, dot(n, l));
%             imagem(i, j, 2) = objetos{indice_min}.cor(2)* ii * max(0, dot(n, l));
%             imagem(i, j, 3) = objetos{indice_min}.cor(3)* ii * max(0, dot(n, l));
        end
    end
end

imagem = uint8(imagem);
figure, imshow(imagem);

