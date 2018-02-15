Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:46880 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033275AbeBOUWS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 15:22:18 -0500
Received: by mail-io0-f194.google.com with SMTP id p78so1957061iod.13
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 12:22:18 -0800 (PST)
Subject: [PATCH RFC 2/3] Avoid choosing reserved ports in svc_tli_create(3)
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Thu, 15 Feb 2018 15:22:16 -0500
Message-ID: <20180215202216.16924.4607.stgit@klimt.1015granger.net>
In-Reply-To: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
References: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers of svc_tli_create(3) can specify that an arbitrary port
number be dynamically assigned for the service listener being
created. svc_tli_create(3) tries bindresvport(3) first in this
case. bindresvport(3) chooses a reserved port if the caller has
CAP_NET_ADMIN_BIND privilege. If this fails, bind(2) is used to
assign a port number from the range above 1024.

This approach becomes a problem whenever bindresvport(3) happens to
choose the port number of a well-known service. If the caller is a
long-running service (like rpc.statd), it indefinitely prevents the
IANA-assigned well-known service from starting.

It seems that a reserved port is completely unnecessary for listener
sockets. It does not confer any extra privilege or functionality to
the listener socket, nor do remote clients infer any extra privilege
from a listener on a port number lower than 1024.

Therefore, remove the bindresvport step to prevent svc_tli_create(3)
from choosing a port number that interferes with well-known services
assigned to a privileged port.

svc_tli_create(3) will now never assign a privileged port
dynamically. If needed, a caller may still bind to a dynamically-
assigned reserved port by invoking bindresvport(3) directly and
passing the already-bound file descriptor to svc_tli_create(3).

But that should be a special case. It is no longer the default
behavior.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 src/rpc_soc.c     |    7 +++++--
 src/svc_generic.c |   12 ++++--------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index ed0892a..5ec96a7 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -67,6 +67,8 @@
 
 extern mutex_t	rpcsoc_lock;
 
+extern int __binddynport(int fd);
+
 static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, rpcvers_t,
     int *, u_int, u_int, char *, int);
 static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
@@ -145,7 +147,8 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
 	bindaddr.buf = raddr;
 
-	bindresvport(fd, NULL);
+	if (__binddynport(fd) == -1)
+		goto err;
 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
 				sendsz, recvsz);
 	if (cl) {
@@ -332,7 +335,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
 
 	memset(&sin, 0, sizeof sin);
 	sin.sin_family = AF_INET;
-	bindresvport(fd, &sin);
+	bind(fd, (struct sockaddr *)(void *)&sin, sizeof sin);
 	listen(fd, SOMAXCONN);
 	svc = svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
 	(void) freenetconfigent(nconf);
diff --git a/src/svc_generic.c b/src/svc_generic.c
index 7aae796..52a56c2 100644
--- a/src/svc_generic.c
+++ b/src/svc_generic.c
@@ -53,6 +53,7 @@
 #include <rpc/svc.h>
 
 extern int __svc_vc_setflag(SVCXPRT *, int);
+extern int __binddynport(int fd);
 
 /*
  * The highest level interface for server creation.
@@ -220,15 +221,10 @@ svc_tli_create(fd, nconf, bindaddr, sendsz, recvsz)
 	 */
 	if (madefd || !__rpc_sockisbound(fd)) {
 		if (bindaddr == NULL) {
-			if (bindresvport(fd, NULL) < 0) {
-				memset(&ss, 0, sizeof ss);
-				ss.ss_family = si.si_af;
-				if (bind(fd, (struct sockaddr *)(void *)&ss,
-				    (socklen_t)si.si_alen) < 0) {
-					warnx(
+			if (__binddynport(fd) == -1) {
+				warnx(
 			"svc_tli_create: could not bind to anonymous port");
-					goto freedata;
-				}
+				goto freedata;
 			}
 			listen(fd, SOMAXCONN);
 		} else {

