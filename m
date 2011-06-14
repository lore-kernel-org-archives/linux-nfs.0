Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37373 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab1FNVUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:20:25 -0400
Message-ID: <4DF7D092.5020405@panasas.com>
Date: Tue, 14 Jun 2011 17:20:18 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
CC: Boaz Harrosh <"Boaz Harrosh bharrosh"@panasas.com>
Subject: [PATCH 3/8] pnfs-obj: pnfs_osd_xdr: Remove dead code and cleanup
References: <4DF7CA2F.7030407@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Boaz Harrosh <Boaz Harrosh bharrosh@panasas.com>

* Some leftovers from ancient times.
* This file will only define common types and client API.
  Remove server from comments

Signed-off-by: Boaz Harrosh <Boaz Harrosh bharrosh@panasas.com>
---
 include/linux/pnfs_osd_xdr.h |   31 ++-----------------------------
 1 files changed, 2 insertions(+), 29 deletions(-)

diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 76efbdd..435dd5f 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -41,9 +41,6 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
-#include <scsi/osd_protocol.h>
-
-#define PNFS_OSD_OSDNAME_MAXSIZE 256
 
 /*
  * draft-ietf-nfsv4-minorversion-22
@@ -99,12 +96,6 @@ struct pnfs_osd_objid {
 #define _DEVID_HI(oid_device_id) \
 	(unsigned long long)be64_to_cpup(((__be64 *)(oid_device_id)->data) + 1)
 
-static inline int
-pnfs_osd_objid_xdr_sz(void)
-{
-	return (NFS4_DEVICEID4_SIZE / 4) + 2 + 2;
-}
-
 enum pnfs_osd_version {
 	PNFS_OSD_MISSING              = 0,
 	PNFS_OSD_VERSION_1            = 1,
@@ -189,8 +180,6 @@ struct pnfs_osd_targetid {
 	struct nfs4_string		oti_scsi_device_id;
 };
 
-enum { PNFS_OSD_TARGETID_MAX = 1 + PNFS_OSD_OSDNAME_MAXSIZE / 4 };
-
 /*   struct netaddr4 {
  *       // see struct rpcb in RFC1833
  *       string r_netid<>;    // network id
@@ -207,12 +196,6 @@ struct pnfs_osd_targetaddr {
 	struct pnfs_osd_net_addr	ota_netaddr;
 };
 
-enum {
-	NETWORK_ID_MAX = 16 / 4,
-	UNIVERSAL_ADDRESS_MAX = 64 / 4,
-	PNFS_OSD_TARGETADDR_MAX = 3 +  NETWORK_ID_MAX + UNIVERSAL_ADDRESS_MAX,
-};
-
 struct pnfs_osd_deviceaddr {
 	struct pnfs_osd_targetid	oda_targetid;
 	struct pnfs_osd_targetaddr	oda_targetaddr;
@@ -222,15 +205,6 @@ struct pnfs_osd_deviceaddr {
 	struct nfs4_string		oda_osdname;
 };
 
-enum {
-	ODA_OSDNAME_MAX = PNFS_OSD_OSDNAME_MAXSIZE / 4,
-	PNFS_OSD_DEVICEADDR_MAX =
-		PNFS_OSD_TARGETID_MAX + PNFS_OSD_TARGETADDR_MAX +
-		2 /*oda_lun*/ +
-		1 + OSD_SYSTEMID_LEN +
-		1 + ODA_OSDNAME_MAX,
-};
-
 /* LAYOUTCOMMIT: layoutupdate */
 
 /*   union pnfs_osd_deltaspaceused4 switch (bool dsu_valid) {
@@ -279,7 +253,7 @@ struct pnfs_osd_ioerr {
 	u32			oer_errno;
 };
 
-/* OSD XDR API */
+/* OSD XDR Client API */
 /* Layout helpers */
 /* Layout decoding is done in two parts:
  * 1. First Call pnfs_osd_xdr_decode_layout_map to read in only the header part
@@ -337,8 +311,7 @@ extern int
 pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
 				 struct pnfs_osd_layoutupdate *lou);
 
-/* osd_ioerror encoding/decoding (layout_return) */
-/* Client */
+/* osd_ioerror encoding (layout_return) */
 extern __be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr);
 extern void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr);
 
-- 
1.7.3.4

