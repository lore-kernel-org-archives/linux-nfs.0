Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f172.google.com ([209.85.160.172]:62886 "EHLO
	mail-gh0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3A1Tsg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:48:36 -0500
Received: by mail-gh0-f172.google.com with SMTP id z22so477373ghb.31
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:48:35 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 14/16] nfsd: track the number of DRC entries in the cache
Date: Mon, 28 Jan 2013 14:41:20 -0500
Message-Id: <1359402082-29195-15-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 896e1c0..bd21230 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -21,6 +21,7 @@
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
+static unsigned int		num_drc_entries;
 
 /*
  * Calculate the hash index from an XID.
@@ -65,6 +66,7 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 		kfree(rp->c_replvec.iov_base);
 	hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
+	--num_drc_entries;
 	kmem_cache_free(drc_slab, rp);
 }
 
@@ -88,6 +90,7 @@ int nfsd_reply_cache_init(void)
 		goto out_nomem;
 
 	INIT_LIST_HEAD(&lru_head);
+	num_drc_entries = 0;
 	return 0;
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
@@ -257,6 +260,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		return RC_DOIT;
 	}
 	spin_lock(&cache_lock);
+	++num_drc_entries;
 
 	/*
 	 * Must search again just in case someone inserted one
-- 
1.7.11.7

