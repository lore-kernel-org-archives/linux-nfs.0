Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:48066 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752572AbcHVSfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Aug 2016 14:35:18 -0400
From: Mikko Rapeli <mikko.rapeli@iki.fi>
To: linux-kernel@vger.kernel.org
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: [PATCH v05 07/72] cld.h: use __u8, __u16, __s16, __u32 and __s64 from linux/types.h
Date: Mon, 22 Aug 2016 20:32:24 +0200
Message-Id: <1471890809-4383-8-git-send-email-mikko.rapeli@iki.fi>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes userspace compilation errors like:

linux/nfsd/cld.h:40:2: error: unknown type name ‘uint16_t’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/nfsd/cld.h | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
index f14a9ab..d9f2306 100644
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
+	__u16	cn_len;				/* length of cm_id */
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
+	__u32	cm_xid;			/* transaction id */
 	union {
-		int64_t		cm_gracetime;	/* grace period start time */
+		__s64		cm_gracetime;	/* grace period start time */
 		struct cld_name	cm_name;
 	} __attribute__((packed)) cm_u;
 } __attribute__((packed));
-- 
2.8.1

