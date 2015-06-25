Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36818 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbbFYOgL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:36:11 -0400
Message-ID: <558C11D0.9020606@gmail.com>
Date: Thu, 25 Jun 2015 22:36:00 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 09/10 v6] sunrpc: Support validate/invalidate for reference
 change in cache_detail
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add validate/invalidate functions in cache_detail for processing
reference change (increase/decrease, both are before change!)

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.h                  |  2 +-
 include/linux/sunrpc/cache.h      | 11 ++++++++++-
 net/sunrpc/auth_gss/svcauth_gss.c |  2 +-
 net/sunrpc/cache.c                | 12 ++++++------
 net/sunrpc/svcauth_unix.c         |  2 +-
 5 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..b559acf 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -105,7 +105,7 @@ static inline void exp_put(struct svc_export *exp)
 
 static inline struct svc_export *exp_get(struct svc_export *exp)
 {
-	cache_get(&exp->h);
+	cache_get(&exp->h, exp->cd);
 	return exp;
 }
 struct svc_export * rqst_exp_find(struct svc_rqst *, int, u32 *);
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 5a4b921..f77b2cd 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -101,6 +101,8 @@ struct cache_detail {
 	int			(*match)(struct cache_head *orig, struct cache_head *new);
 	void			(*init)(struct cache_head *orig, struct cache_head *new);
 	void			(*update)(struct cache_head *orig, struct cache_head *new);
+	void			(*validate)(struct cache_head *h);
+	void			(*invalidate)(struct cache_head *h);
 
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
@@ -185,8 +187,11 @@ sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h);
 
 extern void cache_clean_deferred(void *owner);
 
-static inline struct cache_head  *cache_get(struct cache_head *h)
+static inline struct cache_head *cache_get(struct cache_head *h, struct cache_detail *cd)
 {
+	if (cd && cd->validate)
+		cd->validate(h);
+
 	kref_get(&h->ref);
 	return h;
 }
@@ -197,6 +202,10 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 	if (atomic_read(&h->ref.refcount) <= 2 &&
 	    h->expiry_time < cd->nextcheck)
 		cd->nextcheck = h->expiry_time;
+
+	if (cd->invalidate)
+		cd->invalidate(h);
+
 	kref_put(&h->ref, cd->cache_put);
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1095be9..ee1faa2 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1520,7 +1520,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 			goto auth_err;
 		}
 		svcdata->rsci = rsci;
-		cache_get(&rsci->h);
+		cache_get(&rsci->h, NULL);
 		rqstp->rq_cred.cr_flavor = gss_svc_to_pseudoflavor(
 					rsci->mechctx->mech_type,
 					GSS_C_QOP_DEFAULT,
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8a27483..cb7f3c0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -68,7 +68,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 			if (cache_is_expired(detail, tmp))
 				/* This entry is expired, we will discard it. */
 				break;
-			cache_get(tmp);
+			cache_get(tmp, detail);
 			read_unlock(&detail->hash_lock);
 			return tmp;
 		}
@@ -98,7 +98,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				freeme = tmp;
 				break;
 			}
-			cache_get(tmp);
+			cache_get(tmp, detail);
 			write_unlock(&detail->hash_lock);
 			cache_put(new, detail);
 			return tmp;
@@ -107,7 +107,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 
 	list_add(&new->cache_list, head);
 	detail->entries++;
-	cache_get(new);
+	cache_get(new, detail);
 	write_unlock(&detail->hash_lock);
 
 	if (freeme)
@@ -175,7 +175,7 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 		detail->update(tmp, new);
 	list_add(&tmp->cache_list, &detail->hash_table[hash]);
 	detail->entries++;
-	cache_get(tmp);
+	cache_get(tmp, detail);
 	cache_fresh_locked(tmp, new->expiry_time);
 	cache_fresh_locked(old, 0);
 	write_unlock(&detail->hash_lock);
@@ -1204,7 +1204,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 	}
 
 	crq->q.reader = 0;
-	crq->item = cache_get(h);
+	crq->item = cache_get(h, detail);
 	crq->buf = buf;
 	crq->len = 0;
 	crq->readers = 0;
@@ -1382,7 +1382,7 @@ static int c_show(struct seq_file *m, void *p)
 		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
 			   convert_to_wallclock(cp->expiry_time),
 			   atomic_read(&cp->ref.refcount), cp->flags);
-	cache_get(cp);
+	cache_get(cp, cd);
 	if (cache_check(cd, cp, NULL))
 		/* cache_check does a cache_put on failure */
 		seq_printf(m, "# ");
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 621ca7b..ebba6b7 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -359,7 +359,7 @@ ip_map_cached_get(struct svc_xprt *xprt)
 				cache_put(&ipm->h, sn->ip_map_cache);
 				return NULL;
 			}
-			cache_get(&ipm->h);
+			cache_get(&ipm->h, NULL);
 		}
 		spin_unlock(&xprt->xpt_lock);
 	}
-- 
2.4.3

