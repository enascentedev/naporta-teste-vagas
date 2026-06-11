-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "customer_email" TEXT,
ADD COLUMN     "customer_phone" TEXT,
ADD COLUMN     "delivery_lat" DOUBLE PRECISION,
ADD COLUMN     "delivery_lng" DOUBLE PRECISION,
ADD COLUMN     "origin_address" TEXT,
ADD COLUMN     "origin_lat" DOUBLE PRECISION,
ADD COLUMN     "origin_lng" DOUBLE PRECISION;
