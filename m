Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f44.google.com ([209.85.213.44]:33524 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab3LBU0h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 15:26:37 -0500
Received: by mail-yh0-f44.google.com with SMTP id f64so9341532yha.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 12:26:37 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: when reusing an existing repcache entry, unhash it first
Date: Mon,  2 Dec 2013 15:26:19 -0500
Message-Id: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The DRC code will attempt to reuse an existing, expired cache entry in
preference to allocating a new one. It'll then search the cache, and if
it gets a hit it'll then free the cache entry that it was going to
reuse.

The cache code doesn't unhash the entry that it's going to reuse
however, so it's possible for it end up designating an entry for reuse
and then subsequently freeing the same entry after it finds it.  This
leads it to a later use-after-free situation and usually some list
corruption warnings or an oops.

Fix this by simply unhashing the entry that we intend to reuse. That
will mean that it's not findable via a search and should prevent this
situation from occurring.

Cc: stable@vger.kernel.org # v3.10+
Reported-by: Christoph Hellwig <hch@infradead.org>
Reported-by: g. artim <gartim@gmail.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 9186c7c..b6af150 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -132,6 +132,13 @@ nfsd_reply_cache_alloc(void)
 }
 
 static void
+nfsd_reply_cache_unhash(struct svc_cacherep *rp)
+{
+	hlist_del_init(&rp->c_hash);
+	list_del_init(&rp->c_lru);
+}
+
+static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
@@ -417,7 +424,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
 		if (nfsd_cache_entry_expired(rp) ||
 		    num_drc_entries >= max_drc_entries) {
-			lru_put_end(rp);
+			nfsd_reply_cache_unhash(rp);
 			prune_cache_entries();
 			goto search_cache;
 		}
-- 
1.8.4.2

