Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724Ab3JXSQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 14:16:30 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGU5Z009245
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:30 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-62-59.rdu2.redhat.com [10.10.62.59])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGSR8030193
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] mountd: Use protocol bit fields to turn protocols off.
Date: Thu, 24 Oct 2013 14:17:11 -0400
Message-Id: <1382638633-6710-2-git-send-email-steved@redhat.com>
In-Reply-To: <1382638633-6710-1-git-send-email-steved@redhat.com>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the current code to used the NFSCTL_XXX macros
to turn off the TCP listener.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/rpcmisc.h |  2 +-
 support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
 support/nfs/svc_create.c  |  5 +++++
 utils/mountd/mountd.c     |  2 +-
 4 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index b806227..31c8e5d 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -56,7 +56,7 @@ void		rpc_dispatch(struct svc_req *rq, SVCXPRT *xprt,
 int		getservport(u_long number, const char *proto);
 
 extern int	_rpcpmstart;
-extern int	_rpcfdtype;
+extern unsigned int	_rpcprotobits;
 extern int	_rpcsvcdirty;
 
 static inline struct sockaddr_in *nfs_getrpccaller_in(SVCXPRT *xprt)
diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index b73187a..64c98ff 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -39,7 +39,7 @@
 
 #define _RPCSVC_CLOSEDOWN	120
 int	_rpcpmstart = 0;
-int	_rpcfdtype = 0;
+unsigned int _rpcprotobits = (NFSCTL_UDPBIT|NFSCTL_TCPBIT);
 int	_rpcsvcdirty = 0;
 
 static void
@@ -51,7 +51,7 @@ closedown(int sig)
 		static int size;
 		int i, openfd;
 
-		if (_rpcfdtype == SOCK_DGRAM)
+		if (NFSCTL_TCPISSET(_rpcprotobits) == 0)
 			exit(0);
 
 		if (size == 0)
@@ -130,7 +130,16 @@ rpc_init(char *name, int prog, int vers,
 		 * listen will fail on a connected TCP socket(passed by rsh).
 		 */
 		if (!(fdtype == SOCK_STREAM && listen(0,5) == -1)) {
-			_rpcfdtype = fdtype;
+			switch(fdtype) {
+			case SOCK_DGRAM:
+				NFSCTL_UDPSET(_rpcprotobits);
+				break;
+			case SOCK_STREAM:
+				NFSCTL_TCPSET(_rpcprotobits);
+				break;
+			default:
+				xlog(L_FATAL, "getsockopt returns bad socket type: %d", fdtype);
+			}
 			_rpcpmstart = 1;
 		}
 	}
@@ -139,7 +148,7 @@ rpc_init(char *name, int prog, int vers,
 		sock = RPC_ANYSOCK;
 	}
 
-	if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_DGRAM)) {
+	if (NFSCTL_UDPISSET(_rpcprotobits)) {
 		static SVCXPRT *last_transp = NULL;
 
 		if (_rpcpmstart == 0) {
@@ -167,7 +176,7 @@ rpc_init(char *name, int prog, int vers,
 		last_transp = transp;
 	}
 
-	if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_STREAM)) {
+	if (NFSCTL_TCPISSET(_rpcprotobits)) {
 		static SVCXPRT *last_transp = NULL;
 
 		if (_rpcpmstart == 0) {
diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
index c159fc8..9ae2965 100644
--- a/support/nfs/svc_create.c
+++ b/support/nfs/svc_create.c
@@ -29,6 +29,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <netdb.h>
+#include "nfslib.h"
 
 #include <netinet/in.h>
 
@@ -417,6 +418,10 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
 		if (!(nconf->nc_flag & NC_VISIBLE))
 			continue;
 		visible++;
+
+		if (!strcmp(nconf->nc_proto, NC_TCP) && !NFSCTL_TCPISSET(_rpcprotobits))
+			continue;
+
 		if (port == 0)
 			servport = getservport(program, nconf->nc_proto);
 		else
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 993b6e6..f918472 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -755,7 +755,7 @@ main(int argc, char **argv)
 			nfs_version &= ~NFSVERSBIT(vers);
 			break;
 		case 'n':
-			_rpcfdtype = SOCK_DGRAM;
+			NFSCTL_TCPUNSET(_rpcprotobits);
 			break;
 		case 'r':
 			reverse_resolve = 1;
-- 
1.8.3.1

