CREATE TABLE Usuario
(
  id_usuario VARCHAR NOT NULL,
  nombre VARCHAR NOT NULL,
  correo VARCHAR NOT NULL,
  contraseña INT NOT NULL,
  ubicación INT NOT NULL,
  PRIMARY KEY (id_usuario)
);

CREATE TABLE Rol
(
  id_rol VARCHAR NOT NULL,
  nombre_rol INT NOT NULL,
  id_usuario VARCHAR NOT NULL,
  PRIMARY KEY (id_rol),
  FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE listas_deseado
(
  id_lista_ INT NOT NULL,
  id_usuario VARCHAR NOT NULL,
  PRIMARY KEY (id_lista_),
  FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE videojuego
(
  id_videojuego_ INT NOT NULL,
  nombre INT NOT NULL,
  descripción INT NOT NULL,
  precio INT NOT NULL,
  stock INT NOT NULL,
  url_imagen INT NOT NULL,
  PRIMARY KEY (id_videojuego_)
);

CREATE TABLE valoracion
(
  id_valoracion_ INT NOT NULL,
  estrellas INT NOT NULL,
  comentario INT NOT NULL,
  restricciones INT NOT NULL,
  id_usuario VARCHAR NOT NULL,
  id_videojuego_ INT NOT NULL,
  PRIMARY KEY (id_valoracion_),
  FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
  FOREIGN KEY (id_videojuego_) REFERENCES videojuego(id_videojuego_)
);

CREATE TABLE categoria
(
  id_categoria INT NOT NULL,
  nombre_categoria INT NOT NULL,
  PRIMARY KEY (id_categoria)
);

CREATE TABLE pertenece_a
(
  id_videojuego_ INT NOT NULL,
  id_categoria INT NOT NULL,
  FOREIGN KEY (id_videojuego_) REFERENCES videojuego(id_videojuego_),
  FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE ranking
(
  id_ranking INT NOT NULL,
  tipo_de_ranking INT NOT NULL,
  PRIMARY KEY (id_ranking)
);

CREATE TABLE aparecen
(
  id_videojuego_ INT NOT NULL,
  id_ranking INT NOT NULL,
  FOREIGN KEY (id_videojuego_) REFERENCES videojuego(id_videojuego_),
  FOREIGN KEY (id_ranking) REFERENCES ranking(id_ranking)
);

CREATE TABLE compra
(
  id_compra INT NOT NULL,
  fecha INT NOT NULL,
  medio_pago INT NOT NULL,
  precio_total INT NOT NULL,
  boleta/factura INT NOT NULL,
  id_usuario VARCHAR NOT NULL,
  PRIMARY KEY (id_compra),
  FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE detalle_compra
(
  id_detalle_compra INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario INT NOT NULL,
  id_compra INT NOT NULL,
  id_videojuego_ INT NOT NULL,
  PRIMARY KEY (id_detalle_compra),
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
  FOREIGN KEY (id_videojuego_) REFERENCES videojuego(id_videojuego_)
);
