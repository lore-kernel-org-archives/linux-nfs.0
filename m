Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f177.google.com ([209.85.160.177]:39281 "EHLO
	mail-gh0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3BDNSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:23 -0500
Received: by mail-gh0-f177.google.com with SMTP id g22so1504413ghb.22
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:22 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/8] nfsd: when updating an entry with RC_NOCACHE, just free it
Date: Mon,  4 Feb 2013 08:18:04 -0500
Message-Id: <1359983887-28535-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
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
index 69d29d4..e8ea785 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -98,6 +98,14 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
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
@@ -182,8 +190,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 
 	rh = &cache_hash[request_hash(xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
+		if (xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    !nfsd_cache_entry_expired(rp) &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
@@ -353,7 +360,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
-		rp->c_state = RC_UNUSED;
+		nfsd_reply_cache_free(rp);
 		return;
 	}
 
@@ -367,12 +374,15 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
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

