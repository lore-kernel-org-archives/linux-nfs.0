From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/16] nfs-utils: remove disabled code from
	support/nfs/rpcmisc.c
Date: Thu, 04 Sep 2008 12:56:48 -0400
Message-ID: <20080904165647.1471.11212.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47978 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbYIDQ5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:15 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After some recent discussions, we want to rely on the kernel's network
layer to autotune socket buffers.  Since this code is already disabled in
support/nfs/rpcmisc.c (and has been for some time), let's just remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index bd1a2db..40c2102 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -192,22 +192,6 @@ int makesock(int port, int proto)
 			xlog(L_ERROR, "setsockopt failed: %s\n",
 			     strerror(errno));
 
-#if 0
-	/* I was told it didn't work with gigabit ethernet.
-	   Don't bothet with it.  H.J. */
-#ifdef SO_SNDBUF
-	{
-		int sblen, rblen;
-
-		/* 1024 for rpc & transport overheads */
-		sblen = rblen = socksz + 1024;
-		if (setsockopt(s, SOL_SOCKET, SO_SNDBUF, &sblen, sizeof sblen) < 0 ||
-		    setsockopt(s, SOL_SOCKET, SO_RCVBUF, &rblen, sizeof rblen) < 0)
-			xlog(L_ERROR, "setsockopt failed: %s\n", strerror(errno));
-	}
-#endif				/* SO_SNDBUF */
-#endif
-
 	if (bind(s, (struct sockaddr *) &sin, sizeof(sin)) == -1) {
 		xlog(L_FATAL, "Could not bind name to socket: %s\n",
 					strerror(errno));

