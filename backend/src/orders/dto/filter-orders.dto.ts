import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  Validate,
  type ValidationArguments,
  ValidatorConstraint,
  type ValidatorConstraintInterface,
} from 'class-validator';
import { OrderStatus } from '../../generated/prisma/client';

@ValidatorConstraint({ name: 'isValidDateRange', async: false })
class IsValidDateRangeConstraint implements ValidatorConstraintInterface {
  validate(endDate: unknown, args: ValidationArguments): boolean {
    const { startDate } = args.object as FilterOrdersDto;
    if (typeof startDate !== 'string' || typeof endDate !== 'string') {
      return true;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return true;
    }
    if (/^\d{4}-\d{2}-\d{2}$/.test(endDate)) {
      end.setUTCHours(23, 59, 59, 999);
    }

    return start <= end;
  }

  defaultMessage(): string {
    return 'endDate deve ser igual ou posterior a startDate';
  }
}

export class FilterOrdersDto {
  @IsOptional()
  @IsString()
  orderNumber?: string;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  @Validate(IsValidDateRangeConstraint)
  endDate?: string;

  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 10;
}
