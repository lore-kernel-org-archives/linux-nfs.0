Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65003 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab0IJUI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:08:59 -0400
Received: by mail-yx0-f174.google.com with SMTP id 4so1305439yxp.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:08:59 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] SUNRPC: Correct an rpcbind debugging message
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:08:56 -0400
Message-ID: <20100910200856.13321.20475.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
References: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index c961094..63ec116 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -211,8 +211,9 @@ static int rpcb_create_local(void)
 	 */
 	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
 	if (IS_ERR(clnt4)) {
-		dprintk("RPC:       failed to create local rpcbind v4 "
-				"cleint (errno %ld).\n", PTR_ERR(clnt4));
+		dprintk("RPC:       failed to bind second program to "
+				"rpcbind v4 client (errno %ld).\n",
+				PTR_ERR(clnt4));
 		clnt4 = NULL;
 	}
 

