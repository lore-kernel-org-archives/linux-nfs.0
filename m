Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:45787 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758815AbeBPRES (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Feb 2018 12:04:18 -0500
Received: by mail-io0-f174.google.com with SMTP id p188so4761402ioe.12
        for <linux-nfs@vger.kernel.org>; Fri, 16 Feb 2018 09:04:18 -0800 (PST)
Subject: [PATCH v2 4/4] Avoid choosing reserved ports in legacy RPC APIs
From: Chuck Lever <chuck.lever@oracle.com>
To: steve.dickson@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Fri, 16 Feb 2018 12:04:15 -0500
Message-ID: <20180216170415.9986.76878.stgit@klimt.1015granger.net>
In-Reply-To: <20180216164846.9986.58128.stgit@klimt.1015granger.net>
References: <20180216164846.9986.58128.stgit@klimt.1015granger.net>
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

