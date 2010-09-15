Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab0IONEy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:04:54 -0400
Message-ID: <4C90BB53.2060401@parallels.com>
Date: Wed, 15 Sep 2010 16:25:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] sunrpc: Pass xprt to cached get/put routines
References: <4C90BADB.10700@parallels.com>
In-Reply-To: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

They do not require the rqst actually and having the xprt simplifies
further patching.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/sunrpc/svcauth_unix.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index aef0feb..f0017ca 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -426,10 +426,9 @@ void svcauth_unix_purge(void)
 EXPORT_SYMBOL_GPL(svcauth_unix_purge);
 
 static inline struct ip_map *
-ip_map_cached_get(struct svc_rqst *rqstp)
+ip_map_cached_get(struct svc_xprt *xprt)
 {
 	struct ip_map *ipm = NULL;
-	struct svc_xprt *xprt = rqstp->rq_xprt;
 
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)) {
 		spin_lock(&xprt->xpt_lock);
@@ -454,10 +453,8 @@ ip_map_cached_get(struct svc_rqst *rqstp)
 }
 
 static inline void
-ip_map_cached_put(struct svc_rqst *rqstp, struct ip_map *ipm)
+ip_map_cached_put(struct svc_xprt *xprt, struct ip_map *ipm)
 {
-	struct svc_xprt *xprt = rqstp->rq_xprt;
-
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)) {
 		spin_lock(&xprt->xpt_lock);
 		if (xprt->xpt_auth_cache == NULL) {
@@ -705,6 +702,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	struct ip_map *ipm;
 	struct group_info *gi;
 	struct svc_cred *cred = &rqstp->rq_cred;
+	struct svc_xprt *xprt = rqstp->rq_xprt;
 
 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -723,7 +721,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	if (rqstp->rq_proc == 0)
 		return SVC_OK;
 
-	ipm = ip_map_cached_get(rqstp);
+	ipm = ip_map_cached_get(xprt);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
 				    &sin6->sin6_addr);
@@ -742,7 +740,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 		case 0:
 			rqstp->rq_client = &ipm->m_client->h;
 			kref_get(&rqstp->rq_client->ref);
-			ip_map_cached_put(rqstp, ipm);
+			ip_map_cached_put(xprt, ipm);
 			break;
 	}
 
-- 
1.5.5.6

