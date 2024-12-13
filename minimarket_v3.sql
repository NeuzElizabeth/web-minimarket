create table if not exists categoria
(
    id_categoria int auto_increment
        primary key,
    nombre       varchar(50) not null,
    descripcion  text        null,
    constraint uk_categoria_nombre
        unique (nombre)
);

create table if not exists cliente
(
    id_cliente         int auto_increment
        primary key,
    nombre             varchar(100)                           not null,
    apellido           varchar(100)                           not null,
    dni                varchar(20)                            null,
    telefono           varchar(20)                            null,
    email              varchar(100)                           not null,
    direccion          text                                   null,
    password           varchar(255)                           not null,
    fecha_registro     timestamp  default current_timestamp() not null,
    ultimo_login       timestamp                              null,
    is_active          tinyint(1) default 1                   null,
    token_recuperacion varchar(100)                           null,
    constraint uk_cliente_dni
        unique (dni),
    constraint uk_cliente_email
        unique (email)
);

create table if not exists carrito
(
    id_carrito          int auto_increment
        primary key,
    id_cliente          int                                   not null,
    fecha_creacion      timestamp default current_timestamp() null,
    ultima_modificacion timestamp default current_timestamp() null on update current_timestamp(),
    constraint fk_carrito_cliente
        foreign key (id_cliente) references cliente (id_cliente)
);

create table if not exists metodo_pago
(
    id_metodo_pago int auto_increment
        primary key,
    nombre         varchar(50)          not null,
    descripcion    text                 null,
    instrucciones  text                 null,
    is_active      tinyint(1) default 1 null
);

create index if not exists idx_metodo_pago_active
    on metodo_pago (is_active);

create index if not exists idx_metodo_pago_nombre
    on metodo_pago (nombre);

create table if not exists producto
(
    id_producto          int auto_increment
        primary key,
    id_categoria         int                          not null,
    nombre               varchar(100)                 not null,
    slug                 varchar(150)                 not null,
    descripcion          text                         null,
    precio               decimal(10, 2)               not null,
    precio_oferta        decimal(10, 2)               null,
    stock                int        default 0         null,
    codigo_barras        varchar(50)                  null,
    imagen_url           varchar(255)                 null,
    imagenes_adicionales longtext collate utf8mb4_bin null
        check (json_valid(`imagenes_adicionales`)),
    meta_descripcion     varchar(160)                 null,
    meta_keywords        varchar(255)                 null,
    destacado            tinyint(1) default 0         null,
    is_active            tinyint(1) default 1         null,
    constraint uk_producto_codigo
        unique (codigo_barras),
    constraint uk_producto_slug
        unique (slug),
    constraint fk_producto_categoria
        foreign key (id_categoria) references categoria (id_categoria)
);

create table if not exists carrito_item
(
    id_carrito_item int auto_increment
        primary key,
    id_carrito      int            not null,
    id_producto     int            not null,
    cantidad        int            not null,
    precio_unitario decimal(10, 2) not null,
    subtotal        decimal(10, 2) not null,
    constraint fk_carrito_item_carrito
        foreign key (id_carrito) references carrito (id_carrito),
    constraint fk_carrito_item_producto
        foreign key (id_producto) references producto (id_producto)
);

create index if not exists idx_producto_categoria
    on producto (id_categoria);

create index if not exists idx_producto_destacado
    on producto (destacado);

create index if not exists idx_producto_precio
    on producto (precio);

create table if not exists proveedor
(
    id_proveedor int auto_increment
        primary key,
    nombre       varchar(100) not null,
    ruc          varchar(20)  not null,
    telefono     varchar(20)  null,
    email        varchar(100) null,
    direccion    text         null,
    constraint uk_proveedor_ruc
        unique (ruc)
);

