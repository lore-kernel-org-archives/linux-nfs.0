Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:36999 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753248AbcLVRjv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Dec 2016 12:39:51 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <neilb@suse.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4] SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY
Date: Thu, 22 Dec 2016 12:38:06 -0500
Message-ID: <1482428286-33744-2-git-send-email-andros@netapp.com>
In-Reply-To: <1482428286-33744-1-git-send-email-andros@netapp.com>
References: <1482428286-33744-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Neil Brown <neilb@suse.com>

The rsc cache code operates in a read_lock/write_lock environment.
Changes to a cache entry should use the provided rsc_update
routine which takes the write_lock.

The current code sets the expiry_time and the CACHE_NEGATIVE flag
without taking the write_lock as it does not call rsc_update.
Without this patch, while cache_clean sees the entries to be
removed, it does not remove the rsc_entries. This is because
rsc_update updates other fields such as flush_time and last_refresh
in the entry to trigger cache_clean to reap the entry.

Add a new sunrpc_cache_unhash() function (by Neil Brown) designed
to directly unhash and reap the to be destroyed cache entry.

Signed-off-by: Neil Brown <neilb@suse.com>
Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/cache.h      |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c |  4 ++--
 net/sunrpc/cache.c                | 13 +++++++++++++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 62a60ee..9dcf2c8 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -227,6 +227,7 @@ extern int cache_check(struct cache_detail *detail,
 extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
 					umode_t, struct cache_detail *);
 extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
+extern void sunrpc_cache_unhash(struct cache_detail *, struct cache_head *);
 
 /* Must store cache_detail in seq_file->private if using next three functions */
 extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 45662d7..78f8a9c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1489,8 +1489,8 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		rsci->h.expiry_time = get_seconds();
-		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
+		/* Delete the entry from the cache_list and call cache_put */
+		sunrpc_cache_unhash(sn->rsc_cache, &rsci->h);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
 		svc_putnl(resv, RPC_SUCCESS);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8aabe12..153e254 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1855,3 +1855,16 @@ void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
 
+void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
+{
+	write_lock(&cd->hash_lock);
+	if (!hlist_unhashed(&h->cache_list)){
+		hlist_del_init(&h->cache_list);
+		cd->entries--;
+		write_unlock(&cd->hash_lock);
+		cache_put(h, cd);
+	} else
+		write_unlock(&cd->hash_lock);
+}
+EXPORT_SYMBOL_GPL(sunrpc_cache_unhash);
+
-- 
1.8.3.1

