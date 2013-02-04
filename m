Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f171.google.com ([209.85.161.171]:41481 "EHLO
	mail-gg0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3BDNSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:16 -0500
Received: by mail-gg0-f171.google.com with SMTP id j1so181024ggn.16
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:16 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/8] nfsd: track the number of DRC entries in the cache
Date: Mon,  4 Feb 2013 08:18:01 -0500
Message-Id: <1359983887-28535-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 9d80dfa..c0c5847 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -27,6 +27,7 @@ static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 static struct kmem_cache	*drc_slab;
+static unsigned int		num_drc_entries;
 
 /*
  * Calculate the hash index from an XID.
@@ -68,6 +69,7 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 	if (rp->c_type == RC_REPLBUFF)
 		kfree(rp->c_replvec.iov_base);
 	list_del(&rp->c_lru);
+	--num_drc_entries;
 	kmem_cache_free(drc_slab, rp);
 }
 
@@ -83,10 +85,12 @@ int nfsd_reply_cache_init(void)
 
 	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
+	num_drc_entries = 0;
 	while (i) {
 		rp = nfsd_reply_cache_alloc();
 		if (!rp)
 			goto out_nomem;
+		++num_drc_entries;
 		list_add(&rp->c_lru, &lru_head);
 		i--;
 	}
-- 
1.7.11.7

