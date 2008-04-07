From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Fix memory leak introduced by commit 510deb0d
Date: Mon, 07 Apr 2008 16:52:44 -0400
Message-ID: <20080407205211.3187.31966.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:5059 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbYDHUQH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 16:16:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 510deb0d was supposed to move the xprt_create_transport() call in
rpc_create(), but neglected to remove the old call site.  This resulted in
a transport leak after every rpc_create() call.

This leak is present in 2.6.24 and 2.6.25.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d0f04c8..dd39a39 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -260,10 +260,6 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	};
 	char servername[48];
 
-	xprt = xprt_create_transport(&xprtargs);
-	if (IS_ERR(xprt))
-		return (struct rpc_clnt *)xprt;
-
 	/*
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.

