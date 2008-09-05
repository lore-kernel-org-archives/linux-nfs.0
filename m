From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/19] nfs-utils: whitespace clean ups in support/nfs/rpcmisc.c
Date: Fri, 05 Sep 2008 17:08:27 -0400
Message-ID: <20080905210826.10001.65783.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41641 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbYIEVJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:09:05 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fix a few spurious white space issues in support/nfs/rpcmisc.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index 506b595..a0854e7 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -1,9 +1,8 @@
 /*
- * support/nfs/rpcmisc.c
+ * Miscellaneous functions for RPC service startup and shutdown.
  *
- * Miscellaneous functions for RPC startup and shutdown.
  * This code is partially snarfed from rpcgen -s tcp -s udp,
- * partly written by Mark Shand, Donald Becker, and Rick 
+ * partly written by Mark Shand, Donald Becker, and Rick
  * Sladkey. It was tweaked slightly by Olaf Kirch to be
  * usable by both unfsd and mountd.
  *
@@ -122,7 +121,7 @@ rpc_init(char *name, int prog, int vers,
 	sock = 0;
 	if (getsockname(0, (struct sockaddr *) &saddr, &asize) == 0
 	    && saddr.sin_family == AF_INET) {
-		socklen_t ssize = sizeof (int);
+		socklen_t ssize = sizeof(int);
 		int fdtype = 0;
 		if (getsockopt(0, SOL_SOCKET, SO_TYPE,
 				(char *)&fdtype, &ssize) == -1)
@@ -142,7 +141,7 @@ rpc_init(char *name, int prog, int vers,
 
 	if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_DGRAM)) {
 		static SVCXPRT *last_transp = NULL;
- 
+
 		if (_rpcpmstart == 0) {
 			if (last_transp
 			    && (!defport || defport == last_transp->xp_port)) {
@@ -197,7 +196,7 @@ rpc_init(char *name, int prog, int vers,
 	}
 
 	if (_rpcpmstart) {
-		signal (SIGALRM, closedown);
-		alarm (_RPCSVC_CLOSEDOWN);
+		signal(SIGALRM, closedown);
+		alarm(_RPCSVC_CLOSEDOWN);
 	}
 }

