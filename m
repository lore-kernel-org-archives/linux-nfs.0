From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/7] SUNRPC: Fix a race in xs_tcp_state_change()
Date: Tue, 06 Nov 2007 19:39:40 -0500
Message-ID: <20071107003940.13713.65472.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpYw8-0002SS-VC
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:29 -0800
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpYwE-000512-Ew
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:34 -0800
In-Reply-To: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

When scheduling the autoclose RPC call, we want to ensure that we don't
race against the test_bit() call in xprt_clear_locked().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |   20 ++++++++++++++++++++
 net/sunrpc/xprtsock.c       |    5 +----
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 30b17b3..6f524a9 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -246,6 +246,7 @@ struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect(struct rpc_xprt *xprt);
+void			xprt_force_disconnect(struct rpc_xprt *xprt);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 282a9a2..48c5a8b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -570,6 +570,7 @@ static void xprt_autoclose(struct work_struct *work)
 
 	xprt_disconnect(xprt);
 	xprt->ops->close(xprt);
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt_release_write(xprt, NULL);
 }
 
@@ -588,6 +589,25 @@ void xprt_disconnect(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect);
 
+/**
+ * xprt_force_disconnect - force a transport to disconnect
+ * @xprt: transport to disconnect
+ *
+ */
+void xprt_force_disconnect(struct rpc_xprt *xprt)
+{
+	/* Don't race with the test_bit() in xprt_clear_locked() */
+	spin_lock_bh(&xprt->transport_lock);
+	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	/* Try to schedule an autoclose RPC call */
+	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
+		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	else if (xprt->snd_task != NULL)
+		rpc_wake_up_task(xprt->snd_task);
+	spin_unlock_bh(&xprt->transport_lock);
+}
+EXPORT_SYMBOL_GPL(xprt_force_disconnect);
+
 static void
 xprt_init_autodisconnect(unsigned long data)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 02298f5..322e4e2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1118,10 +1118,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_SYN_RECV:
 		break;
 	case TCP_CLOSE_WAIT:
-		/* Try to schedule an autoclose RPC calls */
-		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
-		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-			queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		xprt_force_disconnect(xprt);
 	default:
 		xprt_disconnect(xprt);
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
