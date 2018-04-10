Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751770AbeDJVaq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 17:30:46 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Restore using reserve ports for client connections
Date: Tue, 10 Apr 2018 17:30:42 -0400
Message-Id: <20180410213043.5545-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 46e04a73 changed both clnt_com_create()
and clnt_tli_create() to avoid using reserve ports when
creating connection to the server.

For certain legacy apps, the client has to used
reserve port to be able to communicate with its
server so using of reserve ports is restored.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_generic.c | 3 +--
 src/rpc_soc.c      | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/src/clnt_generic.c b/src/clnt_generic.c
index e5a314f..774292b 100644
--- a/src/clnt_generic.c
+++ b/src/clnt_generic.c
@@ -341,8 +341,7 @@ clnt_tli_create(int fd, const struct netconfig *nconf,
 		servtype = nconf->nc_semantics;
 		if (!__rpc_fd2sockinfo(fd, &si))
 			goto err;
-		if (__binddynport(fd) == -1)
-			goto err;
+		bindresvport(fd, NULL);
 	} else {
 		if (!__rpc_fd2sockinfo(fd, &si))
 			goto err;
diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index af6c482..f32a27c 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -147,8 +147,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
 	bindaddr.buf = raddr;
 
-	if (__binddynport(fd) == -1)
-		goto err;
+	bindresvport(fd, NULL);
 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
 				sendsz, recvsz);
 	if (cl) {
-- 
2.14.3

