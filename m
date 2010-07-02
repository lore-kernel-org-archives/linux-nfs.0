From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/22] SUNRPC: Correct an rpcbind debugging message
Date: Fri, 02 Jul 2010 13:18:48 -0400
Message-ID: <20100702171848.8761.77163.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:64957 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759321Ab0GBRSv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:18:51 -0400
Received: by pxi14 with SMTP id 14so907723pxi.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:18:51 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 

