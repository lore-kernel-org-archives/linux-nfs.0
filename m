Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:53810 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbdCAAMp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2017 19:12:45 -0500
Date: Wed, 1 Mar 2017 03:12:03 +0300
From: "Dmitry V. Levin" <ldv@altlinux.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] uapi: fix linux/nfsd/cld.h userspace compilation errors
Message-ID: <20170301001203.GA11188@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Include <linux/types.h> and consistently use types it provides
to fix the following linux/nfsd/cld.h userspace compilation errors:

/usr/include/linux/nfsd/cld.h:40:2: error: unknown type name 'uint16_t'
  uint16_t cn_len;    /* length of cm_id */
/usr/include/linux/nfsd/cld.h:46:2: error: unknown type name 'uint8_t'
  uint8_t  cm_vers;  /* upcall version */
/usr/include/linux/nfsd/cld.h:47:2: error: unknown type name 'uint8_t'
  uint8_t  cm_cmd;   /* upcall command */
/usr/include/linux/nfsd/cld.h:48:2: error: unknown type name 'int16_t'
  int16_t  cm_status;  /* return code */
/usr/include/linux/nfsd/cld.h:49:2: error: unknown type name 'uint32_t'
  uint32_t cm_xid;   /* transaction id */
/usr/include/linux/nfsd/cld.h:51:3: error: unknown type name 'int64_t'
   int64_t  cm_gracetime; /* grace period start time */

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/nfsd/cld.h | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
index f14a9ab..ec26027 100644
--- a/include/uapi/linux/nfsd/cld.h
+++ b/include/uapi/linux/nfsd/cld.h
@@ -22,6 +22,8 @@
 #ifndef _NFSD_CLD_H
 #define _NFSD_CLD_H
 
+#include <linux/types.h>
+
 /* latest upcall version available */
 #define CLD_UPCALL_VERSION 1
 
@@ -37,18 +39,18 @@ enum cld_command {
 
 /* representation of long-form NFSv4 client ID */
 struct cld_name {
-	uint16_t	cn_len;				/* length of cm_id */
+	__u16		cn_len;				/* length of cm_id */
 	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
 } __attribute__((packed));
 
 /* message struct for communication with userspace */
 struct cld_msg {
-	uint8_t		cm_vers;		/* upcall version */
-	uint8_t		cm_cmd;			/* upcall command */
-	int16_t		cm_status;		/* return code */
-	uint32_t	cm_xid;			/* transaction id */
+	__u8		cm_vers;		/* upcall version */
+	__u8		cm_cmd;			/* upcall command */
+	__s16		cm_status;		/* return code */
+	__u32		cm_xid;			/* transaction id */
 	union {
-		int64_t		cm_gracetime;	/* grace period start time */
+		__s64		cm_gracetime;	/* grace period start time */
 		struct cld_name	cm_name;
 	} __attribute__((packed)) cm_u;
 } __attribute__((packed));
-- 
ldv
