From: NeilBrown <neilb@suse.de>
Subject: [PATCH 6/9] sunrpc/cache: retry cache lookups that return -ETIMEDOUT
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909063254.20462.41616.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56321 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbZIIGdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:33:13 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If cache_check returns -ETIMEDOUT, then the cache item is not
up-to-date, but there is no pending upcall.
This could mean the data is not available, or it could mean that the
good data has been stored in a new cache item.

So re-do the lookup and if that returns a new item, proceed using that
item.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfsd/export.c                  |   18 ++++++++++++++++++
 net/sunrpc/auth_gss/svcauth_gss.c |   18 ++++++++++++++----
 net/sunrpc/svcauth_unix.c         |   22 ++++++++++++++++++++--
 3 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 984a5eb..ec0f0d9 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -793,9 +793,18 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
 	ek = svc_expkey_lookup(&key);
+ again:
 	if (ek == NULL)
 		return ERR_PTR(-ENOMEM);
 	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
+	if (err == -ETIMEDOUT) {
+		struct svc_expkey *prev_ek = ek;
+		ek = svc_expkey_lookup(&key);
+		if (ek != prev_ek)
+			goto again;
+		if (ek)
+			cache_put(&ek->h, &svc_expkey_cache);
+	}
 	if (err)
 		return ERR_PTR(err);
 	return ek;
@@ -865,9 +874,18 @@ static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
 	key.ex_path = *path;
 
 	exp = svc_export_lookup(&key);
+ retry:
 	if (exp == NULL)
 		return ERR_PTR(-ENOMEM);
 	err = cache_check(&svc_export_cache, &exp->h, reqp);
+	if (err == -ETIMEDOUT) {
+		struct svc_export *prev_exp = exp;
+		exp = svc_export_lookup(&key);
+		if (exp != prev_exp)
+			goto retry;
+		if (exp)
+			cache_put(&exp->h, &svc_export_cache);
+	}
 	if (err)
 		return ERR_PTR(err);
 	return exp;
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f6c51e5..c4e9177 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -999,7 +999,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	struct kvec *argv = &rqstp->rq_arg.head[0];
 	struct kvec *resv = &rqstp->rq_res.head[0];
 	struct xdr_netobj tmpobj;
-	struct rsi *rsip, rsikey;
+	struct rsi *rsip, rsikey, *prev_rsi;
 	int ret;
 
 	/* Read the verifier; should be NULL: */
@@ -1029,15 +1029,24 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	}
 
 	/* Perform upcall, or find upcall result: */
+ retry:
 	rsip = rsi_lookup(&rsikey);
-	rsi_free(&rsikey);
-	if (!rsip)
+	if (!rsip) {
+		rsi_free(&rsikey);
 		return SVC_DROP;
+	}
 	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
-	case -EAGAIN:
 	case -ETIMEDOUT:
+		prev_rsi = rsip;
+		rsip = rsi_lookup(&rsikey);
+		if (rsip != prev_rsi)
+			goto retry;
+		if (rsip)
+			cache_put(&rsip->h, &rsi_cache);
+	case -EAGAIN:
 	case -ENOENT:
 		/* No upcall result: */
+		rsi_free(&rsikey);
 		return SVC_DROP;
 	case 0:
 		ret = SVC_DROP;
@@ -1059,6 +1068,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	}
 	ret = SVC_COMPLETE;
 out:
+	rsi_free(&rsikey);
 	cache_put(&rsip->h, &rsi_cache);
 	return ret;
 }
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 117f68a..f9122df 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -659,8 +659,10 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 			 struct svc_rqst *rqstp)
 {
 	struct unix_gid *ug = unix_gid_lookup(uid);
+	struct unix_gid *prevug;
 	if (!ug)
 		return -EAGAIN;
+ retry:
 	switch (cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle)) {
 	case -ENOENT:
 		*gip = NULL;
@@ -670,6 +672,13 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 		get_group_info(*gip);
 		cache_put(&ug->h, &unix_gid_cache);
 		return 0;
+	case -ETIMEDOUT:
+		prevug = ug;
+		ug = unix_gid_lookup(uid);
+		if (ug != prevug)
+			goto retry;
+		if (ug)
+			cache_put(&ug->h, &unix_gid_cache);
 	default:
 		return -EAGAIN;
 	}
@@ -680,7 +689,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
 	struct sockaddr_in *sin;
 	struct sockaddr_in6 *sin6, sin6_storage;
-	struct ip_map *ipm;
+	struct ip_map *ipm, *prev_ipm;
 
 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -705,14 +714,23 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
 				    &sin6->sin6_addr);
 
+ retry:
 	if (ipm == NULL)
 		return SVC_DENIED;
 
 	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		default:
 			BUG();
-		case -EAGAIN:
 		case -ETIMEDOUT:
+			prev_ipm = ipm;
+			ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
+					    &sin6->sin6_addr);
+			if (ipm != prev_ipm)
+				goto retry;
+			if (ipm)
+				cache_put(&ipm->h, &ip_map_cache);
+
+		case -EAGAIN:
 			return SVC_DROP;
 		case -ENOENT:
 			return SVC_DENIED;


