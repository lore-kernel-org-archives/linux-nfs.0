From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/7] SUNRPC: xprt_autoclose() should not call
	xprt_disconnect()
Date: Tue, 06 Nov 2007 19:40:01 -0500
Message-ID: <20071107004001.13713.508.stgit@heimdal.trondhjem.org>
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
	id 1IpYvk-0002Q6-PV
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:05 -0800
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpYvp-0005E4-SJ
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:10 -0800
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

The transport layer should do that itself whenever appropriate.

Note that the RDMA transport already assumes that it needs to call
xprt_disconnect in xprt_rdma_close().
For TCP sockets, we want to call xprt_disconnect() only after the
connection has been closed by both ends.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c     |    1 -
 net/sunrpc/xprtsock.c |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48c5a8b..fcdc4b8 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -568,7 +568,6 @@ static void xprt_autoclose(struct work_struct *work)
 	struct rpc_xprt *xprt =
 		container_of(work, struct rpc_xprt, task_cleanup);
 
-	xprt_disconnect(xprt);
 	xprt->ops->close(xprt);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt_release_write(xprt, NULL);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d610d28..c0aa2b4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -786,10 +786,10 @@ static void xs_close(struct rpc_xprt *xprt)
 	sock_release(sock);
 clear_close_wait:
 	smp_mb__before_clear_bit();
-	clear_bit(XPRT_CONNECTED, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
+	xprt_disconnect(xprt);
 }
 
 /**
@@ -805,7 +805,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	cancel_rearming_delayed_work(&transport->connect_worker);
 
-	xprt_disconnect(xprt);
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
 	kfree(xprt->slot);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
