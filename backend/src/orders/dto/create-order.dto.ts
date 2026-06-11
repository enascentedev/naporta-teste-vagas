import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsDateString,
  IsEmail,
  IsEnum,
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  ValidateNested,
} from 'class-validator';
import { OrderStatus } from '../../generated/prisma/client';

export class OrderItemDto {
  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  price: number;
}

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty()
  orderNumber: string;

  @IsDateString()
  deliveryForecast: string;

  @IsString()
  @IsNotEmpty()
  customerName: string;

  @IsString()
  @IsNotEmpty()
  customerDocument: string;

  @IsOptional()
  @IsEmail()
  customerEmail?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  customerPhone?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  originAddress?: string;

  @IsOptional()
  @IsLatitude()
  originLat?: number;

  @IsOptional()
  @IsLongitude()
  originLng?: number;

  @IsString()
  @IsNotEmpty()
  deliveryAddress: string;

  @IsOptional()
  @IsLatitude()
  deliveryLat?: number;

  @IsOptional()
  @IsLongitude()
  deliveryLng?: number;

  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[];
}
