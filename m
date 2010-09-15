Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422Ab0IONE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:04:58 -0400
Message-ID: <4C90BB32.2050304@parallels.com>
Date: Wed, 15 Sep 2010 16:25:22 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] sunrpc: Make xprt auth cache release work with the xprt
References: <4C90BADB.10700@parallels.com>
In-Reply-To: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is done in order to facilitate getting the ip_map_cache from
which to put the ip_map.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/sunrpc/svcauth.h |    3 ++-
 net/sunrpc/svc_xprt.c          |    5 ++---
 net/sunrpc/svcauth_unix.c      |    9 ++++++---
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index d39dbdc..f656667 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -112,6 +112,7 @@ struct auth_ops {
 #define	SVC_PENDING	8
 #define	SVC_COMPLETE	9
 
+struct svc_xprt;
 
 extern int	svc_authenticate(struct svc_rqst *rqstp, __be32 *authp);
 extern int	svc_authorise(struct svc_rqst *rqstp);
@@ -127,7 +128,7 @@ extern struct auth_domain *auth_domain_find(char *name);
 extern struct auth_domain *auth_unix_lookup(struct in6_addr *addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
-extern void svcauth_unix_info_release(void *);
+extern void svcauth_unix_info_release(struct svc_xprt *xpt);
 extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 
 static inline unsigned long hash_str(char *name, int bits)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index cbc0849..57703ac 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -128,9 +128,8 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
-	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags) &&
-	    xprt->xpt_auth_cache != NULL)
-		svcauth_unix_info_release(xprt->xpt_auth_cache);
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
+		svcauth_unix_info_release(xprt);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 1fe37be..aef0feb 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -472,10 +472,13 @@ ip_map_cached_put(struct svc_rqst *rqstp, struct ip_map *ipm)
 }
 
 void
-svcauth_unix_info_release(void *info)
+svcauth_unix_info_release(struct svc_xprt *xpt)
 {
-	struct ip_map *ipm = info;
-	cache_put(&ipm->h, &ip_map_cache);
+	struct ip_map *ipm;
+
+	ipm = xpt->xpt_auth_cache;
+	if (ipm != NULL)
+		cache_put(&ipm->h, &ip_map_cache);
 }
 
 /****************************************************************************
-- 
1.5.5.6

