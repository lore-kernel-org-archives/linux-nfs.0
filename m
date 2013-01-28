Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f172.google.com ([209.85.161.172]:45695 "EHLO
	mail-gg0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TrH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:47:07 -0500
Received: by mail-gg0-f172.google.com with SMTP id f4so468111ggn.17
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:47:07 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 06/16] nfsd: remove redundant test from nfsd_reply_cache_free
Date: Mon, 28 Jan 2013 14:41:12 -0500
Message-Id: <1359402082-29195-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Entries can only get a c_type of RC_REPLBUFF iff they are
RC_DONE. Therefore the test for RC_DONE isn't necessary here.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 363bc61..2cdc4be 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -65,7 +65,7 @@ nfsd_reply_cache_alloc(void)
 static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
-	if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
+	if (rp->c_type == RC_REPLBUFF)
 		kfree(rp->c_replvec.iov_base);
 	list_del(&rp->c_lru);
 	kmem_cache_free(drc_slab, rp);
-- 
1.7.11.7

