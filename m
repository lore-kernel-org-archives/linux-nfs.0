From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] statd: replace smn_{get,
	set}_port() with the shared equivalents
Date: Tue, 08 Dec 2009 13:09:00 -0500
Message-ID: <20091208180900.3982.18112.stgit@localhost.localdomain>
References: <20091208180547.3982.31814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:38232 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965712AbZLHSJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:09:32 -0500
In-Reply-To: <20091208180547.3982.31814.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use shared sockaddr port management functions instead of duplicating
this functionality in sm-notify.  This is now easy because sm-notify
is linked with libnfs.a, where nfs_{get,set}_port() reside.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   40 +++++++---------------------------------
 1 files changed, 7 insertions(+), 33 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 15d0a92..0dba891 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -29,6 +29,7 @@
 #include <grp.h>
 
 #include "xlog.h"
+#include "nfsrpc.h"
 
 #ifndef BASEDIR
 # ifdef NFS_STATEDIR
@@ -90,33 +91,6 @@ static void		set_kernel_nsm_state(int state);
 
 static struct nsm_host *	hosts = NULL;
 
-/*
- * Address handling utilities
- */
-
-static unsigned short smn_get_port(const struct sockaddr *sap)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *)sap)->sin_port);
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-	}
-	return 0;
-}
-
-static void smn_set_port(struct sockaddr *sap, const unsigned short port)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
-		break;
-	}
-}
-
 static struct addrinfo *smn_lookup(const char *name)
 {
 	struct addrinfo	*ai, hint = {
@@ -321,7 +295,7 @@ notify(void)
 	/* Use source port if provided on the command line,
 	 * otherwise use bindresvport */
 	if (opt_srcport) {
-		smn_set_port(local_addr, opt_srcport);
+		nfs_set_port(local_addr, opt_srcport);
 		if (bind(sock, local_addr, sizeof(struct sockaddr_in)) < 0) {
 			xlog(L_ERROR, "Failed to bind RPC socket: %m");
 			exit(1);
@@ -455,16 +429,16 @@ notify_host(int sock, struct nsm_host *host)
 						first->ai_addrlen);
 		}
 
-		smn_set_port((struct sockaddr *)&host->addr, 0);
+		nfs_set_port((struct sockaddr *)&host->addr, 0);
 		host->retries = 0;
 	}
 
 	memcpy(dest, &host->addr, destlen);
-	if (smn_get_port(dest) == 0) {
+	if (nfs_get_port(dest) == 0) {
 		/* Build a PMAP packet */
 		xlog(D_GENERAL, "Sending portmap query to %s", host->name);
 
-		smn_set_port(dest, 111);
+		nfs_set_port(dest, 111);
 		*p++ = htonl(100000);
 		*p++ = htonl(2);
 		*p++ = htonl(3);
@@ -540,7 +514,7 @@ recv_reply(int sock)
 		return;
 	sap = (struct sockaddr *)&hp->addr;
 
-	if (smn_get_port(sap) == 0) {
+	if (nfs_get_port(sap) == 0) {
 		/* This was a portmap request */
 		unsigned int	port;
 
@@ -556,7 +530,7 @@ recv_reply(int sock)
 			hp->timeout = NSM_MAX_TIMEOUT;
 			hp->send_next += NSM_MAX_TIMEOUT;
 		} else {
-			smn_set_port(sap, port);
+			nfs_set_port(sap, port);
 			if (hp->timeout >= NSM_MAX_TIMEOUT / 4)
 				hp->timeout = NSM_MAX_TIMEOUT / 4;
 		}

