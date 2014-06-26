Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:35552 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbaFZTNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:53 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so3172969qab.17
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 004/117] nfsd: clean up sparse endianness warnings in nfscache.c
Date: Thu, 26 Jun 2014 15:11:44 -0400
Message-Id: <1403810017-16062-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently hash the XID to determine a hash bucket to use for the
reply cache entry, which is fed into hash_32 without byte-swapping it.
Add __force to make sparse happy, and add some comments to explain
why.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfscache.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 6040da8830ff..ff9567633245 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -221,7 +221,12 @@ static void
 hash_refile(struct svc_cacherep *rp)
 {
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
+	/*
+	 * No point in byte swapping c_xid since we're just using it to pick
+	 * a hash bucket.
+	 */
+	hlist_add_head(&rp->c_hash, cache_hash +
+			hash_32((__force u32)rp->c_xid, maskbits));
 }
 
 /*
@@ -356,7 +361,11 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	struct hlist_head 	*rh;
 	unsigned int		entries = 0;
 
-	rh = &cache_hash[hash_32(rqstp->rq_xid, maskbits)];
+	/*
+	 * No point in byte swapping rq_xid since we're just using it to pick
+	 * a hash bucket.
+	 */
+	rh = &cache_hash[hash_32((__force u32)rqstp->rq_xid, maskbits)];
 	hlist_for_each_entry(rp, rh, c_hash) {
 		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
-- 
1.9.3

