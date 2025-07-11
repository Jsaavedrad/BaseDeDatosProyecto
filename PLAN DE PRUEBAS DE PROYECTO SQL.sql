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
VALUES (8, 'Minecraft', 'Juego sandbox', 30000, 0, 'minecraft.jpg', 3, 1);

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