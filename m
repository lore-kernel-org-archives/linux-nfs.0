Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35474 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933317AbeBVRQb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Feb 2018 12:16:31 -0500
Received: by mail-it0-f68.google.com with SMTP id v194so7351097itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Feb 2018 09:16:30 -0800 (PST)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id 5sm656168itb.36.2018.02.22.09.16.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Feb 2018 09:16:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix broken cast in nfs4_callback_recallany()
Date: Thu, 22 Feb 2018 12:16:07 -0500
Message-Id: <20180222171607.19036-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Passing a pointer to a unsigned integer to test_bit() is broken.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2435af56b87e..a50d7813e3ea 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -572,7 +572,7 @@ __be32 nfs4_callback_sequence(void *argp, void *resp,
 }
 
 static bool
-validate_bitmap_values(unsigned long mask)
+validate_bitmap_values(unsigned int mask)
 {
 	return (mask & ~RCA4_TYPE_MASK_ALL) == 0;
 }
@@ -596,17 +596,15 @@ __be32 nfs4_callback_recallany(void *argp, void *resp,
 		goto out;
 
 	status = cpu_to_be32(NFS4_OK);
-	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
-		     &args->craa_type_mask))
+	if (args->craa_type_mask & BIT(RCA4_TYPE_MASK_RDATA_DLG))
 		flags = FMODE_READ;
-	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
-		     &args->craa_type_mask))
+	if (args->craa_type_mask & BIT(RCA4_TYPE_MASK_WDATA_DLG))
 		flags |= FMODE_WRITE;
-	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
-		     &args->craa_type_mask))
-		pnfs_recall_all_layouts(cps->clp);
 	if (flags)
 		nfs_expire_unused_delegation_types(cps->clp, flags);
+
+	if (args->craa_type_mask & BIT(RCA4_TYPE_MASK_FILE_LAYOUT))
+		pnfs_recall_all_layouts(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
2.14.3

