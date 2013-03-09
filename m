Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759955Ab3CIAgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 19:36:17 -0500
Date: Fri, 8 Mar 2013 19:36:15 -0500
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: don't attempt to cancel unitialized work
Message-ID: <20130309003615.GH31448@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As of dc107402ae06286a9ed33c32daf3f35514a7cb8d "SUNRPC: make AF_LOCAL connect synchronous", we no longer initialize connect_worker in the
AF_LOCAL case, resulting in warnings like:

    WARNING: at lib/debugobjects.c:261 debug_print_object+0x8c/0xb0() Hardware name: Bochs
    ODEBUG: assert_init not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
    Modules linked in: iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi nfsd auth_rpcgss nfs_acl lockd sunrpc
    Pid: 4816, comm: nfsd Tainted: G        W    3.8.0-rc2-00049-gdc10740 #801
    Call Trace:
     [<ffffffff8156ec00>] ? free_obj_work+0x60/0xa0
     [<ffffffff81046aaf>] warn_slowpath_common+0x7f/0xc0
     [<ffffffff81046ba6>] warn_slowpath_fmt+0x46/0x50
     [<ffffffff8156eccc>] debug_print_object+0x8c/0xb0
     [<ffffffff81055030>] ? timer_debug_hint+0x10/0x10
     [<ffffffff8156f7e3>] debug_object_assert_init+0xe3/0x120
     [<ffffffff81057ebb>] del_timer+0x2b/0x80
     [<ffffffff8109c4e6>] ? mark_held_locks+0x86/0x110
     [<ffffffff81065a29>] try_to_grab_pending+0xd9/0x150
     [<ffffffff81065b57>] __cancel_work_timer+0x27/0xc0
     [<ffffffff81065c03>] cancel_delayed_work_sync+0x13/0x20
     [<ffffffffa0007067>] xs_destroy+0x27/0x80 [sunrpc]
     [<ffffffffa00040d8>] xprt_destroy+0x78/0xa0 [sunrpc]
     [<ffffffffa0006241>] xprt_put+0x21/0x30 [sunrpc]
     [<ffffffffa00030cf>] rpc_free_client+0x10f/0x1a0 [sunrpc]
     [<ffffffffa0002ff3>] ? rpc_free_client+0x33/0x1a0 [sunrpc]
     [<ffffffffa0002f7e>] rpc_release_client+0x6e/0xb0 [sunrpc]
     [<ffffffffa000325d>] rpc_shutdown_client+0xfd/0x1b0 [sunrpc]
     [<ffffffffa0017196>] rpcb_put_local+0x106/0x130 [sunrpc]
    ...

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c1d8476..35fc805 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -849,6 +849,14 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
 		xs_tcp_shutdown(xprt);
 }
 
+xs_local_destroy(struct rpc_xprt *xprt)
+{
+	xs_close(xprt);
+	xs_free_peer_addresses(xprt);
+	xprt_free(xprt);
+	module_put(THIS_MODULE);
+}
+
 /**
  * xs_destroy - prepare to shutdown a transport
  * @xprt: doomed transport
@@ -862,10 +870,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	cancel_delayed_work_sync(&transport->connect_worker);
 
-	xs_close(xprt);
-	xs_free_peer_addresses(xprt);
-	xprt_free(xprt);
-	module_put(THIS_MODULE);
+	xs_local_destroy(xprt);
 }
 
 static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
@@ -2482,7 +2487,7 @@ static struct rpc_xprt_ops xs_local_ops = {
 	.send_request		= xs_local_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_close,
-	.destroy		= xs_destroy,
+	.destroy		= xs_local_destroy,
 	.print_stats		= xs_local_print_stats,
 };
 
-- 
1.7.9.5

