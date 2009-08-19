From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/32] SUNRPC: Allow the cache_detail to specify
 alternative upcall mechanisms
Date: Wed, 19 Aug 2009 19:38:46 -0400
Message-ID: <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606AbZHSXk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:57 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNehbx001920
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:44 -0700 (PDT)
In-Reply-To: <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For events that are rare, such as referral DNS lookups, it makes limited
sense to have a daemon constantly listening for upcalls on a channel. An
alternative in those cases might simply be to run the app that fills the
cache using call_usermodehelper_exec() and friends.

The following patch allows the cache_detail to specify alternative upcall
mechanisms for these particular cases.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/export.c                  |   14 ++++++++++++--
 fs/nfsd/nfs4idmap.c               |   16 ++++++++++++++--
 include/linux/sunrpc/cache.h      |   13 ++++++++++---
 net/sunrpc/auth_gss/svcauth_gss.c |    7 ++++++-
 net/sunrpc/cache.c                |   26 ++++++++++++++++++--------
 net/sunrpc/svcauth_unix.c         |   14 ++++++++++++--
 6 files changed, 72 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b92a276..d946264 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -85,6 +85,11 @@ static void expkey_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
+static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	return sunrpc_cache_pipe_upcall(cd, h, expkey_request);
+}
+
 static struct svc_expkey *svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old);
 static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *);
 static struct cache_detail svc_expkey_cache;
@@ -259,7 +264,7 @@ static struct cache_detail svc_expkey_cache = {
 	.hash_table	= expkey_table,
 	.name		= "nfsd.fh",
 	.cache_put	= expkey_put,
-	.cache_request	= expkey_request,
+	.cache_upcall	= expkey_upcall,
 	.cache_parse	= expkey_parse,
 	.cache_show	= expkey_show,
 	.match		= expkey_match,
@@ -355,6 +360,11 @@ static void svc_export_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
+static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	return sunrpc_cache_pipe_upcall(cd, h, svc_export_request);
+}
+
 static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
@@ -724,7 +734,7 @@ struct cache_detail svc_export_cache = {
 	.hash_table	= export_table,
 	.name		= "nfsd.export",
 	.cache_put	= svc_export_put,
-	.cache_request	= svc_export_request,
+	.cache_upcall	= svc_export_upcall,
 	.cache_parse	= svc_export_parse,
 	.cache_show	= svc_export_show,
 	.match		= svc_export_match,
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index e9012ad..cdfa86f 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -146,6 +146,12 @@ idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 }
 
 static int
