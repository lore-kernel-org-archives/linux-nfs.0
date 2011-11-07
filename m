Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34860 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352Ab1KGTEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Nov 2011 14:04:08 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/1] RPC: print warning before hanging due to bad server reply
Date: Mon,  7 Nov 2011 14:04:03 -0500
Message-Id: <1320692643-27423-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a server incorrectly returns RPC_PROG_MISMATCH in the midst
of nfsv4 traffic, the client will hang in various difficult to
debug states.  Change a dprintk to a printk to ensure a
relevant log message is sent in this case.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 net/sunrpc/clnt.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c5347d2..2d9b77e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -31,6 +31,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/un.h>
+#include <linux/ratelimit.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -1736,8 +1737,9 @@ rpc_verify_header(struct rpc_task *task)
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
-		dprintk("RPC: %5u %s: program %u, version %u unsupported by "
-				"server %s\n", task->tk_pid, __func__,
+		printk_ratelimited("RPC: %5u %s: program %u, version %u "
+				"unsupported by server %s\n",
+				task->tk_pid, __func__,
 				(unsigned int)task->tk_client->cl_prog,
 				(unsigned int)task->tk_client->cl_vers,
 				task->tk_client->cl_server);
-- 
1.7.2.1

