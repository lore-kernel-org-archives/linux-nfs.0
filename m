From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH next-20090316] sunrpc: fix build breakage
Date: Mon, 16 Mar 2009 15:51:40 +0300
Message-ID: <20090316125140.GA3095@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:40304 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZCPMvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2009 08:51:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

net/sunrpc/clnt.c: In function 'call_bind_status':
net/sunrpc/clnt.c:994: error: 'struct rpc_task' has no member named
'tk_pid'
net/sunrpc/clnt.c: In function 'call_connect_status':
net/sunrpc/clnt.c:1051: error: 'struct rpc_task' has no member named
'tk_pid'

rpc_task has tk_pid if RPC_DEBUG is defined.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index efd0c7b..68cb91a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -990,7 +990,7 @@ call_bind_status(struct rpc_task *task)
 		return;
 	default:
 		if (net_ratelimit())
-			printk("RPC: %5u unrecognized rpcbind error (%d)\n",
+			dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
 					task->tk_pid, -task->tk_status);
 	}
 
@@ -1047,7 +1047,7 @@ call_connect_status(struct rpc_task *task)
 		break;
 	default:
 		if (net_ratelimit())
-			printk("RPC: %5u unrecognized connect error (%d)\n",
+			dprintk("RPC: %5u unrecognized connect error (%d)\n",
 					task->tk_pid, status);
 		rpc_exit(task, -EIO);
 	}
