Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f170.google.com ([209.85.161.170]:48848 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1Tlw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:41:52 -0500
Received: by mail-gg0-f170.google.com with SMTP id k4so465881ggn.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:41:52 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 07/16] nfsd: clean up and clarify the cache expiration code
Date: Mon, 28 Jan 2013 14:41:13 -0500
Message-Id: <1359402082-29195-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a preprocessor constant for the expiry time of cache entries, and
move the test for an expired entry into a function. Note that the current
code does not test for RC_INPROG. It just assumes that it won't take more
than 2 minutes to fill out an in-progress entry.

I'm not sure how valid that assumption is though, so let's just ensure
that we never consider an RC_INPROG entry to be expired.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h    | 3 +++
 fs/nfsd/nfscache.c | 9 ++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index f8c6df8..9c7232b 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -70,6 +70,9 @@ enum {
  */
 #define RC_DELAY		(HZ/5)
 
+/* Cache entries expire after this time period */
+#define RC_EXPIRE		(120 * HZ)
+
 int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *);
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 2cdc4be..634b856 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -142,6 +142,13 @@ hash_refile(struct svc_cacherep *rp)
 	hlist_add_head(&rp->c_hash, cache_hash + request_hash(rp->c_xid));
 }
 
+static inline bool
+nfsd_cache_entry_expired(struct svc_cacherep *rp)
+{
+	return rp->c_state != RC_INPROG &&
+	       time_after(jiffies, rp->c_timestamp + RC_EXPIRE);
+}
+
 /*
  * Try to find an entry matching the current call in the cache. When none
  * is found, we grab the oldest unlocked entry off the LRU list.
@@ -175,7 +182,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
-		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
+		    !nfsd_cache_entry_expired(rp) &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
 		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr)) {
 			nfsdstats.rchits++;
-- 
1.7.11.7

