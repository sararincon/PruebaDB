-- Borrando base datos 
DROP DATABASE biblioteca;
-- Creando base de datos 
CREATE DATABASE biblioteca;

\c biblioteca
--Creación de la tabla socio
CREATE TABLE socio (
    rut VARCHAR(100),
    nombre VARCHAR(100),
    apellido VARCHAR (100),
    direccion VARCHAR (250),
    telefono VARCHAR (250),
    PRIMARY KEY (rut)
);
--Creación de la tabla libro
CREATE TABLE libro (
    ISBN VARCHAR (250),
    titulo VARCHAR (250),
    pagina INT,
    PRIMARY KEY (ISBN)
);
--Creación de la tabla autor
CREATE TABLE autor (
    id INT,
    nombre VARCHAR(100),
    apellido VARCHAR (100),
    fecha_nacimiento INT, 
    fecha_defuncion INT,
    PRIMARY KEY (id)
); 


--Creación de la tabla socio historial_prestamo
CREATE TABLE historial_prestamo(
    id INT,
    fecha_prestamo DATE, 
    fecha_devolucion DATE,
    socio_rut VARCHAR (100),
    libro_isbn VARCHAR (100),
    PRIMARY KEY (id),
    FOREIGN KEY (libro_isbn) REFERENCES libro(ISBN),
    FOREIGN KEY (socio_rut) REFERENCES socio(rut)
);

--Creación de Tablas tipo_autor

 CREATE TABLE tipo_autor (
        id_tipo_autor INT,
        tipo_autor VARCHAR(50),
        PRIMARY KEY (id_tipo_autor)
    );

--Creación de la tabla autor_libro
CREATE TABLE autor_libro (
    id INT, 
    libro_isbn VARCHAR (100),
    autor_id INT,
    tipo_autor INT,
    PRIMARY KEY (id),
    FOREIGN KEY (libro_isbn) REFERENCES libro(ISBN),
    FOREIGN KEY (autor_id) REFERENCES autor(id),
    FOREIGN KEY (tipo_autor) REFERENCES tipo_autor(id_tipo_autor)
); 


--Llenando tablas 
\copy socio FROM 'socios.csv' csv header;

\copy libro FROM 'libros.csv' csv header;

\copy autor FROM 'autores.csv' csv header;

\copy tipo_autor FROM 'tipoAutor.csv' csv header;

\copy autor_libro FROM 'autorLibro.csv' csv header;

\copy historial_prestamo FROM 'prestamos.csv' csv header;


-- CONSULTAS
-- a. Mostrar todos los libros que posean menos de 300 páginas.
SELECT * FROM libro l WHERE l.pagina <= 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT * FROM autor a WHERE a.fecha_nacimiento > 1970;

-- c. ¿Cuál es el libro más solicitado?.

SELECT l.isbn, l.titulo, l.pagina, count(*) AS freq FROM historial_prestamo hp
JOIN libro l ON l.isbn = hp.libro_isbn
GROUP BY l.isbn, l.titulo, l.pagina
HAVING count(*) = (
    SELECT MAX(freq) FROM (SELECT libro_isbn, COUNT(*) AS freq FROM historial_prestamo GROUP BY libro_isbn) historial_prestamo
);

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto 
-- debería pagar cada usuario que entregue el préstamo después de 7 días.

SELECT s.rut, s.nombre, s.apellido,
DATE_PART('day', fecha_devolucion::timestamp - fecha_prestamo::timestamp) as dias_atrasos,
(DATE_PART('day', fecha_devolucion::timestamp - fecha_prestamo::timestamp) - 7) * 100 as deuda
FROM historial_prestamo hp 
JOIN socio s ON s.rut = hp.socio_rut