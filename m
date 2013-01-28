Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f175.google.com ([209.85.161.175]:54796 "EHLO
	mail-gg0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TmF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:42:05 -0500
Received: by mail-gg0-f175.google.com with SMTP id l1so468277ggn.6
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:42:04 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 12/16] nfsd: when updating an entry with RC_NOCACHE, just free it
Date: Mon, 28 Jan 2013 14:41:18 -0500
Message-Id: <1359402082-29195-13-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no need to keep entries around that we're declaring RC_NOCACHE.
Ditto if there's a problem with the entry.

With this change too, there's no need to test for RC_UNUSED in the
search function. If the entry's in the hash table then it's either
INPROG or DONE.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 5a39b82..6b4693c 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -66,6 +66,14 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 	kmem_cache_free(drc_slab, rp);
 }
 
+static void
+nfsd_reply_cache_free(struct svc_cacherep *rp)
+{
+	spin_lock(&cache_lock);
+	nfsd_reply_cache_free_locked(rp);
+	spin_unlock(&cache_lock);
+}
+
 int nfsd_reply_cache_init(void)
 {
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
@@ -148,8 +156,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 
 	rh = &cache_hash[request_hash(xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
+		if (xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    !nfsd_cache_entry_expired(rp) &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
@@ -311,7 +318,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
-		rp->c_state = RC_UNUSED;
+		nfsd_reply_cache_free(rp);
 		return;
 	}
 
@@ -325,12 +332,15 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 		cachv = &rp->c_replvec;
 		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
 		if (!cachv->iov_base) {
-			rp->c_state = RC_UNUSED;
+			nfsd_reply_cache_free(rp);
 			return;
 		}
 		cachv->iov_len = len << 2;
 		memcpy(cachv->iov_base, statp, len << 2);
 		break;
+	case RC_NOCACHE:
+		nfsd_reply_cache_free(rp);
+		return;
 	}
 	spin_lock(&cache_lock);
 	lru_put_end(rp);
-- 
1.7.11.7

