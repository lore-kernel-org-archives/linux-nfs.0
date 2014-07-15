Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008AbaGOPJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:50 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/15] clnt_bcast: Convert local debug() calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:31 -0400
Message-Id: <1405436974-4161-13-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_bcast.c | 36 +++++++++++-------------------------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/src/clnt_bcast.c b/src/clnt_bcast.c
index 1055545..373d8a5 100644
--- a/src/clnt_bcast.c
+++ b/src/clnt_bcast.c
@@ -55,9 +55,7 @@
 #endif				/* PORTMAP */
 #include <rpc/nettype.h>
 #include <arpa/inet.h>
-#ifdef RPC_DEBUG
 #include <stdio.h>
-#endif
 #include <errno.h>
 #include <stdlib.h>
 #include <unistd.h>
@@ -66,6 +64,7 @@
 #include <string.h>
 
 #include "rpc_com.h"
+#include "debug.h"
 
 #define	MAXBCAST 20	/* Max no of broadcasting transports */
 #define	INITTIME 4000	/* Time to wait initially */
@@ -454,20 +453,15 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 					    outlen, 0, (struct sockaddr*)addr,
 					    (size_t)fdlist[i].asize) !=
 					    outlen) {
-#ifdef RPC_DEBUG
-						perror("sendto");
-#endif
-						warnx("clnt_bcast: cannot send"
-						      "broadcast packet");
+						LIBTIRPC_DEBUG(1, 
+							("rpc_broadcast_exp: sendto failed: errno %d", errno));
+						warnx("rpc_broadcast_exp: cannot send broadcast packet");
 						stat = RPC_CANTSEND;
 						continue;
 					};
-#ifdef RPC_DEBUG
 				if (!__rpc_lowvers)
-					fprintf(stderr, "Broadcast packet sent "
-						"for %s\n",
-						 fdlist[i].nconf->nc_netid);
-#endif
+					LIBTIRPC_DEBUG(3, ("rpc_broadcast_exp: Broadcast packet sent for %s\n",
+						 fdlist[i].nconf->nc_netid));
 #ifdef PORTMAP
 				/*
 				 * Send the version 2 packet also
@@ -485,11 +479,8 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 						continue;
 					}
 				}
-#ifdef RPC_DEBUG
-				fprintf(stderr, "PMAP Broadcast packet "
-					"sent for %s\n",
-					fdlist[i].nconf->nc_netid);
-#endif
+				LIBTIRPC_DEBUG(3, ("rpc_broadcast_exp: PMAP Broadcast packet sent for %s\n",
+					fdlist[i].nconf->nc_netid));
 #endif				/* PORTMAP */
 			}
 			/* End for sending all packets on this transport */
@@ -532,10 +523,8 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 				continue;
 			} else
 				fds_found++;
-#ifdef RPC_DEBUG
-			fprintf(stderr, "response for %s\n",
-				fdlist[i].nconf->nc_netid);
-#endif
+			LIBTIRPC_DEBUG(3, ("rpc_broadcast_exp: response for %s\n", 
+				fdlist[i].nconf->nc_netid));
 		try_again:
 			inlen = recvfrom(fdlist[i].fd, inbuf, fdlist[i].dsize,
 			    0, (struct sockaddr *)(void *)&fdlist[i].raddr,
@@ -596,10 +585,7 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 						    &taddr, fdlist[i].nconf);
 					} else {
 #endif				/* PORTMAP */
-#ifdef RPC_DEBUG
-						fprintf(stderr, "uaddr %s\n",
-						    uaddrp);
-#endif
+						LIBTIRPC_DEBUG(3, ("rpc_broadcast_exp: uaddr %s\n", uaddrp));
 						np = uaddr2taddr(
 						    fdlist[i].nconf, uaddrp);
 						done = (*eachresult)(resultsp,
-- 
1.9.3

