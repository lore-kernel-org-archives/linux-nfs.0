From: NeilBrown <neilb@suse.de>
Subject: [PATCH 08/12] sunrpc/cache: retry cache lookups that return -ETIMEDOUT
Date: Tue, 04 Aug 2009 15:22:39 +1000
Message-ID: <20090804052239.15929.66850.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41298 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbZHDFZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:25:05 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
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

 fs/nfsd/export.c          |   18 ++++++++++++++++++
 net/sunrpc/svcauth_unix.c |   22 ++++++++++++++++++++--
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b92a276..6fcb0eb 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -783,9 +783,18 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
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
@@ -855,9 +864,18 @@ static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
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
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 5c865e2..f2de152 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -649,8 +649,10 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
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
@@ -659,6 +661,13 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 		*gip = ug->gi;
 		get_group_info(*gip);
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
@@ -669,7 +678,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
 	struct sockaddr_in *sin;
 	struct sockaddr_in6 *sin6, sin6_storage;
-	struct ip_map *ipm;
+	struct ip_map *ipm, *prev_ipm;
 
 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -694,14 +703,23 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
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


