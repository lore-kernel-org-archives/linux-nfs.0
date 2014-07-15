Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbaGOPJw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:52 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 14/15] svc_dg: Convert fprintf calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:33 -0400
Message-Id: <1405436974-4161-15-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_dg.c | 51 +++++++++++++++++++++++----------------------------
 1 file changed, 23 insertions(+), 28 deletions(-)

diff --git a/src/svc_dg.c b/src/svc_dg.c
index 6e00191..f8255cc 100644
--- a/src/svc_dg.c
+++ b/src/svc_dg.c
@@ -49,13 +49,11 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
-#ifdef RPC_CACHE_DEBUG
 #include <netconfig.h>
-#include <netdir.h>
-#endif
 #include <err.h>
 
 #include "rpc_com.h"
+#include "debug.h"
 
 #define	su_data(xprt)	((struct svc_dg_data *)(xprt->xp_p2))
 #define	rpc_buffer(xprt) ((xprt)->xp_p1)
@@ -506,10 +504,8 @@ cache_set(xprt, replylen)
 	struct cl_cache *uc = (struct cl_cache *) su->su_cache;
 	u_int loc;
 	char *newbuf;
-#ifdef RPC_CACHE_DEBUG
 	struct netconfig *nconf;
 	char *uaddr;
-#endif
 
 	mutex_lock(&dupreq_lock);
 	/*
@@ -549,17 +545,17 @@ cache_set(xprt, replylen)
 	/*
 	 * Store it away
 	 */
-#ifdef RPC_CACHE_DEBUG
-	if (nconf = getnetconfigent(xprt->xp_netid)) {
-		uaddr = taddr2uaddr(nconf, &xprt->xp_rtaddr);
-		freenetconfigent(nconf);
-		printf(
-	"cache set for xid= %x prog=%d vers=%d proc=%d for rmtaddr=%s\n",
-			su->su_xid, uc->uc_prog, uc->uc_vers,
-			uc->uc_proc, uaddr);
-		free(uaddr);
+	if (libtirpc_debug_level > 3) {
+		if ((nconf = getnetconfigent(xprt->xp_netid))) {
+			uaddr = taddr2uaddr(nconf, &xprt->xp_rtaddr);
+			freenetconfigent(nconf);
+			LIBTIRPC_DEBUG(4,
+				("cache set for xid= %x prog=%d vers=%d proc=%d for rmtaddr=%s\n",
+				su->su_xid, uc->uc_prog, uc->uc_vers,
+				uc->uc_proc, uaddr));
+			free(uaddr);
+		}
 	}
-#endif
 	victim->cache_replylen = replylen;
 	victim->cache_reply = rpc_buffer(xprt);
 	rpc_buffer(xprt) = newbuf;
@@ -596,10 +592,8 @@ cache_get(xprt, msg, replyp, replylenp)
 	cache_ptr ent;
 	struct svc_dg_data *su = su_data(xprt);
 	struct cl_cache *uc = (struct cl_cache *) su->su_cache;
-#ifdef RPC_CACHE_DEBUG
 	struct netconfig *nconf;
 	char *uaddr;
-#endif
 
 	mutex_lock(&dupreq_lock);
 	loc = CACHE_LOC(xprt, su->su_xid);
@@ -611,18 +605,19 @@ cache_get(xprt, msg, replyp, replylenp)
 			ent->cache_addr.len == xprt->xp_rtaddr.len &&
 			(memcmp(ent->cache_addr.buf, xprt->xp_rtaddr.buf,
 				xprt->xp_rtaddr.len) == 0)) {
-#ifdef RPC_CACHE_DEBUG
-			if (nconf = getnetconfigent(xprt->xp_netid)) {
-				uaddr = taddr2uaddr(nconf, &xprt->xp_rtaddr);
-				freenetconfigent(nconf);
-				printf(
-	"cache entry found for xid=%x prog=%d vers=%d proc=%d for rmtaddr=%s\n",
-					su->su_xid, msg->rm_call.cb_prog,
-					msg->rm_call.cb_vers,
-					msg->rm_call.cb_proc, uaddr);
-				free(uaddr);
+			if (libtirpc_debug_level > 3) {
+				if ((nconf = getnetconfigent(xprt->xp_netid))) {
+					uaddr = taddr2uaddr(nconf, &xprt->xp_rtaddr);
+					freenetconfigent(nconf);
+					LIBTIRPC_DEBUG(4,
+						("cache entry found for xid=%x prog=%d" 
+						"vers=%d proc=%d for rmtaddr=%s\n",
+						su->su_xid, msg->rm_call.cb_prog,
+						msg->rm_call.cb_vers,
+						msg->rm_call.cb_proc, uaddr));
+					free(uaddr);
+				}
 			}
-#endif
 			*replyp = ent->cache_reply;
 			*replylenp = ent->cache_replylen;
 			mutex_unlock(&dupreq_lock);
-- 
1.9.3