create table if not exists usuario
(
    id_usuario   int auto_increment
        primary key,
    nombre       varchar(100)                           not null,
    apellido     varchar(100)                           not null,
    dni          varchar(20)                            not null,
    telefono     varchar(20)                            null,
    email        varchar(100)                           not null,
    contraseña   varchar(255)                           not null,
    tipo_usuario enum ('administrador', 'empleado')     not null,
    is_active    tinyint(1) default 1                   null,
    created_at   timestamp  default current_timestamp() null,
    constraint uk_usuario_dni
        unique (dni),
    constraint uk_usuario_email
        unique (email)
);

create table if not exists compra
(
    id_compra    int auto_increment
        primary key,
    id_proveedor int                                                                       not null,
    id_usuario   int                                                                       not null,
    fecha_compra timestamp                                     default current_timestamp() null,
    total        decimal(10, 2)                                                            not null,
    estado       enum ('pendiente', 'completada', 'cancelada') default 'pendiente'         null,
    constraint fk_compra_proveedor
        foreign key (id_proveedor) references proveedor (id_proveedor),
    constraint fk_compra_usuario
        foreign key (id_usuario) references usuario (id_usuario)
);

create index if not exists idx_compra_fecha
    on compra (fecha_compra);

create table if not exists detalle_compra
(
    id_detalle_compra int auto_increment
        primary key,
    id_compra         int            not null,
    id_producto       int            not null,
    cantidad          int            not null,
    precio_unitario   decimal(10, 2) not null,
    subtotal          decimal(10, 2) not null,
    constraint fk_detalle_compra_compra
        foreign key (id_compra) references compra (id_compra),
    constraint fk_detalle_compra_producto
        foreign key (id_producto) references producto (id_producto)
);

create table if not exists venta
(
    id_venta           int auto_increment
        primary key,
    id_cliente         int                                                                   null,
    id_usuario         int                                                                   not null,
    metodo_pago_id     int                                                                   null,
    fecha_venta        timestamp                                 default current_timestamp() null,
    tipo_comprobante   enum ('boleta', 'factura')                                            not null,
    numero_comprobante varchar(50)                                                           not null,
    total              decimal(10, 2)                                                        not null,
    estado             enum ('completada', 'anulada')            default 'completada'        null,
    estado_pago        enum ('pendiente', 'pagado', 'rechazado') default 'pendiente'         null,
    referencia_pago    varchar(100)                                                          null,
    direccion_envio    text                                                                  null,
    costo_envio        decimal(10, 2)                            default 0.00                null,
    notas              text                                                                  null,
    constraint uk_venta_comprobante
        unique (numero_comprobante),
    constraint fk_venta_cliente
        foreign key (id_cliente) references cliente (id_cliente),
    constraint fk_venta_metodo_pago
        foreign key (metodo_pago_id) references metodo_pago (id_metodo_pago),
    constraint fk_venta_usuario
        foreign key (id_usuario) references usuario (id_usuario)
);

create table if not exists detalle_venta
(
    id_detalle_venta int auto_increment
        primary key,
    id_venta         int            not null,
    id_producto      int            not null,
    cantidad         int            not null,
    precio_unitario  decimal(10, 2) not null,
    subtotal         decimal(10, 2) not null,
    constraint fk_detalle_venta_producto
        foreign key (id_producto) references producto (id_producto),
    constraint fk_detalle_venta_venta
        foreign key (id_venta) references venta (id_venta)
);

create table if not exists seguimiento_pedido
(
    id_seguimiento      int auto_increment
        primary key,
    id_venta            int                                                                                                                 not null,
    estado              enum ('pendiente', 'confirmado', 'en_preparacion', 'enviado', 'entregado', 'cancelado') default 'pendiente'         null,
    comentario          text                                                                                                                null,
    fecha_actualizacion timestamp                                                                               default current_timestamp() null,
    constraint fk_seguimiento_venta
        foreign key (id_venta) references venta (id_venta)
);

create index if not exists idx_venta_estado_pago
    on venta (estado_pago);

create index if not exists idx_venta_fecha
    on venta (fecha_venta);

