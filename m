From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 2.5.60] Clean up and fix SMP issue w.r.t. XID allocation
Date: Thu, 13 Feb 2003 15:52:50 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15947.45378.421333.627616@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>


The following problem was identified by Olaf Kirch. In
xprt_request_init(), the XID allocation needs to be protected by a
global spinlock.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.60-00-fix_pipes/net/sunrpc/xprt.c linux-2.5.60-01-fix_xid/net/sunrpc/xprt.c
--- linux-2.5.60-00-fix_pipes/net/sunrpc/xprt.c	2003-01-12 22:39:48.000000000 +0100
+++ linux-2.5.60-01-fix_xid/net/sunrpc/xprt.c	2003-02-13 14:17:10.000000000 +0100
@@ -1273,25 +1273,41 @@
 }
 
 /*
+ * Allocate a 'unique' XID
+ */
+static u32
+xprt_alloc_xid(void)
+{
+	static spinlock_t xid_lock = SPIN_LOCK_UNLOCKED;
+	static int need_init = 1;
+	static u32 xid;
+	u32 ret;
+
+	spin_lock(&xid_lock);
+	if (unlikely(need_init)) {
+		xid = get_seconds() << 12;
+		need_init = 0;
+	}
+	ret = xid++;
+	spin_unlock(&xid_lock);
+	return ret;
+}
+
+/*
  * Initialize RPC request
  */
 static void
 xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
-	static u32	xid = 0;
-
-	if (!xid)
-		xid = get_seconds() << 12;
 
-	dprintk("RPC: %4d reserved req %p xid %08x\n", task->tk_pid, req, xid);
 	req->rq_timeout = xprt->timeout;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
-	req->rq_xid     = xid++;
-	if (!xid)
-		xid++;
+	req->rq_xid     = xprt_alloc_xid();
 	INIT_LIST_HEAD(&req->rq_list);
+	dprintk("RPC: %4d reserved req %p xid %08x\n", task->tk_pid,
+			req, req->rq_xid);
 }
 
 /*
