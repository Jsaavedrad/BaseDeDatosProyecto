PROYECTO BASE DE DATOS

Este proyecto tuvo el fin de diseñar e implementar una base de datos para una plataforma de ventas de videojuegos en linea, esta se encuentra orientada para las tiendas pequeñas las cuales no cuentan con los recuros para desarrollar su propio sistema. Esto surge por la necesidad detectada por la empresa DEBEDE, esta busca ofrecer un espacio donde las tiendas puedan subir, organizar y vender sus productos de manera mas accesible.

Intrucciones de uso

Esta base de datos fue diseñada para integrarse en una futura aplicacion web, las funcionalidades principales que permite esta son las siguientes:
  - Registro y login de usuarios, con las diferencias de roles y permisos
  - Administracion de videojuegos, incluye el stock de estos, la categoria correspondiente de cada uno, sus descripciones y URL de imagen.
  - Gestion de compras, el carrito para previzualizar lo que piensa comprar, la cantidad, su medio de pago y la generacion de una boleta.
  - Valoracion de productos, este permite que el usuario califique el producto con estrellas (1 a 5 estrellas) y comentarios.
  - Creacion de lista de deseos, para almacenar los videojuegos que el usuario guste.
  - Generacion de rankings, mostrando cuales son los mas vendidos o los mas deseados.
  - Filtracion por ubicacion, para la adaptacion de monedas y  adaptacion de rankings dependiendo de la zona geografica.

Esta base de dato tuvo una implementacion en SQL y se encuentra normalizada para evitar redundancias, facilitar futuras actualizaciones y para asegurar la integridad de la informacion de datos. Todas las tablas fueron definidas con sus claves primarias y foraneas, respetando los principios del modelo relacional.

Equipo de desarrollo

  - Analizar de requerimiento: Interpretacion detallada de las funcionalidades solicitadas por la empresa DEBEDE.
  - Modelo entidad-relacion (MER): Se diseño el esquema conceptual con entidades, atributos y relaciones.
  - Modelo relacional (MR): El mer fue transformado a un modelo logico, definiendo las claves primarias y foraneas.
  - Implementacion en SQL: Se construyo la base de datos respetando las reglas de integridad referencial.
    
