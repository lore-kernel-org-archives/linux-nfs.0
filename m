Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41130 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756341Ab3AOIIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 03:08:51 -0500
Subject: [PATCH 1/4] SUNRPC: introduce cache_detail->cache_request callback
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 15 Jan 2013 11:09:31 +0300
Message-ID: <20130115080931.2996.44386.stgit@localhost.localdomain>
In-Reply-To: <20130115080402.2996.74320.stgit@localhost.localdomain>
References: <20130115080402.2996.74320.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This callback will allow to simplify upcalls in further patches in this
series.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/dns_resolve.c              |    2 +-
 fs/nfsd/export.c                  |    6 ++++--
 fs/nfsd/nfs4idmap.c               |    6 ++++--
 include/linux/sunrpc/cache.h      |    4 ++++
 net/sunrpc/auth_gss/svcauth_gss.c |    3 ++-
 net/sunrpc/svcauth_unix.c         |    6 ++++--
 6 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 31c26c4..90edbd0 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -142,7 +142,7 @@ static int nfs_dns_upcall(struct cache_detail *cd,
 
 	ret = nfs_cache_upcall(cd, key->hostname);
 	if (ret)
-		ret = sunrpc_cache_pipe_upcall(cd, ch, nfs_dns_request);
+		ret = sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
 	return ret;
 }
 
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a3946cf..63ee3bc 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -69,7 +69,7 @@ static void expkey_request(struct cache_detail *cd,
 
 static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	return sunrpc_cache_pipe_upcall(cd, h, expkey_request);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 static struct svc_expkey *svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
@@ -246,6 +246,7 @@ static struct cache_detail svc_expkey_cache_template = {
 	.name		= "nfsd.fh",
 	.cache_put	= expkey_put,
 	.cache_upcall	= expkey_upcall,
+	.cache_request	= expkey_request,
 	.cache_parse	= expkey_parse,
 	.cache_show	= expkey_show,
 	.match		= expkey_match,
@@ -339,7 +340,7 @@ static void svc_export_request(struct cache_detail *cd,
 
 static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	return sunrpc_cache_pipe_upcall(cd, h, svc_export_request);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 static struct svc_export *svc_export_update(struct svc_export *new,
@@ -712,6 +713,7 @@ static struct cache_detail svc_export_cache_template = {
 	.name		= "nfsd.export",
 	.cache_put	= svc_export_put,
 	.cache_upcall	= svc_export_upcall,
+	.cache_request	= svc_export_request,
 	.cache_parse	= svc_export_parse,
 	.cache_show	= svc_export_show,
 	.match		= svc_export_match,
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a1f10c0..9033dfd 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -142,7 +142,7 @@ idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 static int
 idtoname_upcall(struct cache_detail *cd, struct cache_head *ch)
 {
-	return sunrpc_cache_pipe_upcall(cd, ch, idtoname_request);
+	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
 }
 
 static int
@@ -193,6 +193,7 @@ static struct cache_detail idtoname_cache_template = {
 	.name		= "nfs4.idtoname",
 	.cache_put	= ent_put,
 	.cache_upcall	= idtoname_upcall,
+	.cache_request	= idtoname_request,
 	.cache_parse	= idtoname_parse,
 	.cache_show	= idtoname_show,
 	.warn_no_listener = warn_no_idmapd,
@@ -323,7 +324,7 @@ nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 static int
 nametoid_upcall(struct cache_detail *cd, struct cache_head *ch)
 {
-	return sunrpc_cache_pipe_upcall(cd, ch, nametoid_request);
+	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
 }
 
 static int
@@ -366,6 +367,7 @@ static struct cache_detail nametoid_cache_template = {
 	.name		= "nfs4.nametoid",
 	.cache_put	= ent_put,
 	.cache_upcall	= nametoid_upcall,
+	.cache_request	= nametoid_request,
 	.cache_parse	= nametoid_parse,
 	.cache_show	= nametoid_show,
 	.warn_no_listener = warn_no_idmapd,
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 5dc9ee4..4f1c858 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -83,6 +83,10 @@ struct cache_detail {
 	int			(*cache_upcall)(struct cache_detail *,
 						struct cache_head *);
 
+	void			(*cache_request)(struct cache_detail *cd,
+						 struct cache_head *ch,
+						 char **bpp, int *blen);
+
 	int			(*cache_parse)(struct cache_detail *,
 					       char *buf, int len);
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73e9573..82437f9 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -184,7 +184,7 @@ static void rsi_request(struct cache_detail *cd,
 
 static int rsi_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	return sunrpc_cache_pipe_upcall(cd, h, rsi_request);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 
@@ -276,6 +276,7 @@ static struct cache_detail rsi_cache_template = {
 	.name           = "auth.rpcsec.init",
 	.cache_put      = rsi_put,
 	.cache_upcall   = rsi_upcall,
+	.cache_request  = rsi_request,
 	.cache_parse    = rsi_parse,
 	.match		= rsi_match,
 	.init		= rsi_init,
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4d01292..6b03cc1 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -159,7 +159,7 @@ static void ip_map_request(struct cache_detail *cd,
 
 static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	return sunrpc_cache_pipe_upcall(cd, h, ip_map_request);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
@@ -472,7 +472,7 @@ static void unix_gid_request(struct cache_detail *cd,
 
 static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-	return sunrpc_cache_pipe_upcall(cd, h, unix_gid_request);
+	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
 }
 
 static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid);
@@ -578,6 +578,7 @@ static struct cache_detail unix_gid_cache_template = {
 	.name		= "auth.unix.gid",
 	.cache_put	= unix_gid_put,
 	.cache_upcall	= unix_gid_upcall,
+	.cache_request	= unix_gid_request,
 	.cache_parse	= unix_gid_parse,
 	.cache_show	= unix_gid_show,
 	.match		= unix_gid_match,
@@ -875,6 +876,7 @@ static struct cache_detail ip_map_cache_template = {
 	.name		= "auth.unix.ip",
 	.cache_put	= ip_map_put,
 	.cache_upcall	= ip_map_upcall,
+	.cache_request	= ip_map_request,
 	.cache_parse	= ip_map_parse,
 	.cache_show	= ip_map_show,
 	.match		= ip_map_match,

