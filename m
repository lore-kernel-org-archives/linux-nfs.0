Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:12342 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab3BDLCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 06:02:05 -0500
Subject: [PATCH v2 4/6] SUNRPC: rework cache upcall logic
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 04 Feb 2013 14:02:50 +0300
Message-ID: <20130204110250.11633.70147.stgit@localhost.localdomain>
In-Reply-To: <20130204105728.11633.53621.stgit@localhost.localdomain>
References: <20130204105728.11633.53621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For most of SUNRPC caches (except NFS DNS cache) cache_detail->cache_upcall is
redundant since all that it's implementations are doing is calling
sunrpc_cache_pipe_upcall() with proper function address argument.
Cache request function address is now stored on cache_detail structure and
thus all the code can be simplified.
Now, for those cache details, which doesn't have cache_upcall callback (the
only one, which still has is nfs_dns_resolve_template)
sunrpc_cache_pipe_upcall will be called instead.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/export.c                  |   12 ------------
 fs/nfsd/nfs4idmap.c               |   14 --------------
 net/sunrpc/auth_gss/svcauth_gss.c |    7 -------
 net/sunrpc/cache.c                |   11 +++++++----
 net/sunrpc/svcauth_unix.c         |   12 ------------
 5 files changed, 7 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 22f4d4e..30a572d 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -67,11 +67,6 @@ static void expkey_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
-{
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
-}
-
 static struct svc_expkey *svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
 					    struct svc_expkey *old);
 static struct svc_expkey *svc_expkey_lookup(struct cache_detail *cd, struct svc_expkey *);
@@ -245,7 +240,6 @@ static struct cache_detail svc_expkey_cache_template = {
 	.hash_size	= EXPKEY_HASHMAX,
 	.name		= "nfsd.fh",
 	.cache_put	= expkey_put,
-	.cache_upcall	= expkey_upcall,
 	.cache_request	= expkey_request,
 	.cache_parse	= expkey_parse,
 	.cache_show	= expkey_show,
@@ -339,11 +333,6 @@ static void svc_export_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
-{
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
-}
-
 static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
@@ -713,7 +702,6 @@ static struct cache_detail svc_export_cache_template = {
 	.hash_size	= EXPORT_HASHMAX,
 	.name		= "nfsd.export",
 	.cache_put	= svc_export_put,
-	.cache_upcall	= svc_export_upcall,
 	.cache_request	= svc_export_request,
 	.cache_parse	= svc_export_parse,
 	.cache_show	= svc_export_show,
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 9033dfd..d9402ea 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -140,12 +140,6 @@ idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 }
 
 static int
-idtoname_upcall(struct cache_detail *cd, struct cache_head *ch)
-{
-	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
-}
-
-static int
 idtoname_match(struct cache_head *ca, struct cache_head *cb)
 {
 	struct ent *a = container_of(ca, struct ent, h);
@@ -192,7 +186,6 @@ static struct cache_detail idtoname_cache_template = {
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.idtoname",
 	.cache_put	= ent_put,
-	.cache_upcall	= idtoname_upcall,
 	.cache_request	= idtoname_request,
 	.cache_parse	= idtoname_parse,
 	.cache_show	= idtoname_show,
@@ -322,12 +315,6 @@ nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 }
 
 static int
-nametoid_upcall(struct cache_detail *cd, struct cache_head *ch)
-{
-	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
-}
-
-static int
 nametoid_match(struct cache_head *ca, struct cache_head *cb)
 {
 	struct ent *a = container_of(ca, struct ent, h);
@@ -366,7 +353,6 @@ static struct cache_detail nametoid_cache_template = {
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.nametoid",
 	.cache_put	= ent_put,
-	.cache_upcall	= nametoid_upcall,
 	.cache_request	= nametoid_request,
 	.cache_parse	= nametoid_parse,
 	.cache_show	= nametoid_show,
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 82437f9..1bd18af 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -182,12 +182,6 @@ static void rsi_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static int rsi_upcall(struct cache_detail *cd, struct cache_head *h)
-{
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
-}
-
-
 static int rsi_parse(struct cache_detail *cd,
 		    char *mesg, int mlen)
 {
@@ -275,7 +269,6 @@ static struct cache_detail rsi_cache_template = {
 	.hash_size	= RSI_HASHMAX,
 	.name           = "auth.rpcsec.init",
 	.cache_put      = rsi_put,
-	.cache_upcall   = rsi_upcall,
 	.cache_request  = rsi_request,
 	.cache_parse    = rsi_parse,
 	.match		= rsi_match,
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9f84703..51853d8 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -196,9 +196,9 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_update);
 
 static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	if (!cd->cache_upcall)
-		return -EINVAL;
-	return cd->cache_upcall(cd, h);
+	if (cd->cache_upcall)
+		return cd->cache_upcall(cd, h);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
@@ -1152,6 +1152,9 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 	char *bp;
 	int len;
 
+	if (!detail->cache_request)
+		return -EINVAL;
+
 	if (!cache_listeners_exist(detail)) {
 		warn_no_listener(detail);
 		return -EINVAL;
@@ -1605,7 +1608,7 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 	if (p == NULL)
 		goto out_nomem;
 
-	if (cd->cache_upcall || cd->cache_parse) {
+	if (cd->cache_request || cd->cache_parse) {
 		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
 				     cd->u.procfs.proc_ent,
 				     &cache_file_operations_procfs, cd);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 6b03cc1..002ddd9 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -157,11 +157,6 @@ static void ip_map_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
-{
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
-}
-
 static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
@@ -470,11 +465,6 @@ static void unix_gid_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
-{
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
-}
-
 static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid);
 
 static int unix_gid_parse(struct cache_detail *cd,
@@ -577,7 +567,6 @@ static struct cache_detail unix_gid_cache_template = {
 	.hash_size	= GID_HASHMAX,
 	.name		= "auth.unix.gid",
 	.cache_put	= unix_gid_put,
-	.cache_upcall	= unix_gid_upcall,
 	.cache_request	= unix_gid_request,
 	.cache_parse	= unix_gid_parse,
 	.cache_show	= unix_gid_show,
@@ -875,7 +864,6 @@ static struct cache_detail ip_map_cache_template = {
 	.hash_size	= IP_HASHMAX,
 	.name		= "auth.unix.ip",
 	.cache_put	= ip_map_put,
-	.cache_upcall	= ip_map_upcall,
 	.cache_request	= ip_map_request,
 	.cache_parse	= ip_map_parse,
 	.cache_show	= ip_map_show,

