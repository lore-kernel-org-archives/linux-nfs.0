Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f177.google.com ([209.85.161.177]:45530 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1Tli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:41:38 -0500
Received: by mail-gg0-f177.google.com with SMTP id q1so471932gge.36
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:41:38 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 02/16] nfsd: remove unneeded spinlock in nfsd_cache_update
Date: Mon, 28 Jan 2013 14:41:08 -0500
Message-Id: <1359402082-29195-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The locking rules for cache entries say that locking the cache_lock
isn't needed if you're just touching the current entry. Earlier
in this function we set rp->c_state to RC_UNUSED without any locking,
so I believe it's ok to do the same here.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 5dd9ec2..972c14a 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -286,9 +286,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 		cachv = &rp->c_replvec;
 		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
 		if (!cachv->iov_base) {
-			spin_lock(&cache_lock);
 			rp->c_state = RC_UNUSED;
-			spin_unlock(&cache_lock);
 			return;
 		}
 		cachv->iov_len = len << 2;
-- 
1.7.11.7

