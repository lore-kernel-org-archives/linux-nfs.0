Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757262Ab3CIOBK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Mar 2013 09:01:10 -0500
Date: Sat, 9 Mar 2013 09:01:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: sunrpc ODEBUG assertion.
Message-ID: <20130309140107.GI31448@fieldses.org>
References: <20130309025949.GA14176@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130309025949.GA14176@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 08, 2013 at 09:59:49PM -0500, Dave Jones wrote:
> restarted my nfs server, and mounted it from a Mac, and got this..
> 
> 
> [47433.585266] WARNING: at lib/debugobjects.c:260 debug_print_object+0x8c/0xb0()

Thanks for the report.  It's a known issue.  I'd like Trond to either
take this or ACK (or NAK) this.

--b.

commit dc329cfb5c68c62db56b78b67ee45c3ef24df7d6
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 8 13:13:08 2013 -0500

    sunrpc: don't attempt to cancel unitialized work
    
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
 
