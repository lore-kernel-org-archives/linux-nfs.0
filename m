Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33981 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbIPLRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 07:17:35 -0400
Received: by ykdg206 with SMTP id g206so214815589ykd.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 04:17:34 -0700 (PDT)
Date: Wed, 16 Sep 2015 07:17:30 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "Suzuki K. Poulose" <suzuki.poulose@arm.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, marc.zyngier@arm.com
Subject: Re: [PATCHv2] SUNRPC: Fix a race in xs_reset_transport
Message-ID: <20150916071730.052af53d@tlielax.poochiereds.net>
In-Reply-To: <1442396149-24775-1-git-send-email-suzuki.poulose@arm.com>
References: <1442394280-24280-1-git-send-email-suzuki.poulose@arm.com>
	<1442396149-24775-1-git-send-email-suzuki.poulose@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Sep 2015 10:35:49 +0100
"Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:

> From: "Suzuki K. Poulose" <suzuki.poulose@arm.com>
> 
> Ignore the previous patch, which was really v1.
> 
> ---
> 
> Encountered the following BUG() with 4.3-rc1 on a fast model
> for arm64 with NFS root filesystem.
> 
> ------------[ cut here ]------------
> kernel BUG at fs/inode.c:1493!
> 
> Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.3.0-rc1+ #855
> Hardware name: FVP Base (DT)
> task: ffffc000760b0000 ti: ffffc00076070000 task.ti: ffffc00076070000
> PC is at iput+0x144/0x170
> LR is at sock_release+0xbc/0xdc
> pc : [<ffffc000001b4920>] lr : [<ffffc000004d1974>] pstate: 40000045
> sp : ffffc00076073790
> x29: ffffc00076073790 x28: ffffc00076073b40
> x27: 00000000000003e8 x26: ffffc00076955000
> x25: 000000000000000c x24: ffffc00076637200
> x23: ffffc00076073930 x22: ffffc000769b8180
> x21: ffffc000740500a8 x20: ffffc00074050158
> x19: ffffc00074050030 x18: 000000009fcef6bf
> x17: 00000000593e3df5 x16: 00000000b597f71d
> x15: 00000000e2f9d3f6 x14: 0ffffffffffffffe
> x13: 0000000000000020 x12: 0101010101010101
> x11: 00000000000001c9 x10: 0000000000000750
> x9 : ffffc00076073670 x8 : ffffc000760b07b0
> x7 : 0000000000000001 x6 : 0000000000000001
> x5 : 0000000000000000 x4 : 00000000ffffffff
> x3 : 0000000000000000 x2 : ffffffffffffffff
> x1 : ffffc00076070000 x0 : 0000000000000060
> 
> Process swapper/0 (pid: 1, stack limit = 0xffffc00076070020)
> Stack: (0xffffc00076073790 to 0xffffc00076074000)
> 
>  [ stack contents stripped ]
> 
> Call trace:
> [<ffffc000001b4920>] iput+0x144/0x170
> [<ffffc000004d1970>] sock_release+0xb8/0xdc
> [<ffffc00000578df0>] xs_reset_transport+0x8c/0xac
> [<ffffc00000578e60>] xs_close+0x50/0x6c
> [<ffffc00000578e9c>] xs_destroy+0x20/0x5c
> [<ffffc00000575f70>] xprt_destroy+0x68/0x8c
> [<ffffc0000057777c>] xprt_put+0x24/0x30
> [<ffffc000005726c4>] rpc_free_client+0x78/0xd8
> [<ffffc0000057288c>] rpc_release_client+0x94/0xec
> [<ffffc00000572aac>] rpc_shutdown_client+0x58/0x118
> [<ffffc00000278588>] nfs_mount+0x100/0x234
> [<ffffc0000026cc88>] nfs_request_mount+0xa8/0x12c
> [<ffffc0000026e564>] nfs_try_mount+0x54/0x2b4
> [<ffffc0000026f140>] nfs_fs_mount+0x5cc/0xac0
> [<ffffc0000019f1a0>] mount_fs+0x38/0x158
> [<ffffc000001b81a8>] vfs_kern_mount+0x48/0x11c
> [<ffffc000001bb390>] do_mount+0x208/0xc04
> [<ffffc000001bc0b0>] SyS_mount+0x78/0xd0
> [<ffffc000007f0fa8>] mount_root+0x80/0x148
> [<ffffc000007f11a8>] prepare_namespace+0x138/0x184
> [<ffffc000007f0b20>] kernel_init_freeable+0x1cc/0x1f4
> [<ffffc000005a2914>] kernel_init+0xc/0xd8
> Code: b5fffc00 17ffffed d4210000 17ffffd7 (d4210000)
> ---[ end trace 02951451f1831f54 ]---
> 
> With rpc_debug enabled here is the log :
> 
> RPC:       shutting down mount client for your.nfs.server
> RPC:       rpc_release_client(ffffc00076637800)
> RPC:       destroying UNIX authenticator ffffc000008f48c8
> RPC:       destroying mount client for your.nfs.server
> RPC:       destroying transport ffffc00076226000
> RPC:       xs_destroy xprt ffffc00076226000
> RPC:       xs_close xprt ffffc00076226000
> RPC:       xs_tcp_state_change client ffffc00076226000...
> RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
> RPC:       xs_tcp_state_change client ffffc00076226000...
> RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       xs_tcp_state_change client ffffc00076226000...
> RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       disconnected transport ffffc00076226000
> RPC:       xs_tcp_state_change client ffffc00076226000...
> RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       disconnected transport ffffc00076226000
> RPC:       xs_tcp_data_ready...
> RPC:       xs_tcp_state_change client ffffc00076226000...
> RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       disconnected transport ffffc00076226000
> RPC:       wake_up_first(ffffc00076226170 "xprt_sending")
> 
> So it looks like just before we lock the callbacks in xs_reset_transport,
> a few of the callbacks got through and issued the reset before we could
> lock it. And we end up repeating the cleanups, ending up in the above
> BUG() due to multiple sock_release().
> 
> This patch fixes the race by confirming that somebody else hasn't performed
> the reset while we were waiting for the lock. Also, the transport->sock is
> only accessed within the lock to prevent using a stale sock for kernel_sock_shutdown().
> 
> Signed-off-by: Suzuki K. Poulose <suzuki.poulose@arm.com>
> ---
> Changes since V1:
>   - Prevent race in accessing sock.
> ---
>  net/sunrpc/xprtsock.c |   15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc..b95f5d0 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -812,7 +812,7 @@ static void xs_error_report(struct sock *sk)
>  
>  static void xs_reset_transport(struct sock_xprt *transport)
>  {
> -	struct socket *sock = transport->sock;
> +	struct socket *sock;
>  	struct sock *sk = transport->inet;
>  	struct rpc_xprt *xprt = &transport->xprt;
>  
> @@ -822,9 +822,14 @@ static void xs_reset_transport(struct sock_xprt *transport)
>  	if (atomic_read(&transport->xprt.swapper))
>  		sk_clear_memalloc(sk);
>  
> -	kernel_sock_shutdown(sock, SHUT_RDWR);
> -
>  	write_lock_bh(&sk->sk_callback_lock);
> +	/* Check someone has already done the job, while we were waiting */
> +	if (!transport->inet) {
> +		write_unlock_bh(&sk->sk_callback_lock);
> +		return;
> +	}
> +	sock = transport->sock;
> +
>  	transport->inet = NULL;
>  	transport->sock = NULL;
>  
> @@ -833,6 +838,10 @@ static void xs_reset_transport(struct sock_xprt *transport)
>  	xs_restore_old_callbacks(transport, sk);
>  	xprt_clear_connected(xprt);
>  	write_unlock_bh(&sk->sk_callback_lock);
> +
> +	if (sock)
> +		kernel_sock_shutdown(sock, SHUT_RDWR);
> +
>  	xs_sock_reset_connection_flags(xprt);
>  
>  	trace_rpc_socket_close(xprt, sock);

Better, but now I'm wondering...is it problematic to restore the old
callbacks before calling kernel_sock_shutdown? I can't quite tell
whether it matters in all cases.

It might be best to just go ahead and take the spinlock twice here. Do
it once to clear the transport->sock pointer, call
kernel_sock_shutdown, and then take it again to restore the old
callbacks, etc.

I don't know though...I get the feeling there are races all over the
place in this code. It seems like there's a similar one wrt to the
transport->inet pointer. It seems a little silly that we clear it under
the sk->sk_callback_lock. You have to dereference that pointer
in order to get to the lock.

Maybe the right solution is to use an xchg to swap the inet pointer
with NULL so it can act as a gatekeeper. Whoever gets there first does
the rest of the shutdown.

Something like this maybe? Would this also fix the original problem?
Note that this patch is untested...

[PATCH] sunrpc: use xchg to fetch and clear the transport->inet pointer in xs_reset_transport

Reported-by: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7be90bc1a7c2..57f79dcab493 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -813,9 +813,10 @@ static void xs_error_report(struct sock *sk)
 static void xs_reset_transport(struct sock_xprt *transport)
 {
 	struct socket *sock = transport->sock;
-	struct sock *sk = transport->inet;
+	struct sock *sk;
 	struct rpc_xprt *xprt = &transport->xprt;
 
+	sk = xchg(&transport->inet, NULL);
 	if (sk == NULL)
 		return;
 
@@ -825,7 +826,6 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	kernel_sock_shutdown(sock, SHUT_RDWR);
 
 	write_lock_bh(&sk->sk_callback_lock);
-	transport->inet = NULL;
 	transport->sock = NULL;
 
 	sk->sk_user_data = NULL;
-- 
2.4.3

