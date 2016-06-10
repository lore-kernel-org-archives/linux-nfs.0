Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33648 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbcFJPuX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 11:50:23 -0400
Received: by mail-qk0-f195.google.com with SMTP id u63so5651743qkh.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 08:50:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.1/pnfs: Layout stateids start out as being invalid
Date: Fri, 10 Jun 2016 11:49:55 -0400
Message-Id: <1465573798-80118-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
References: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c7e0d45a4de..f619139621ec 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1290,6 +1290,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	INIT_LIST_HEAD(&lo->plh_bulk_destroy);
 	lo->plh_inode = ino;
 	lo->plh_lc_cred = get_rpccred(ctx->cred);
+	lo->plh_flags |= 1 << NFS_LAYOUT_INVALID_STID;
 	return lo;
 }
 
@@ -1565,8 +1566,7 @@ lookup_again:
 	 * stateid, or it has been invalidated, then we must use the open
 	 * stateid.
 	 */
-	if (lo->plh_stateid.seqid == 0 ||
-	    test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
+	if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
 
 		/*
 		 * The first layoutget for the file. Need to serialize per
-- 
2.5.5

