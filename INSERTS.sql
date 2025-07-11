-- ============================
-- INSERTS DE DATOS INICIALES
-- ============================

-- Roles
INSERT INTO Rol (id_rol, nombre, descripcion) VALUES 
(1, 'administrador', 'Acceso completo al sistema'),
(2, 'cliente', 'Usuarios que compran productos'),
(3, 'jefe de tienda', 'Usuarios que publican y gestionan videojuegos');

-- Usuarios
INSERT INTO Usuario (id_usuario, nombre_usuario, ubicacion_usuario, contraseña, correo, id_rol) VALUES
(1, 'Admin Principal', 'Chile', 'admin123', 'admin@tienda.com', 1),
(2, 'Juan Pérez', 'Argentina', 'cliente123', 'juan@cliente.com', 2),
(3, 'María Gómez', 'Perú', 'cliente456', 'maria@cliente.com', 2),
(4, 'Carlos Méndez', 'México', 'passcarlos', 'carlos@cliente.com', 2),
(5, 'Lucía Torres', 'Colombia', 'passlucia', 'lucia@cliente.com', 2),
(6, 'Pedro Ruiz', 'Chile', 'passpedro', 'pedro@cliente.com', 2);

-- Categorías
INSERT INTO Categoria (id_categoria, nombre_categoria) VALUES
(1, 'Acción'), (2, 'Aventura'), (3, 'RPG'), (4, 'Deportes'), (5, 'Estrategia');

-- Videojuegos
INSERT INTO Videojuego (id_videojuego, nombre_videojuego, descripcion, precio, stock, url_imagen, id_categoria, id_usuario) VALUES
(1, 'FC 24', 'El mejor simulador de fútbol', 55900, 100, 'fc24.jpg', 4, 1),
(2, 'The Legend of Zelda', 'Aventura épica en Hyrule', 69990, 50, 'zelda.jpg', 2, 1),
(3, 'Elden Ring', 'RPG de mundo abierto', 45490, 75, 'eldenring.jpg', 3, 1),
(4, 'God of War', 'Acción épica mitológica', 35000, 80, 'gow.jpg', 1, 1),
(5, 'Hollow Knight', 'Metroidvania desafiante', 8300, 120, 'hollowknight.jpg', 2, 1),
(6, 'Age of Empires IV', 'Estrategia en tiempo real', 19900, 60, 'aoe4.jpg', 5, 1);

-- Carritos
INSERT INTO Carrito (id_carrito, id_usuario, estado) VALUES
(1, 2, 'activo'), (2, 3, 'activo'), (3, 4, 'activo'), (4, 5, 'activo'), (5, 6, 'activo');

-- Carrito_Detalle
INSERT INTO Carrito_Detalle (id_detalle, id_carrito, id_videojuego, cantidad, precio_unitario) VALUES
(1, 1, 1, 1, 55900),	--FC 24
(2, 1, 2, 1, 69990),	--Zelda
(3, 2, 3, 2, 45490),	--Elden Ring
(4, 3, 4, 1, 35000),	--GOD of War
(5, 4, 5, 1, 8300), 	--Hollow Knihgt
(6, 5, 6, 2, 19900);	--Age of Empires IV

-- Compras
INSERT INTO Compra (id_compra, id_usuario, medio_de_pago, precio_total, boleta_factura, fecha_compra) VALUES
(1, 2, 'Tarjeta de crédito', 125790, 'B001-0001', '2023-06-15'),	-- 55900 + 69990
(2, 3, 'PayPal', 90980, 'B001-0002', '2023-06-16'),					-- 2 x 45490
(3, 4, 'Débito', 35000, 'B001-0003', '2023-07-01'),					-- 1 x 35000
(4, 5, 'Tarjeta de crédito', 8300, 'B001-0004', '2023-07-02'),		-- 1 x 8300
(5, 6, 'PayPal', 39800, 'B001-0005', '2023-07-03');					-- 2 x 19900

-- Compra_Detalle
INSERT INTO Compra_Detalle (id_detalle_compra, id_compra, id_videojuego, cantidad, precio_unitario) VALUES
(1, 1, 1, 1, 55900),	--FC 24
(2, 1, 2, 1, 69990),	--Zelda
(3, 2, 3, 2, 45490),	--Elden Ring
(4, 3, 4, 1, 35000),	--GOD of War
(5, 4, 5, 1, 8300), 	--Hollow Knihgt
(6, 5, 6, 2, 19900);	--Age of Empires IV

-- Valoraciones
INSERT INTO Valoracion (id_valoracion, id_usuario, id_videojuego, estrellas, comentario) VALUES
(1, 2, 1, 4, 'Muy bueno pero necesita más ligas'),
(2, 3, 3, 5, 'Increíble juego, lo recomiendo'),
(3, 4, 4, 5, 'Increíble historia y jugabilidad'),
(4, 5, 5, 4, 'Muy entretenido, pero difícil'),
(5, 6, 6, 5, 'Me encanta jugar en línea con amigos');

-- Rankings
INSERT INTO Ranking (id_ranking, tipo_de_ranking, id_videojuego, puntuacion_promedio) VALUES
(1, 'Más vendidos', 1, 4.5),
(2, 'Mejor valorados', 3, 5.0),
(3, 'Novedades', 2, 4.0),
(4, 'Más jugados', 4, 4.8),
(5, 'Indies populares', 5, 4.2),
(6, 'Clásicos de estrategia', 6, 4.7);

-- Lista de deseos
INSERT INTO Lista_Deseos (id_lista, id_usuario, id_videojuego) VALUES
(1, 2, 3), (2, 3, 1), (3, 3, 2), (4, 4, 5), (5, 5, 1), (6, 6, 2), (7, 6, 3);

ALTER TABLE lista_deseos RENAME TO lista_deseados;