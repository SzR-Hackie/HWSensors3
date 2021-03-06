/*
 *  utils.h
 *  HWSensors
 *
 *  Created by Kozel Rogati on 05.04.11.
 *  Copyright 2011 mozodojo. All rights reserved.
 *
 */

inline UInt16 swap_value(UInt16 value)
{
	return ((value & 0xff00) >> 8) | ((value & 0xff) << 8);
}
//we will use fpNM for voltages taking into account that input data in milliVolts while output in Volts
inline UInt16 encode_fp2e(UInt16 value)
{
    UInt32 tmp = value;
    tmp = (tmp << 14) / 1000;
    value = (UInt16)(tmp & 0xffff);
    return swap_value(value);
}

inline UInt16 encode_sp4b(UInt16 value)
{
  UInt32 tmp = (value < 0x8000)?value:(~value);
  tmp = (tmp << 11) / 1000;
  value = (UInt16)(tmp & 0xffff);
  return swap_value(value);
}


/*
inline UInt16 encode_fp3d(UInt16 value)
{
  UInt32 tmp = value;
  tmp = (tmp << 13) / 1000;
  value = (UInt16)(tmp & 0xffff);
  return swap_value(value);
}

inline UInt16 encode_fp4c(UInt16 value)
{
	
    UInt32 tmp = value;
    tmp = (tmp << 12) / 1000;
    value = (UInt16)(tmp & 0xffff);
    return swap_value(value);
}

inline UInt16 encode_fp5b(UInt16 value)
{
  UInt32 tmp = value;
  tmp = (tmp << 11) / 1000;
  value = (UInt16)(tmp & 0xffff);
  return swap_value(value);
}

inline UInt16 encode_sp5a(UInt16 value)
{
  UInt32 tmp = (value < 0x8000)?value:(~value);
  tmp = (tmp << 10) / 1000;
  tmp = tmp & 0x7fff;
  if (value > 0x8000) {
    value = (UInt16)tmp | 0x8000;
  } else {
    value = (UInt16)tmp;
  }

  return swap_value(value);
}
*/
inline UInt16 encode_fpe2(UInt16 value)
{
	return swap_value(value << 2);
}

inline UInt16 decode_fpe2(UInt16 value)
{
	return (swap_value(value) >> 2);
}

inline bool process_sensor_entry(OSObject *object, OSString **name, long *Ri, long *Rf, long *Vf)
{
  *Rf=1;
  *Ri=0;
  *Vf=0;
  if ((*name = OSDynamicCast(OSString, object))) {
    return true;
  }
  else if (OSDictionary *dictionary = OSDynamicCast(OSDictionary, object))
    if ((*name = OSDynamicCast(OSString, dictionary->getObject("Name")))) {
      if (OSNumber *number = OSDynamicCast(OSNumber, dictionary->getObject("VRef")))
        *Vf = (long)number->unsigned64BitValue() ;
      
      if (OSNumber *number = OSDynamicCast(OSNumber, dictionary->getObject("Ri")))
        *Ri = (long)number->unsigned64BitValue();
      
      if (OSNumber *number = OSDynamicCast(OSNumber, dictionary->getObject("Rf"))) {
        *Rf = (long)number->unsigned64BitValue() ;
        if (*Rf == 0) {
          *Rf = 1;
        }
      }
      
      return true;
    }
  
  return false;
}
