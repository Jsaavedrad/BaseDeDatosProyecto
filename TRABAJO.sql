-- ============================
-- CREACIÓN DE TABLAS
-- ============================

-- Tabla de Roles
CREATE TABLE Rol (
    id_rol INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de Usuarios
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    ubicacion_usuario VARCHAR(100) NOT NULL,
    contraseña VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    id_rol INT NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES Rol(id_rol)
);

-- Tabla de Categorías
CREATE TABLE Categoria (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL
);

-- Tabla de Videojuegos
CREATE TABLE Videojuego (
    id_videojuego INT PRIMARY KEY,
    nombre_videojuego VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    precio INT NOT NULL,
    stock INT NOT NULL,
    url_imagen VARCHAR(200),
    id_categoria INT,
    id_usuario INT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

ALTER TABLE Videojuego
ADD CONSTRAINT chk_stock_no_negativo CHECK (stock >= 0);


-- Tabla de Carritos
CREATE TABLE Carrito (
    id_carrito INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo',
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Tabla de Detalles del Carrito
CREATE TABLE Carrito_Detalle (
    id_detalle INT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_videojuego INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario INT NOT NULL,
    FOREIGN KEY (id_carrito) REFERENCES Carrito(id_carrito),
    FOREIGN KEY (id_videojuego) REFERENCES Videojuego(id_videojuego)
);

-- Tabla de Compras
CREATE TABLE Compra (
    id_compra INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    medio_de_pago VARCHAR(50) NOT NULL,
    precio_total INT NOT NULL,
    boleta_factura VARCHAR(100),
    fecha_compra DATE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Tabla de Detalles de Compra
CREATE TABLE Compra_Detalle (
    id_detalle_compra INT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_videojuego INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario INT NOT NULL,
    FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
    FOREIGN KEY (id_videojuego) REFERENCES Videojuego(id_videojuego)
);

-- Tabla de Valoraciones
CREATE TABLE Valoracion (
    id_valoracion INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_videojuego INT NOT NULL,
    estrellas INT NOT NULL CHECK (estrellas BETWEEN 1 AND 5),
    comentario VARCHAR(100),
    restricciones VARCHAR(100),
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_videojuego) REFERENCES Videojuego(id_videojuego),
    UNIQUE (id_usuario, id_videojuego)
);

-- Tabla de Rankings
CREATE TABLE Ranking (
    id_ranking INT PRIMARY KEY,
    tipo_de_ranking VARCHAR(50) NOT NULL,
    id_videojuego INT NOT NULL,
    puntuacion_promedio NUMERIC(3,1),
    FOREIGN KEY (id_videojuego) REFERENCES Videojuego(id_videojuego)
);

-- Tabla de Lista de Deseos
CREATE TABLE Lista_Deseos (
    id_lista INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_videojuego INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_videojuego) REFERENCES Videojuego(id_videojuego),
    UNIQUE (id_usuario, id_videojuego)
);

CREATE TABLE Auditoria_Videojuego (
    id_auditoria SERIAL PRIMARY KEY,
    id_videojuego INT,
    nombre_videojuego VARCHAR(100),
    id_usuario INT,
    accion VARCHAR(20), -- 'INSERT', 'UPDATE', 'DELETE'
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Auditoria_Stock (
    id_auditoria SERIAL PRIMARY KEY,
    id_videojuego INT,
    nombre_videojuego VARCHAR(100),
    stock_anterior INT,
    stock_nuevo INT,
    accion VARCHAR(10),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ============================
-- CREATE DE VIEW
-- ============================

CREATE VIEW ranking_mas_vendidos AS
SELECT 
    v.id_videojuego,
    v.nombre_videojuego,
    SUM(cd.cantidad) AS total_vendidos
FROM 
    compra_detalle cd
JOIN 
    videojuego v ON cd.id_videojuego = v.id_videojuego
GROUP BY 
    v.id_videojuego, v.nombre_videojuego
ORDER BY 
    total_vendidos DESC;

CREATE VIEW ranking_mas_deseados AS
SELECT v.id_videojuego, v.nombre_videojuego, COUNT(ld.id_lista) as total_deseado
FROM videojuego v
LEFT JOIN lista_deseos ld ON v.id_videojuego = ld.id_videojuego
GROUP BY v.id_videojuego, v.nombre_videojuego
ORDER BY total_deseado DESC;

-- ========================================
-- TRIGGER
-- ========================================

--Función que valida el stock
CREATE OR REPLACE FUNCTION validar_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INT;
BEGIN
    -- Buscar el stock actual del videojuego que se quiere comprar
    SELECT stock INTO stock_actual
    FROM Videojuego
    WHERE id_videojuego = NEW.id_videojuego;

    -- Verificar si existe
    IF stock_actual IS NULL THEN
        RAISE EXCEPTION 'El videojuego con ID % no existe.', NEW.id_videojuego;
    END IF;

    -- Validar si hay stock suficiente
    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'No hay stock suficiente para el videojuego con ID % (stock actual: %, cantidad pedida: %)',
            NEW.id_videojuego, stock_actual, NEW.cantidad;
    END IF;

    -- Si todo bien, continuar con el insert
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger que usa la función
CREATE TRIGGER trigger_validar_stock
BEFORE INSERT ON Compra_Detalle
FOR EACH ROW
EXECUTE FUNCTION validar_stock();

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION limpiar_carrito_post_compra(uid INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Carrito_Detalle
    WHERE id_carrito IN (SELECT id_carrito FROM Carrito WHERE id_usuario = uid);
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION descontar_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Videojuego
    SET stock = stock - NEW.cantidad
    WHERE id_videojuego = NEW.id_videojuego;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON Compra_Detalle
FOR EACH ROW
EXECUTE FUNCTION descontar_stock();

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION reporte_ventas_usuario(uid INT)
RETURNS TABLE (
    nombre_videojuego VARCHAR,
    fecha_compra DATE,
    cantidad INT,
    precio_unitario INT,
    total INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.nombre_videojuego,
        c.fecha_compra,
        cd.cantidad,
        cd.precio_unitario,
        cd.cantidad * cd.precio_unitario
    FROM Compra c
    JOIN Compra_Detalle cd ON c.id_compra = cd.id_compra
    JOIN Videojuego v ON v.id_videojuego = cd.id_videojuego
    WHERE c.id_usuario = uid
    ORDER BY c.fecha_compra DESC;
END;
$$;

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION registrar_auditoria_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Auditoria_Videojuego (
        id_videojuego,
        nombre_videojuego,
        id_usuario,
        accion
    ) VALUES (
        NEW.id_videojuego,
        NEW.nombre_videojuego,
        NEW.id_usuario,
        'INSERT'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_insert
AFTER INSERT ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_insert();

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION auditar_actualizacion_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.stock IS DISTINCT FROM NEW.stock THEN
        INSERT INTO Auditoria_Stock (
            id_videojuego,
            nombre_videojuego,
            stock_anterior,
            stock_nuevo,
            accion
        )
        VALUES (
            OLD.id_videojuego,
            OLD.nombre_videojuego,
            OLD.stock,
            NEW.stock,
            'UPDATE'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TRIGGER
-- ========================================

CREATE TRIGGER trg_auditoria_stock
AFTER UPDATE ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION auditar_actualizacion_stock();

CREATE OR REPLACE FUNCTION evitar_eliminar_videojuegos_comprados()
RETURNS TRIGGER AS $$
DECLARE
    existe_compra INT;
BEGIN
    -- Verificar si existe al menos una compra asociada al videojuego
    SELECT COUNT(*) INTO existe_compra
    FROM Compra_Detalle
    WHERE id_videojuego = OLD.id_videojuego;

    -- Si existe una compra, lanzar un error y evitar el DELETE
    IF existe_compra > 0 THEN
        RAISE EXCEPTION 'Operación bloqueada: el videojuego con ID % ya ha sido comprado.', OLD.id_videojuego;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_evitar_delete_videojuegos_comprados
BEFORE DELETE ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION evitar_eliminar_videojuegos_comprados();

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE PROCEDURE actualizar_precio_categoria(
    nombre_categoria_param VARCHAR,
    porcentaje_aumento NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Videojuego
    SET precio = precio + (precio * (porcentaje_aumento / 100))
    WHERE id_categoria = (
        SELECT id_categoria
        FROM Categoria
        WHERE LOWER(nombre_categoria) = LOWER(nombre_categoria_param)
    );
END;
$$;

-- ========================================
-- TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION reporte_ventas_usuario(uid INT)
RETURNS TABLE (
    nombre_videojuego VARCHAR,
    fecha_compra DATE,
    cantidad INT,
    precio_unitario INT,
    total INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.nombre_videojuego,
        c.fecha_compra,
        cd.cantidad,
        cd.precio_unitario,
        cd.cantidad * cd.precio_unitario
    FROM Compra c
    JOIN Compra_Detalle cd ON c.id_compra = cd.id_compra
    JOIN Videojuego v ON v.id_videojuego = cd.id_videojuego
    WHERE c.id_usuario = uid
    ORDER BY c.fecha_compra DESC;
END;
$$;
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

--1

INSERT INTO Usuario (id_usuario, nombre_usuario, ubicacion_usuario, contraseña, correo, id_rol) VALUES
(7, 'Pedro Garcia', 'Chile', 'admin123', 'pedro.garcia@mail.cl', 3)

--2

INSERT INTO Usuario (id_usuario, nombre_usuario, ubicacion_usuario, contraseña, correo, id_rol) VALUES
(8, 'maria Garcia', 'Chile', 'juana123', null , 2)

--3

INSERT INTO Usuario (id_usuario, nombre_usuario, ubicacion_usuario, contraseña, correo, id_rol) VALUES
(8, 'juana Garcia', 'Chile', 'juana123', 'juana.garcia@mail.cl', 99)

--4

INSERT INTO Usuario (id_usuario, nombre_usuario, ubicacion_usuario, contraseña, correo, id_rol)
VALUES (8, 'Camila Rojas', 'Chile', 'camila123', 'camila.rojas@mail.cl', 2);

--5

INSERT INTO Videojuego (id_videojuego, nombre_videojuego, descripcion, precio, stock, url_imagen, id_categoria, id_usuario)
VALUES (7, 'Zelda', 'Juego con error de stock', 25000, -3, 'urlvalida.com', 2, 1);

--6

INSERT INTO Videojuego (id_videojuego, nombre_videojuego, descripcion, precio, stock, url_imagen, id_categoria, id_usuario)
VALUES (7, 'Zelda', 'Intento con categoría inexistente', 25000, 5, 'urlvalida.com', 9, 1);

--7

INSERT INTO Videojuego (id_videojuego, nombre_videojuego, descripcion, precio, stock, url_imagen, id_categoria, id_usuario)
VALUES (7, 'Zelda', 'Aventura legendaria', 25000, 5, 'urlvalida.com', 2, 7);

--8

UPDATE Videojuego
SET precio = 30000,
    stock = 10,
    url_imagen = 'zelda_nueva.com'
WHERE nombre_videojuego = 'Zelda' AND id_usuario = 7;

--9

INSERT INTO lista_deseados (id_lista, id_usuario, id_videojuego)
VALUES (8, 8, 7);

--10

INSERT INTO lista_deseados (id_lista, id_usuario, id_videojuego)
VALUES (9, 8, 7);


--11

SELECT v.id_videojuego, v.nombre_videojuego, v.precio, v.url_imagen
FROM lista_deseados ld
JOIN videojuego v ON ld.id_videojuego = v.id_videojuego
WHERE ld.id_usuario = 8;

--12

INSERT INTO Carrito (id_carrito, id_usuario, estado)
VALUES (6, 8, 'activo');

--13

SELECT id_carrito 
FROM Carrito 
WHERE id_usuario = 8;

--14

INSERT INTO Carrito_Detalle (id_detalle, id_carrito, id_videojuego, cantidad, precio_unitario)
VALUES (7, 6, 7, 1, 30000);

SELECT 
    v.nombre_videojuego,
    cd.cantidad,
    cd.precio_unitario,
    (cd.cantidad * cd.precio_unitario) AS subtotal
FROM Carrito c
JOIN Carrito_Detalle cd ON c.id_carrito = cd.id_carrito
JOIN Videojuego v ON cd.id_videojuego = v.id_videojuego
WHERE c.id_usuario = 8;

SELECT SUM(cd.cantidad * cd.precio_unitario) AS total_a_pagar
FROM Carrito c
JOIN Carrito_Detalle cd ON c.id_carrito = cd.id_carrito
WHERE c.id_usuario = 8;

--15

DELETE FROM Carrito_Detalle
WHERE id_carrito = 6 AND id_videojuego = 7;

--16

INSERT INTO Carrito_Detalle (id_detalle, id_carrito, id_videojuego, cantidad, precio_unitario)
VALUES (7, 6, 7, 1, 30000);

--17

SELECT stock FROM Videojuego WHERE id_videojuego = 7;
SELECT id_carrito FROM Carrito WHERE id_usuario = 8 AND estado = 'activo';
SELECT precio FROM Videojuego WHERE id_videojuego = 7;

INSERT INTO Compra_Detalle (id_detalle_compra, id_compra, id_videojuego, cantidad, precio_unitario)
VALUES (7, 6, 7, 11, 30000);

--18

INSERT INTO Videojuego (id_videojuego, nombre_videojuego, descripcion, precio, stock, url_imagen, id_categoria, id_usuario)
VALUES (8, 'Minecraft', 'Juego sandbox', 30000, 0, 'minecraft.jpg', 3, 7);

INSERT INTO Carrito_Detalle (id_detalle, id_carrito, id_videojuego, cantidad, precio_unitario)
VALUES (8, 6, 8, 1, 30000);

INSERT INTO Compra_Detalle (id_detalle_compra, id_compra, id_videojuego, cantidad, precio_unitario)
VALUES (9, 6, 8, 1, 30000);

--19

SELECT * FROM Carrito_Detalle cd
JOIN Carrito c ON c.id_carrito = cd.id_carrito
WHERE c.id_usuario = 8;

INSERT INTO Compra (id_compra, id_usuario, medio_de_pago, precio_total, boleta_factura, fecha_compra)
VALUES (6, 8, 'Tarjeta de crédito', 30000, 'B001-0007', CURRENT_DATE);

INSERT INTO Compra_Detalle (id_detalle_compra, id_compra, id_videojuego, cantidad, precio_unitario)
VALUES (7, 6, 7, 1, 30000);

--20

INSERT INTO Compra (id_usuario, medio_de_pago, precio_total, boleta_factura, fecha_compra)
VALUES (8, 'monedas de oro', 30000, 'B001-0009', CURRENT_DATE);

--21

INSERT INTO Valoracion (id_valoracion,id_usuario, id_videojuego, estrellas,comentario)
VALUES (6,8, 7, 4,null);

--22

INSERT INTO Valoracion (id_valoracion,id_usuario, id_videojuego, estrellas,comentario)
VALUES (7,8, 7, 5,null);

--23

SELECT v.nombre_videojuego,COUNT(cd.id_videojuego) AS total_ventas
FROM Compra_Detalle cd
JOIN Videojuego v ON v.id_videojuego = cd.id_videojuego
GROUP BY cd.id_videojuego, v.nombre_videojuego
ORDER BY total_ventas DESC
LIMIT 3;

--24

SELECT id_videojuego, COUNT(*) AS cantidad_deseos
FROM lista_deseados
GROUP BY id_videojuego
ORDER BY cantidad_deseos DESC;

--25

SELECT v.id_videojuego, v.nombre_videojuego, v.precio, v.stock, u.ubicacion_usuario
FROM Videojuego v
JOIN Usuario u ON v.id_usuario = u.id_usuario
WHERE u.ubicacion_usuario = 'Santiago';

UPDATE Usuario
SET ubicacion_usuario = 'Santiago'
WHERE id_usuario = 7;

--26

SELECT id_videojuego, COUNT(*) AS total_ventas 
FROM compra_detalle 
GROUP BY id_videojuego 
ORDER BY total_ventas DESC;

--27

SELECT v.id_videojuego,v.nombre_videojuego,v.precio,v.stock,v.url_imagen,u.ubicacion_usuario AS ubicacion_publicacion
FROM Videojuego v
JOIN Usuario u ON v.id_usuario = u.id_usuario
WHERE u.ubicacion_usuario = 'Santiago';

--28

INSERT INTO Videojuego (id_videojuego, nombre_videojuego,descripcion,precio,stock,url_imagen,id_categoria,id_usuario)
VALUES (9,'Hades II','Acción roguelike mitológico',28000,20,'hades2.jpg',1,7);

SELECT * FROM Auditoria_Videojuego;

--29

UPDATE Videojuego
SET stock = stock - 1
WHERE id_videojuego = 7;

SELECT * FROM Auditoria_Stock;

--30

DELETE FROM Videojuego WHERE id_videojuego = 9;

SELECT v.id_videojuego,v.nombre_videojuego,COUNT(cd.id_detalle_compra) AS cantidad_veces_comprado
FROM Videojuego v
JOIN Compra_Detalle cd ON v.id_videojuego = cd.id_videojuego
GROUP BY v.id_videojuego, v.nombre_videojuego
HAVING COUNT(cd.id_detalle_compra) > 0;

--31

SELECT v.id_videojuego, v.nombre_videojuego, v.precio, c.nombre_categoria
FROM Videojuego v
JOIN Categoria c ON v.id_categoria = c.id_categoria
WHERE LOWER(c.nombre_categoria) = 'aventura';

CALL actualizar_precio_categoria('Aventura', 10);

--32
SELECT * FROM reporte_ventas_usuario(8);
