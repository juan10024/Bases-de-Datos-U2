CREATE TYPE order_status_type AS ENUM (
    'CREATED',
    'APPROVED',
    'INVOICED',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED'
);

CREATE TYPE payment_type AS ENUM (
    'CREDIT_CARD',
    'DEBIT_CARD',
    'VOUCHER',
    'BOLETO',
    'PIX'
);