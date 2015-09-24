Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36210 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbbIXM6K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:58:10 -0400
Received: by pacgz1 with SMTP id gz1so6155846pac.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:58:09 -0700 (PDT)
Subject: [PATCH 6/8] NFS: Fix bad defines of callback response maxsize
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F356.8090806@gmail.com>
Date: Thu, 24 Sep 2015 20:57:58 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As CB_OP_TAGLEN_MAXSZ, all XXX_MAXSZ should be defined as bit.
Each operation should not cantains CB_OP_TAGLEN_MAXSZ.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 09aeb9a..9f0f0f6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -18,19 +18,21 @@
 #include "internal.h"
 #include "nfs4session.h"
 
-#define CB_OP_TAGLEN_MAXSZ	(512)
-#define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
-#define CB_OP_GETATTR_BITMAP_MAXSZ	(4)
-#define CB_OP_GETATTR_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
-				CB_OP_GETATTR_BITMAP_MAXSZ + \
-				2 + 2 + 3 + 3)
-#define CB_OP_RECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_TAGLEN_MAXSZ		(512)
+#define CB_OP_HDR_RES_MAXSZ		(2 * 4) // opcode, status
+#define CB_OP_GETATTR_BITMAP_MAXSZ	(4 * 4) // bitmap length, 3 bitmaps
+#define CB_OP_GETATTR_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ + \
+					 CB_OP_GETATTR_BITMAP_MAXSZ + \
+					 /* change, size, ctime, mtime */\
+					 (2 + 2 + 3 + 3) * 4)
+#define CB_OP_RECALL_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ)
 
 #if defined(CONFIG_NFS_V4_1)
 #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
-					4 + 1 + 3)
+					 NFS4_MAX_SESSIONID_LEN + \
+					 (1 + 3) * 4) // seqid, 3 slotids
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
-- 
2.5.0

