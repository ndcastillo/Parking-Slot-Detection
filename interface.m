
function varargout = interface(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function interface_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = interface_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)   
    
    % Asignacion de imagenes
    texto = get(handles.edit3,'String');
    texto = strcat('Prueba/',texto);
    im = imread(texto);
    w=im;
    axes(handles.axes4)
    imshow(im)
    im = rgb2gray(im); % Grizacion de imagen a analizar
    
    parque = imread('Prueba/park1.jpg');
    parque = rgb2gray(parque); % Grizacion de imagen sin autos
    
    th = 210; % Valor de Treshold
    parque(parque < th) = 0;
    parque(parque >= th) = 255;
    im(im < th) = 0;
    im(im >= th) = 255;
    
    % Operaciones Morfologicas
    SE = imfill(im,'holes');
    SEparque = imfill(parque, 'holes');
   
    % Escalamiento de letras
    p = imread('Entrenamiento/1-1.bmp');
    p = imresize(p, 0.1);
    p = imfill(p,'holes');
    e = imread('Entrenamiento/1-2.bmp');
    e =imresize(e, 0.1);
    
    % Correlación Cruzada
    acorr_P = normxcorr2(p,SE);
    acorrparque_P = normxcorr2(p,SEparque);
    acorr_E = normxcorr2(e,SE);
    acorrparque_E = normxcorr2(e,SEparque);
    
    % Asignación de Maximos Relativos
    [fx_P fy_P] = find(acorr_P >= 0.55); % Deteccion de maximos relativos
    [fxparque_P fyparque_P] = find(acorrparque_P >= 0.55);
    Xparque_P = [fxparque_P fyparque_P];
    [idx_P, C_P] = kmeans(Xparque_P,10); % Clusterizacion
    X_P = [fx_P fy_P];
    [n_P m_P] = size(X_P);
    
    [fx_E fy_E] = find(acorr_E >= 0.55); % Deteccion de maximos relativos
    [fxparque_E fyparque_E] = find(acorrparque_E >= 0.55);
    Xparque_E = [fxparque_E fyparque_E];
    [idx_E, C_E] = kmeans(Xparque_E,2); % Clusterizacion
    X_E = [fx_E fy_E];
    [n_E m_E] = size(X_E);
    
    % Verificación de Centroides con los maximos Relativos para la letra P
    num_datos_P = length(X_P);
    num_centroides_P = length(C_P);
    posicion_P = zeros(1,10);
    contador_P = 0;

    for i = 1:num_centroides_P
        for j=1:num_datos_P
            d_P = sqrt((C_P(i,1)-X_P(j,1)).^2 + (C_P(i,2)-X_P(j,2)).^2);
            if d_P > 20

            else
                posicion_P(i) = 1;
            end
        end
    end
    
    % Verificación de Centroides con los maximos Relativos para la letra E
    num_datos_E = length(X_E);
    num_centroides_E = length(C_E);
    posicion_E = zeros(1,2);
    contador_E = 0;

    for i = 1:num_centroides_E
        for j=1:num_datos_E
            d_E = sqrt((C_E(i,1)-X_E(j,1)).^2 + (C_E(i,2)-X_E(j,2)).^2);
            if d_E > 20

            else
                posicion_E(i) = 1;
            end
        end
    end
    
    % Conteo de lugares disponibles
    contador_P=0;
    for i=1:length(posicion_P)
        contador_P = contador_P + posicion_P(i);
    end
    set(handles.edit1,'String',contador_P);
    
    C_P(:,1) =C_P(:,1).* posicion_P';
    C_P(:,2) =C_P(:,2).* posicion_P';
    
    % Pintado de lugares Disponibles para P
    for i = 1:length(C_P)
       if posicion_P(i) == 1
           ini(i,1)=round(C_P(i,1)-52);
           ini(i,2)=round(C_P(i,2)-52);

           fin(i,1)=round(C_P(i,1));
           fin(i,2)=round(C_P(i,2));

           w(ini(i,1):fin(i,1),ini(i,2):fin(i,2)) = 255;
       end
    end
    
    contador_E=0;
    for i=1:length(posicion_E)
        contador_E = contador_E + posicion_E(i);
    end
    set(handles.edit2,'String',contador_E);
    
    C_E(:,1) =C_E(:,1).* posicion_E';
    C_E(:,2) =C_E(:,2).* posicion_E';
    
    % Pintado de lugares Disponibles para E
    for i = 1:length(C_E)
       if posicion_E(i) == 1
           ini(i,1)=round(C_E(i,1)-52);
           ini(i,2)=round(C_E(i,2)-52);

           fin(i,1)=round(C_E(i,1));
           fin(i,2)=round(C_E(i,2));

           w(ini(i,1):fin(i,1),ini(i,2):fin(i,2)) = 255;
       end
    end
    
    % Muestra de Imagenes y Resultados en los Axes de la Interfaz
    axes(handles.axes5)
    imshow(w)
    
    axes(handles.axes6)
    surf(acorr_P)
    xlabel('Posición X')
    ylabel('Posición Y')
    zlabel('Indice de Correlación')
    shading flat;
    
    X = [X_P(:,1) X_P(:,2);X_E(:,1) X_E(:,2)];
    axes(handles.axes7)
    scatter(X(:,1),X(:,2))
    xlabel('Posición X')
    ylabel('Posicion Y')
    axis([0 720 0 1200])
    

function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
