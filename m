From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/30] SUNRPC: Always report 'unrecognised error' cases...
Date: Wed, 11 Mar 2009 14:41:10 -0400
Message-ID: <20090311184110.5578.95835.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6546 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928AbZCKSpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:42 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj6iD022202
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:40 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5abab09..efd0c7b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -27,6 +27,7 @@
 #include <linux/types.h>
 #include <linux/kallsyms.h>
 #include <linux/mm.h>
+#include <linux/net.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
 #include <linux/utsname.h>
@@ -988,8 +989,9 @@ call_bind_status(struct rpc_task *task)
 		task->tk_action = call_bind;
 		return;
 	default:
-		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
-				task->tk_pid, -task->tk_status);
+		if (net_ratelimit())
+			printk("RPC: %5u unrecognized rpcbind error (%d)\n",
+					task->tk_pid, -task->tk_status);
 	}
 
 	rpc_exit(task, status);
@@ -1044,6 +1046,9 @@ call_connect_status(struct rpc_task *task)
 		task->tk_action = call_timeout;
 		break;
 	default:
+		if (net_ratelimit())
+			printk("RPC: %5u unrecognized connect error (%d)\n",
+					task->tk_pid, status);
 		rpc_exit(task, -EIO);
 	}
 }

