Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab0LJGIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:49 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLn023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:48 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/22] pnfs-submit: wave2: rewrite validate_bitmap_values to obey spec
Date: Thu,  9 Dec 2010 20:22:47 -0500
Message-Id: <1291944177-7819-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It was checking that at least one known bit was set.  It needs to check
no unknown bit was set.  From RFC5661, section 20.6.3:

When a bit is set in the type mask that corresponds to an undefined
type of recallable object, NFS4ERR_INVAL MUST be returned.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h      |    1 +
 fs/nfs/callback_proc.c |   27 ++++-----------------------
 2 files changed, 5 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b16dd1f..616c5c1 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -126,6 +126,7 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 #define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
 #define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
 #define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
+#define RCA4_TYPE_MASK_ALL 0xf31f
 
 struct cb_recallanyargs {
 	struct sockaddr	*craa_addr;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 61b3c66..d4aec46 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -661,28 +661,10 @@ out_putclient:
 	goto out;
 }
 
-static inline bool
-validate_bitmap_values(const unsigned long *mask)
+static bool
+validate_bitmap_values(unsigned long mask)
 {
-	int i;
-
-	if (*mask == 0)
-		return true;
-	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
-	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
-	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
-	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
-	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
-		return true;
-	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
-	     i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
-		if (test_bit(i, mask))
-			return true;
-	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
-	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
-		if (test_bit(i, mask))
-			return true;
-	return false;
+	return mask & ~RCA4_TYPE_MASK_ALL;
 }
 
 __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
@@ -702,8 +684,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	status = cpu_to_be32(NFS4ERR_INVAL);
-	if (!validate_bitmap_values((const unsigned long *)
-				    &args->craa_type_mask))
+	if (!validate_bitmap_values(args->craa_type_mask))
 		goto out;
 
 	status = cpu_to_be32(NFS4_OK);
-- 
1.7.2.1

