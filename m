Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:51134 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbeBYSRq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Feb 2018 13:17:46 -0500
Received: by mail-it0-f46.google.com with SMTP id a75so8288680itd.0
        for <linux-nfs@vger.kernel.org>; Sun, 25 Feb 2018 10:17:46 -0800 (PST)
Subject: [PATCH v3 4/4] Avoid choosing reserved ports in legacy RPC APIs
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Sun, 25 Feb 2018 13:17:44 -0500
Message-ID: <20180225181744.2983.40343.stgit@klimt.1015granger.net>
In-Reply-To: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
References: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent a caller of legacy RPC client and server APIs from
dynamically allocating a well-known port number, when no port number
is provided. This is similar to recent changes to svc_tli_create(3)
and clnt_tli_create(3).

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 src/rpc_soc.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index ed0892a..af6c482 100644
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
@@ -313,7 +316,6 @@ svc_com_create(fd, sendsize, recvsize, netid)
 	SVCXPRT *svc;
 	int madefd = FALSE;
 	int port;
-	struct sockaddr_in sin;
 
 	if ((nconf = __rpc_getconfip(netid)) == NULL) {
 		(void) syslog(LOG_ERR, "Could not get %s transport", netid);
@@ -330,10 +332,6 @@ svc_com_create(fd, sendsize, recvsize, netid)
 		madefd = TRUE;
 	}
 
-	memset(&sin, 0, sizeof sin);
-	sin.sin_family = AF_INET;
-	bindresvport(fd, &sin);
-	listen(fd, SOMAXCONN);
 	svc = svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
 	(void) freenetconfigent(nconf);
 	if (svc == NULL) {

