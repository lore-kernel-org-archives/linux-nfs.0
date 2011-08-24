Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44903 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547Ab1HXWqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 18:46:13 -0400
Date: Thu, 25 Aug 2011 08:46:01 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: PATCH/RFC: remove state from struct nfs4_state
Message-ID: <20110825084601.4d8fcdee@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi,
 I've been looking at the error handling code in nfs4 and noticed that
 'state' in 'struct nfs4_exception' is never set (except to NULL).
 Looking back through history, it looks like it never has been.

 So either it should be set and the code is wrong somewhere, or it can be
 safely removed.  Unfortunately I cannot say which..

 So: In case you think it is correct to remove it - the patch is below.

Thanks,
NeilBrown


NFS: remove 'state' from 'struct nfs4_state'.

This field is never set and it appears that it never has been.
So just remove it.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1ec1a85..36639a0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -211,7 +211,6 @@ struct nfs4_state {
 struct nfs4_exception {
 	long timeout;
 	int retry;
-	struct nfs4_state *state;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..8c99ee4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -257,7 +257,6 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_state *state = exception->state;
 	int ret = errorcode;
 
 	exception->retry = 0;
@@ -267,13 +266,8 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OPENMODE:
-			if (state == NULL)
-				break;
-			nfs4_schedule_stateid_recovery(server, state);
-			goto wait_on_recovery;
+			break;
 		case -NFS4ERR_EXPIRED:
-			if (state != NULL)
-				nfs4_schedule_stateid_recovery(server, state);
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
diff --git a/include/linux/configfs.h b/include/linux/configfs.h
index 3081c58..9723858 100644
--- a/include/linux/configfs.h
+++ b/include/linux/configfs.h
@@ -15,8 +15,8 @@
  *
  * You should have received a copy of the GNU General Public
  * License along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA.
+ * Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  *
  * Based on sysfs:
  * 	sysfs is Copyright (C) 2001, 2002, 2003 Patrick Mochel
diff --git a/include/linux/dca.h b/include/linux/dca.h
index d27a7a0..02d4764 100644
--- a/include/linux/dca.h
+++ b/include/linux/dca.h
@@ -12,8 +12,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * The full GNU General Public License is included in this distribution in the
  * file called COPYING.
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 65a2562..a7a9b43 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -11,8 +11,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * Author: Lucy Liu <lucy.liu@intel.com>
  */
diff --git a/include/linux/display.h b/include/linux/display.h
index 3bf70d6..3412709 100644
--- a/include/linux/display.h
+++ b/include/linux/display.h
@@ -15,7 +15,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 8fbf40e..b0bddd4 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -12,8 +12,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * The full GNU General Public License is included in this distribution in the
  * file called COPYING.
diff --git a/include/linux/dmar.h b/include/linux/dmar.h
index 7b776d7..d989fb6 100644
--- a/include/linux/dmar.h
+++ b/include/linux/dmar.h
@@ -11,8 +11,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * Copyright (C) Ashok Raj <ashok.raj@intel.com>
  * Copyright (C) Shaohua Li <shaohua.li@intel.com>
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index c4627cb..e59965d 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -15,7 +15,7 @@
 	You should have received a copy of the GNU General Public License
 	along with this program; if not, write to the
 	Free Software Foundation, Inc.,
-	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+	51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 /*
diff --git a/include/linux/hidraw.h b/include/linux/hidraw.h
index 4b88e69..ccfea00 100644
--- a/include/linux/hidraw.h
+++ b/include/linux/hidraw.h
@@ -12,7 +12,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #include <linux/hid.h>
diff --git a/include/linux/i2c/tps65010.h b/include/linux/i2c/tps65010.h
index 08aa922..07a9ad2 100644
--- a/include/linux/i2c/tps65010.h
+++ b/include/linux/i2c/tps65010.h
@@ -22,7 +22,7 @@
  *
  * You should have received a copy of the  GNU General Public License along
  * with this program; if not, write  to the Free Software Foundation, Inc.,
- * 675 Mass Ave, Cambridge, MA 02139, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_I2C_TPS65010_H
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index 9310c69..697066f 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -11,8 +11,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * Copyright (C) 2006-2008 Intel Corporation
  * Author: Ashok Raj <ashok.raj@intel.com>
diff --git a/include/linux/intel_mid_dma.h b/include/linux/intel_mid_dma.h
index 10496bd..40fdd99 100644
--- a/include/linux/intel_mid_dma.h
+++ b/include/linux/intel_mid_dma.h
@@ -16,7 +16,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
diff --git a/include/linux/ipmi.h b/include/linux/ipmi.h
index ca85cf8..4f1717c 100644
--- a/include/linux/ipmi.h
+++ b/include/linux/ipmi.h
@@ -28,7 +28,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_IPMI_H
diff --git a/include/linux/ipmi_msgdefs.h b/include/linux/ipmi_msgdefs.h
index df97e6e..d4b0bba 100644
--- a/include/linux/ipmi_msgdefs.h
+++ b/include/linux/ipmi_msgdefs.h
@@ -28,7 +28,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_IPMI_MSGDEFS_H
diff --git a/include/linux/ipmi_smi.h b/include/linux/ipmi_smi.h
index 204f9cd..85e2609 100644
--- a/include/linux/ipmi_smi.h
+++ b/include/linux/ipmi_smi.h
@@ -28,7 +28,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_IPMI_SMI_H
diff --git a/include/linux/mfd/pcf50633/backlight.h b/include/linux/mfd/pcf50633/backlight.h
index 83747e2..2e0fc62 100644
--- a/include/linux/mfd/pcf50633/backlight.h
+++ b/include/linux/mfd/pcf50633/backlight.h
@@ -9,7 +9,7 @@
  *
  *  You should have received a copy of the  GNU General Public License along
  *  with this program; if not, write  to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/nfc.h b/include/linux/nfc.h
index 330a4c5..6ad6da3 100644
--- a/include/linux/nfc.h
+++ b/include/linux/nfc.h
@@ -18,7 +18,7 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the
  * Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_NFC_H
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 33d9f51..b8a720b 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -14,7 +14,7 @@
  *
  * You should have received a copy of the GNU General Public License along
  * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/omapfb.h b/include/linux/omapfb.h
index c0b0187..94f48a8 100644
--- a/include/linux/omapfb.h
+++ b/include/linux/omapfb.h
@@ -18,7 +18,7 @@
  *
  * You should have received a copy of the GNU General Public License along
  * with this program; if not, write to the Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_OMAPFB_H__
diff --git a/include/linux/padata.h b/include/linux/padata.h
index 4633b2f..501c2bf 100644
--- a/include/linux/padata.h
+++ b/include/linux/padata.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef PADATA_H
diff --git a/include/linux/power/bq20z75.h b/include/linux/power/bq20z75.h
index 1398eb0..7dc9e51 100644
--- a/include/linux/power/bq20z75.h
+++ b/include/linux/power/bq20z75.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License along
  * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 #ifndef __LINUX_POWER_BQ20Z75_H_
diff --git a/include/linux/power/gpio-charger.h b/include/linux/power/gpio-charger.h
index de1dfe0..ad54842 100644
--- a/include/linux/power/gpio-charger.h
+++ b/include/linux/power/gpio-charger.h
@@ -8,7 +8,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/power/jz4740-battery.h b/include/linux/power/jz4740-battery.h
index 19c9610..b13eb5f 100644
--- a/include/linux/power/jz4740-battery.h
+++ b/include/linux/power/jz4740-battery.h
@@ -8,7 +8,7 @@
  *
  *  You should have received a copy of the  GNU General Public License along
  *  with this program; if not, write  to the Free Software Foundation, Inc.,
- *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/raid/pq.h b/include/linux/raid/pq.h
index 2b59cc8..207c1c9 100644
--- a/include/linux/raid/pq.h
+++ b/include/linux/raid/pq.h
@@ -4,9 +4,10 @@
  *
  *   This program is free software; you can redistribute it and/or modify
  *   it under the terms of the GNU General Public License as published by
- *   the Free Software Foundation, Inc., 53 Temple Place Ste 330,
- *   Boston MA 02111-1307, USA; either version 2 of the License, or
- *   (at your option) any later version; incorporated herein by reference.
+ *   the Free Software Foundation, Inc.,
+ *   51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA; either
+ *   version 2 of the License, or (at your option) any later version;
+ *   incorporated herein by reference.
  *
  * ----------------------------------------------------------------------- */
 
diff --git a/include/linux/rfkill-gpio.h b/include/linux/rfkill-gpio.h
index a175d05..77ce686 100644
--- a/include/linux/rfkill-gpio.h
+++ b/include/linux/rfkill-gpio.h
@@ -13,7 +13,7 @@
  *
  * You should have received a copy of the GNU General Public License along
  * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..4746368 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -15,7 +15,7 @@
 
   You should have received a copy of the GNU General Public License along with
   this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/include/linux/tboot.h b/include/linux/tboot.h
index 1dba6ee..9b92db8 100644
--- a/include/linux/tboot.h
+++ b/include/linux/tboot.h
@@ -16,7 +16,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index 7a2e910..5c25e33 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -11,8 +11,8 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * Author: Alexander Duyck <alexander.h.duyck@intel.com>
  */
diff --git a/include/linux/thermal.h b/include/linux/thermal.h
index 47b4a27..7e13288 100644
--- a/include/linux/thermal.h
+++ b/include/linux/thermal.h
@@ -17,7 +17,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
diff --git a/include/linux/timecompare.h b/include/linux/timecompare.h
index 546e223..e2fd5e1 100644
--- a/include/linux/timecompare.h
+++ b/include/linux/timecompare.h
@@ -42,7 +42,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  */
 #ifndef _LINUX_TIMECOMPARE_H
 #define _LINUX_TIMECOMPARE_H
diff --git a/include/linux/usb/intel_mid_otg.h b/include/linux/usb/intel_mid_otg.h
index a0ccf79..87d324c 100644
--- a/include/linux/usb/intel_mid_otg.h
+++ b/include/linux/usb/intel_mid_otg.h
@@ -13,7 +13,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/usb/langwell_otg.h b/include/linux/usb/langwell_otg.h
index 51f17b1..5d90ea1 100644
--- a/include/linux/usb/langwell_otg.h
+++ b/include/linux/usb/langwell_otg.h
@@ -13,7 +13,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/usb/langwell_udc.h b/include/linux/usb/langwell_udc.h
index 2d2d1bb..343e91f 100644
--- a/include/linux/usb/langwell_udc.h
+++ b/include/linux/usb/langwell_udc.h
@@ -13,7 +13,7 @@
  *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ * 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  */
 
diff --git a/include/linux/video_output.h b/include/linux/video_output.h
index ed5cdeb..bf8afb9 100644
--- a/include/linux/video_output.h
+++ b/include/linux/video_output.h
@@ -16,7 +16,7 @@
  *
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *  51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