+idtoname_upcall(struct cache_detail *cd, struct cache_head *ch)
+{
+	return sunrpc_cache_pipe_upcall(cd, ch, idtoname_request);
+}
+
+static int
 idtoname_match(struct cache_head *ca, struct cache_head *cb)
 {
 	struct ent *a = container_of(ca, struct ent, h);
@@ -192,7 +198,7 @@ static struct cache_detail idtoname_cache = {
 	.hash_table	= idtoname_table,
 	.name		= "nfs4.idtoname",
 	.cache_put	= ent_put,
-	.cache_request	= idtoname_request,
+	.cache_upcall	= idtoname_upcall,
 	.cache_parse	= idtoname_parse,
 	.cache_show	= idtoname_show,
 	.warn_no_listener = warn_no_idmapd,
@@ -325,6 +331,12 @@ nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 }
 
 static int
+nametoid_upcall(struct cache_detail *cd, struct cache_head *ch)
+{
+	return sunrpc_cache_pipe_upcall(cd, ch, nametoid_request);
+}
+
+static int
 nametoid_match(struct cache_head *ca, struct cache_head *cb)
 {
 	struct ent *a = container_of(ca, struct ent, h);
@@ -363,7 +375,7 @@ static struct cache_detail nametoid_cache = {
 	.hash_table	= nametoid_table,
 	.name		= "nfs4.nametoid",
 	.cache_put	= ent_put,
-	.cache_request	= nametoid_request,
+	.cache_upcall	= nametoid_upcall,
 	.cache_parse	= nametoid_parse,
 	.cache_show	= nametoid_show,
 	.warn_no_listener = warn_no_idmapd,
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 3d1fad2..23ee259 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -70,9 +70,9 @@ struct cache_detail {
 	char			*name;
 	void			(*cache_put)(struct kref *);
 
-	void			(*cache_request)(struct cache_detail *cd,
-						 struct cache_head *h,
-						 char **bpp, int *blen);
+	int			(*cache_upcall)(struct cache_detail *,
+						struct cache_head *);
+
 	int			(*cache_parse)(struct cache_detail *,
 					       char *buf, int len);
 
@@ -135,6 +135,13 @@ extern struct cache_head *
 sunrpc_cache_update(struct cache_detail *detail,
 		    struct cache_head *new, struct cache_head *old, int hash);
 
+extern int
+sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
+		void (*cache_request)(struct cache_detail *,
+				      struct cache_head *,
+				      char **,
+				      int *));
+
 
 extern void cache_clean_deferred(void *owner);
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 2278a50..2e6a148 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -181,6 +181,11 @@ static void rsi_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
+static int rsi_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	return sunrpc_cache_pipe_upcall(cd, h, rsi_request);
+}
+
 
 static int rsi_parse(struct cache_detail *cd,
 		    char *mesg, int mlen)
@@ -270,7 +275,7 @@ static struct cache_detail rsi_cache = {
 	.hash_table     = rsi_table,
 	.name           = "auth.rpcsec.init",
 	.cache_put      = rsi_put,
-	.cache_request  = rsi_request,
+	.cache_upcall   = rsi_upcall,
 	.cache_parse    = rsi_parse,
 	.match		= rsi_match,
 	.init		= rsi_init,
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index c8e7d2d..e438352 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -176,7 +176,13 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_update);
 
-static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
+static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	if (!cd->cache_upcall)
+		return -EINVAL;
+	return cd->cache_upcall(cd, h);
+}
+
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -322,7 +328,7 @@ static int create_cache_proc_entries(struct cache_detail *cd)
 	if (p == NULL)
 		goto out_nomem;
 
-	if (cd->cache_request || cd->cache_parse) {
+	if (cd->cache_upcall || cd->cache_parse) {
 		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
 				     cd->proc_ent, &cache_file_operations, cd);
 		cd->channel_ent = p;
@@ -1080,10 +1086,16 @@ static void warn_no_listener(struct cache_detail *detail)
 }
 
 /*
- * register an upcall request to user-space.
+ * register an upcall request to user-space and queue it up for read() by the
+ * upcall daemon.
+ *
  * Each request is at most one page long.
  */
-static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
+int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
+		void (*cache_request)(struct cache_detail *,
+				      struct cache_head *,
+				      char **,
+				      int *))
 {
 
 	char *buf;
@@ -1091,9 +1103,6 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
 	char *bp;
 	int len;
 
-	if (detail->cache_request == NULL)
-		return -EINVAL;
-
 	if (atomic_read(&detail->readers) == 0 &&
 	    detail->last_close < get_seconds() - 30) {
 			warn_no_listener(detail);
@@ -1112,7 +1121,7 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
 
 	bp = buf; len = PAGE_SIZE;
 
-	detail->cache_request(detail, h, &bp, &len);
+	cache_request(detail, h, &bp, &len);
 
 	if (len < 0) {
 		kfree(buf);
@@ -1130,6 +1139,7 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
 	wake_up(&queue_wait);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(sunrpc_cache_pipe_upcall);
 
 /*
  * parse a message from user-space and pass it
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 5c865e2..6caffa3 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -171,6 +171,11 @@ static void ip_map_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
+static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	return sunrpc_cache_pipe_upcall(cd, h, ip_map_request);
+}
+
 static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
@@ -289,7 +294,7 @@ struct cache_detail ip_map_cache = {
 	.hash_table	= ip_table,
 	.name		= "auth.unix.ip",
 	.cache_put	= ip_map_put,
-	.cache_request	= ip_map_request,
+	.cache_upcall	= ip_map_upcall,
 	.cache_parse	= ip_map_parse,
 	.cache_show	= ip_map_show,
 	.match		= ip_map_match,
@@ -523,6 +528,11 @@ static void unix_gid_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
+static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
+{
+	return sunrpc_cache_pipe_upcall(cd, h, unix_gid_request);
+}
+
 static struct unix_gid *unix_gid_lookup(uid_t uid);
 extern struct cache_detail unix_gid_cache;
 
@@ -622,7 +632,7 @@ struct cache_detail unix_gid_cache = {
 	.hash_table	= gid_table,
 	.name		= "auth.unix.gid",
 	.cache_put	= unix_gid_put,
-	.cache_request	= unix_gid_request,
+	.cache_upcall	= unix_gid_upcall,
 	.cache_parse	= unix_gid_parse,
 	.cache_show	= unix_gid_show,
 	.match		= unix_gid_match,
-- 
1.6.0.4
