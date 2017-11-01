Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:12952 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751587AbdKATyK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Nov 2017 15:54:10 -0400
From: Anna.Schumaker@Netapp.com
To: <linux-nfs@vger.kernel.org>
CC: <davej@codemonkey.org.uk>
Subject: [PATCH] NFS: Avoid RCU usage in tracepoints
Date: Wed,  1 Nov 2017 15:53:51 -0400
Message-ID: <20171101195351.13881-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

There isn't an obvious way to acquire and release the RCU lock during a
tracepoint, so we can't use the rpc_peeraddr2str() function here.
Instead, rely on the client's cl_hostname, which should have similar
enough information without needing an rcu_dereference().

Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4trace.h | 24 ++++++------------------
 1 file changed, 6 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b9962d93e746..06ac7156c44b 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -201,17 +201,13 @@ DECLARE_EVENT_CLASS(nfs4_clientid_event,
 		TP_ARGS(clp, error),
 
 		TP_STRUCT__entry(
-			__string(dstaddr,
-				rpc_peeraddr2str(clp->cl_rpcclient,
-					RPC_DISPLAY_ADDR))
+			__string(dstaddr, clp->cl_hostname)
 			__field(int, error)
 		),
 
 		TP_fast_assign(
 			__entry->error = error;
-			__assign_str(dstaddr,
-				rpc_peeraddr2str(clp->cl_rpcclient,
-						RPC_DISPLAY_ADDR));
+			__assign_str(dstaddr, clp->cl_hostname);
 		),
 
 		TP_printk(
@@ -1134,9 +1130,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_callback_event,
 			__field(dev_t, dev)
 			__field(u32, fhandle)
 			__field(u64, fileid)
-			__string(dstaddr, clp ?
-				rpc_peeraddr2str(clp->cl_rpcclient,
-					RPC_DISPLAY_ADDR) : "unknown")
+			__string(dstaddr, clp ? clp->cl_hostname : "unknown")
 		),
 
 		TP_fast_assign(
@@ -1149,9 +1143,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_callback_event,
 				__entry->fileid = 0;
 				__entry->dev = 0;
 			}
-			__assign_str(dstaddr, clp ?
-				rpc_peeraddr2str(clp->cl_rpcclient,
-					RPC_DISPLAY_ADDR) : "unknown")
+			__assign_str(dstaddr, clp ? clp->cl_hostname : "unknown")
 		),
 
 		TP_printk(
@@ -1193,9 +1185,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_stateid_callback_event,
 			__field(dev_t, dev)
 			__field(u32, fhandle)
 			__field(u64, fileid)
-			__string(dstaddr, clp ?
-				rpc_peeraddr2str(clp->cl_rpcclient,
-					RPC_DISPLAY_ADDR) : "unknown")
+			__string(dstaddr, clp ? clp->cl_hostname : "unknown")
 			__field(int, stateid_seq)
 			__field(u32, stateid_hash)
 		),
@@ -1210,9 +1200,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_stateid_callback_event,
 				__entry->fileid = 0;
 				__entry->dev = 0;
 			}
-			__assign_str(dstaddr, clp ?
-				rpc_peeraddr2str(clp->cl_rpcclient,
-					RPC_DISPLAY_ADDR) : "unknown")
+			__assign_str(dstaddr, clp ? clp->cl_hostname : "unknown")
 			__entry->stateid_seq =
 				be32_to_cpu(stateid->seqid);
 			__entry->stateid_hash =
-- 
2.15.0

