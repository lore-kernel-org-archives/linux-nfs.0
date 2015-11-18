Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756438AbbKRQvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2015 11:51:41 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 541D7C0AED40
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2015 16:51:41 +0000 (UTC)
Received: from wirehat.home.4dicksons.org.com (vpn-61-174.rdu2.redhat.com [10.10.61.174])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tAIGpeAU005371
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2015 11:51:40 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] svc_create.c: Make sure errors are logged
Date: Wed, 18 Nov 2015 11:51:36 -0500
Message-Id: <1447865496-3239-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To help debug rpcbind failures, make sure all
errors are logged and log as much info about
the error as possible.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/svc_create.c | 12 +++++++-----
 support/nfs/svc_socket.c | 11 ++++++-----
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
index 5cb5ff6..ef7ff05 100644
--- a/support/nfs/svc_create.c
+++ b/support/nfs/svc_create.c
@@ -133,7 +133,7 @@ svc_create_bindaddr(struct netconfig *nconf, const uint16_t port)
 		hint.ai_family = AF_INET6;
 #endif	/* IPV6_SUPPORTED */
 	else {
-		xlog(D_GENERAL, "Unrecognized bind address family: %s",
+		xlog(L_ERROR, "Unrecognized bind address family: %s",
 			nconf->nc_protofmly);
 		return NULL;
 	}
@@ -143,7 +143,7 @@ svc_create_bindaddr(struct netconfig *nconf, const uint16_t port)
 	else if (strcmp(nconf->nc_proto, NC_TCP) == 0)
 		hint.ai_protocol = (int)IPPROTO_TCP;
 	else {
-		xlog(D_GENERAL, "Unrecognized bind address protocol: %s",
+		xlog(L_ERROR, "Unrecognized bind address protocol: %s",
 			nconf->nc_proto);
 		return NULL;
 	}
@@ -275,7 +275,7 @@ svc_create_nconf_rand_port(const char *name, const rpcprog_t program,
 	xprt = svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
 	freeaddrinfo(ai);
 	if (xprt == NULL) {
-		xlog(D_GENERAL, "Failed to create listener xprt "
+		xlog(L_ERROR, "Failed to create listener xprt "
 			"(%s, %u, %s)", name, version, nconf->nc_netid);
 		return 0;
 	}
@@ -286,10 +286,12 @@ svc_create_nconf_rand_port(const char *name, const rpcprog_t program,
 		return 0;
 	}
 
+	rpc_createerr.cf_stat = rpc_createerr.cf_error.re_errno = 0;
 	if (!svc_reg(xprt, program, version, dispatch, nconf)) {
 		/* svc_reg(3) destroys @xprt in this case */
-		xlog(D_GENERAL, "Failed to register (%s, %u, %s)",
-				name, version, nconf->nc_netid);
+		xlog(L_ERROR, "Failed to register (%s, %u, %s): %s",
+				name, version, nconf->nc_netid, 
+				clnt_spcreateerror("svc_reg() err"));
 		return 0;
 	}
 
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index 99321e7..1fa0d15 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -24,6 +24,7 @@
 #include <sys/socket.h>
 #include <sys/fcntl.h>
 #include <errno.h>
+#include "xlog.h"
 
 #include "config.h"
 
@@ -99,9 +100,9 @@ svcsock_nonblock(int sock)
 	 * connection.
 	 */
 	if ((flags = fcntl(sock, F_GETFL)) < 0)
-		perror(_("svc_socket: can't get socket flags"));
+		xlog(L_ERROR, "svc_socket: can't get socket flags: %m");
 	else if (fcntl(sock, F_SETFL, flags|O_NONBLOCK) < 0)
-		perror(_("svc_socket: can't set socket flags"));
+		xlog(L_ERROR, "svc_socket: can't set socket flags: %m");
 	else
 		return sock;
 
@@ -119,7 +120,7 @@ svc_socket (u_long number, int type, int protocol, int reuse)
 
   if ((sock = __socket (AF_INET, type, protocol)) < 0)
     {
-      perror (_("svc_socket: socket creation problem"));
+      xlog(L_ERROR, "svc_socket: socket creation problem: %m");
       return sock;
     }
 
@@ -130,7 +131,7 @@ svc_socket (u_long number, int type, int protocol, int reuse)
 			sizeof (ret));
       if (ret < 0)
 	{
-	  perror (_("svc_socket: socket reuse problem"));
+	  xlog(L_ERROR, "svc_socket: socket reuse problem: %m");
 	  return ret;
 	}
     }
@@ -141,7 +142,7 @@ svc_socket (u_long number, int type, int protocol, int reuse)
 
   if (bind(sock, (struct sockaddr *) &addr, len) < 0)
     {
-      perror (_("svc_socket: bind problem"));
+      xlog(L_ERROR, "svc_socket: bind problem: %m");
       (void) __close(sock);
       sock = -1;
     }
-- 
2.4.3

