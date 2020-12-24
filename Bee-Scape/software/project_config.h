/* Project name project configuration file	*/

#ifndef _project_config_h_
#define _project_config_h_

#include "../usb_kb1/GenericMacros.h"
#include "../usb_kb1/GenericTypeDefs.h"
#include "../usb_kb1/HID.h"
#include "../usb_kb1/MAX3421E.h"
#include "../usb_kb1/transfer.h"
#include "../usb_kb1/usb_ch9.h"
#include "../usb_kb1/USB.h"

/* USB constants */
/* time in milliseconds */
#define USB_SETTLE_TIME 					200         //USB settle after reset
#define USB_XFER_TIMEOUT					5000        //USB transfer timeout

#define USB_NAK_LIMIT 200
#define USB_RETRY_LIMIT 3

#endif // _project_config_h
