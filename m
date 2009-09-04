From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 01/10] nfsd41: sunrpc: move struct rpc_buffer def into sunrpc.h
Date: Fri,  4 Sep 2009 19:31:19 +0300
Message-ID: <1252081879-19460-1-git-send-email-bhalevy@panasas.com>
References: <4AA13DE3.8020800@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:6649 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754725AbZIDQbV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 12:31:21 -0400
In-Reply-To: <4AA13DE3.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move struct rpc_buffer's definition into a sunrpc.h, a common, internal
header file, in preparation for supporting the nfsv4.1 backchannel.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: sunrpc: #include <linux/net.h> from sunrpc.h]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/sched.c  |    7 ++-----
 net/sunrpc/sunrpc.h |   10 ++++++++++
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 8f459ab..cef74ba 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -21,6 +21,8 @@
 
 #include <linux/sunrpc/clnt.h>
 
+#include "sunrpc.h"
+
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY		RPCDBG_SCHED
 #define RPC_TASK_MAGIC_ID	0xf00baa
@@ -711,11 +713,6 @@ static void rpc_async_schedule(struct work_struct *work)
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
 }
 
-struct rpc_buffer {
-	size_t	len;
-	char	data[];
-};
-
 /**
  * rpc_malloc - allocate an RPC buffer
  * @task: RPC task that will use this buffer
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index 5d9dd74..13171e6 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -27,6 +27,16 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #ifndef _NET_SUNRPC_SUNRPC_H
 #define _NET_SUNRPC_SUNRPC_H
 
+#include <linux/net.h>
+
+/*
+ * Header for dynamically allocated rpc buffers.
+ */
+struct rpc_buffer {
+	size_t	len;
+	char	data[];
+};
+
 static inline int rpc_reply_expected(struct rpc_task *task)
 {
 	return (task->tk_msg.rpc_proc != NULL) &&
-- 
1.6.4

