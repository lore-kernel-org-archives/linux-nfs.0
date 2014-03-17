Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:53024 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaCQSkw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 14:40:52 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so5969394iec.9
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 11:40:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Ensure that call_bind times out correctly
Date: Mon, 17 Mar 2014 14:40:45 -0400
Message-Id: <1395081645-11906-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the rpcbind server is unavailable, we still want the RPC client
to respect the timeout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f22d3a115fda..53a13835b90f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1728,9 +1728,7 @@ call_bind_status(struct rpc_task *task)
 	case -EPROTONOSUPPORT:
 		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
 				task->tk_pid);
-		task->tk_status = 0;
-		task->tk_action = call_bind;
-		return;
+		goto retry_timeout;
 	case -ECONNREFUSED:		/* connection problems */
 	case -ECONNRESET:
 	case -ECONNABORTED:
@@ -1756,6 +1754,7 @@ call_bind_status(struct rpc_task *task)
 	return;
 
 retry_timeout:
+	task->tk_status = 0;
 	task->tk_action = call_timeout;
 }
 
-- 
1.8.5.3

