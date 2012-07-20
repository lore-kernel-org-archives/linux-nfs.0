Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38257 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab2GTMEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jul 2012 08:04:53 -0400
Subject: [PATCH] SUNRPC: return negative value in case rpcbind client creation
	error
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 20 Jul 2012 15:57:48 +0400
Message-ID: <20120720114849.23572.91010.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without this patch kernel will panic on LockD start, because lockd_up() checks
lockd_up_net() result for negative value.
>From my pow it's better to return negative value from rpcbind routines instead
of replacing all such checks like in lockd_up().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/rpcb_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 92509ff..a70acae 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -251,7 +251,7 @@ static int rpcb_create_local_unix(struct net *net)
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
 				"client (errno %ld).\n", PTR_ERR(clnt));
-		result = -PTR_ERR(clnt);
+		result = PTR_ERR(clnt);
 		goto out;
 	}
 
@@ -298,7 +298,7 @@ static int rpcb_create_local_net(struct net *net)
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create local rpcbind "
 				"client (errno %ld).\n", PTR_ERR(clnt));
-		result = -PTR_ERR(clnt);
+		result = PTR_ERR(clnt);
 		goto out;
 	}
 

