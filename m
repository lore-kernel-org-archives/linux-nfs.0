Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f169.google.com ([209.85.161.169]:50773 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1Tl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:41:58 -0500
Received: by mail-gg0-f169.google.com with SMTP id j5so471564ggn.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:41:57 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 09/16] nfsd: always move DRC entries to the end of LRU list when updating timestamp
Date: Mon, 28 Jan 2013 14:41:15 -0500
Message-Id: <1359402082-29195-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...otherwise, we end up with the list ordering wrong. Currently, it's
not a problem since we skip RC_INPROG entries, but keeping the ordering
strict will be necessary for a later patch that adds a cache cleaner.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b89e7c8..9d80dfa 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -129,6 +129,7 @@ void nfsd_reply_cache_shutdown(void)
 static void
 lru_put_end(struct svc_cacherep *rp)
 {
+	rp->c_timestamp = jiffies;
 	list_move_tail(&rp->c_lru, &lru_head);
 }
 
@@ -245,9 +246,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
-	rp->c_timestamp = jiffies;
 
 	hash_refile(rp);
+	lru_put_end(rp);
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
@@ -262,7 +263,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 found_entry:
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
-	rp->c_timestamp = jiffies;
 	lru_put_end(rp);
 
 	rtn = RC_DROPIT;
@@ -354,7 +354,6 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
-	rp->c_timestamp = jiffies;
 	spin_unlock(&cache_lock);
 	return;
 }
-- 
1.7.11.7

