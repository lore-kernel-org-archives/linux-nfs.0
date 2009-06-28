From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: nfsd41: sunrpc: move struct rpc_buffer def into a common header file
Date: Sun, 28 Jun 2009 19:20:27 +0300
Message-ID: <1246206027-13990-1-git-send-email-bhalevy@panasas.com>
References: <4A3F7DB9.9030701@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:7276
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752771AbZF1QU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 12:20:29 -0400
In-Reply-To: <4A3F7DB9.9030701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct rpc_buffer is currently defined twice, the same way, in sched.c
and xprtsock.c.  Move its definition into a sunrpc.h, a common, internal
header file.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/sched.c    |    7 ++-----
 net/sunrpc/sunrpc.h   |    8 ++++++++
 net/sunrpc/xprtsock.c |    4 ----
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 1102ce1..a90855a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -22,6 +22,8 @@
 
 #include <linux/sunrpc/clnt.h>
 
+#include "sunrpc.h"
+
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY		RPCDBG_SCHED
 #define RPC_TASK_MAGIC_ID	0xf00baa
@@ -712,11 +714,6 @@ static void rpc_async_schedule(struct work_struct *work)
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
index b1b2e64..7b68daf 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -27,6 +27,14 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #ifndef _NET_SUNRPC_SUNRPC_H
 #define _NET_SUNRPC_SUNRPC_H
 
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
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 042c421..78ec5c8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2158,10 +2158,6 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.bklog_u);
 }
 
-struct rpc_buffer {
-	size_t	len;
-	char	data[];
-};
 /*
  * Allocate a bunch of pages for a scratch buffer for the rpc code. The reason
  * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
-- 
1.6.3.3

