Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:57871 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752229AbbIRLQx convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Sep 2015 07:16:53 -0400
Message-ID: <55FBF29D.5060708@arm.com>
Date: Fri, 18 Sep 2015 12:16:45 +0100
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>
CC: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a race in xs_reset_transport
References: <1442332163-9230-1-git-send-email-suzuki.poulose@arm.com>	 <20150915145229.4e69d5f7@synchrony.poochiereds.net>	 <CAHQdGtTzHbuBQTdW7vfxpOzET8hOQrXV-AE1Px7rNwu1zBMKNw@mail.gmail.com>	 <20150917101847.74ee85ac@synchrony.poochiereds.net> <1442501401.12852.1.camel@primarydata.com>
In-Reply-To: <1442501401.12852.1.camel@primarydata.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17/09/15 15:50, Trond Myklebust wrote:
> On Thu, 2015-09-17 at 10:18 -0400, Jeff Layton wrote:
>> On Thu, 17 Sep 2015 09:38:33 -0400
>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>>> On Tue, Sep 15, 2015 at 2:52 PM, Jeff Layton <
>>> jlayton@poochiereds.net> wrote:
>>>> On Tue, 15 Sep 2015 16:49:23 +0100
>>>> "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
>>>>
>>>>>   net/sunrpc/xprtsock.c |    9 ++++++++-
>>>>>   1 file changed, 8 insertions(+), 1 deletion(-)
>>>>>

...

>>
>> IDGI -- if the XPRT_LOCKED bit was supposed to prevent that, then
>> how could you hit the original race? There should be no concurrent
>> callers to xs_reset_transport on the same xprt, right?
>
> Correct. The only exception is xs_destroy.
>
>> AFAICT, that bit is not set in the xprt_destroy codepath, which may
>> be
>> the root cause of the problem. How would we take it there anyway?
>> xprt_destroy is void return, and may not be called in the context of
>> a
>> rpc_task. If it's contended,  what do we do? Sleep until it's
>> cleared?
>>
>
> How about the following.
>
> 8<-----------------------------------------------------------------
>  From e2e68218e66c6b0715fd6b8f1b3092694a7c0e62 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 17 Sep 2015 10:42:27 -0400
> Subject: [PATCH] SUNRPC: Fix races between socket connection and destroy code
>
> When we're destroying the socket transport, we need to ensure that
> we cancel any existing delayed connection attempts, and order them
> w.r.t. the call to xs_close().
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>   net/sunrpc/xprtsock.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc1a7c2..d2dfbd043bea 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -881,8 +881,11 @@ static void xs_xprt_free(struct rpc_xprt *xprt)
>    */
>   static void xs_destroy(struct rpc_xprt *xprt)
>   {
> +	struct sock_xprt *transport = container_of(xprt,
> +			struct sock_xprt, xprt);
>   	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
>
> +	cancel_delayed_work_sync(&transport->connect_worker);
>   	xs_close(xprt);
>   	xs_xprt_free(xprt);
>   	module_put(THIS_MODULE);


That doesn't fix it for me:

Root-NFS: nfsroot=/work/local/data/rootfs/arm64-rootfs-fvp,tcp,vers=2
NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,tcp,vers=2,nolock,addr=your.nfs.server'
NFS:   parsing nfs mount option 'vers=2'
NFS:   parsing nfs mount option 'udp'
NFS:   parsing nfs mount option 'rsize=4096'
NFS:   parsing nfs mount option 'wsize=4096'
NFS:   parsing nfs mount option 'tcp'
NFS:   parsing nfs mount option 'vers=2'
NFS:   parsing nfs mount option 'nolock'
NFS:   parsing nfs mount option 'addr=your.nfs.server'
NFS: MNTPATH: '/work/local/data/rootfs/arm64-rootfs-fvp'
NFS: sending MNT request for your.nfs.server:/work/local/data/rootfs/arm64-rootfs-fvp
RPC:       set up xprt to your.nfs.server (autobind) via tcp
RPC:       created transport ffff800077e9d000 with 65536 slots
RPC:       creating mount client for your.nfs.server (xprt ffff800077e9d000)
RPC:       creating UNIX authenticator for client ffff8000787a7800
RPC:       new task initialized, procpid 1
RPC:       allocated task ffff800077f63600
RPC:     1 __rpc_execute flags=0x680
RPC:     1 call_start mount1 proc NULL (sync)
RPC:     1 call_reserve (status 0)
RPC:     1 reserved req ffff8000787a7600 xid b188dcac
RPC:       wake_up_first(ffff800077e9d170 "xprt_sending")
RPC:     1 call_reserveresult (status 0)
RPC:     1 call_refresh (status 0)
RPC:     1 holding NULL cred ffff8000008e2e68
RPC:     1 refreshing NULL cred ffff8000008e2e68
RPC:     1 call_refreshresult (status 0)
RPC:     1 call_allocate (status 0)
RPC:     1 allocated buffer of size 96 at ffff800077e9d800
RPC:     1 call_bind (status 0)
RPC:     1 rpcb_getport_async(your.nfs.server, 100005, 1, 6)
RPC:     1 sleep_on(queue "xprt_binding" time 4294937393)
RPC:     1 added to queue ffff800077e9d0c8 "xprt_binding"
RPC:     1 setting alarm for 60000 ms
RPC:     1 rpcb_getport_async: trying rpcbind version 2
RPC:       set up xprt to your.nfs.server (port 111) via tcp
RPC:       created transport ffff800077e9e000 with 65536 slots
RPC:       creating rpcbind client for your.nfs.server (xprt ffff800077e9e000)
RPC:       creating UNIX authenticator for client ffff800078688000
RPC:       new task initialized, procpid 1
RPC:       allocated task ffff800077f63800
RPC:       rpc_release_client(ffff800078688000)
RPC:     2 __rpc_execute flags=0x681
RPC:     2 call_start rpcbind2 proc GETPORT (async)
RPC:     2 call_reserve (status 0)
RPC:     2 reserved req ffff8000787a7e00 xid 591ea4ad
RPC:       wake_up_first(ffff800077e9e170 "xprt_sending")
RPC:     2 call_reserveresult (status 0)
RPC:     2 call_refresh (status 0)
RPC:     2 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:       allocating UNIX cred for uid 0 gid 0
RPC:     2 refreshing UNIX cred ffff800077ee5e40
RPC:     2 call_refreshresult (status 0)
RPC:     2 call_allocate (status 0)
RPC:     2 allocated buffer of size 512 at ffff800077e9e800
RPC:     2 call_bind (status 0)
RPC:     2 call_connect xprt ffff800077e9e000 is not connected
RPC:     2 xprt_connect xprt ffff800077e9e000 is not connected
RPC:     2 sleep_on(queue "xprt_pending" time 4294937393)
RPC:     2 added to queue ffff800077e9e218 "xprt_pending"
RPC:     2 setting alarm for 60000 ms
RPC:       xs_connect scheduled xprt ffff800077e9e000
RPC:       worker connecting xprt ffff800077e9e000 via tcp to your.nfs.server (port 111)
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
RPC:     2 __rpc_wake_up_task (now 4294937393)
RPC:     2 disabling timer
RPC:     2 removed from queue ffff800077e9e218 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       ffff800077e9e000 connect status 115 connected 1 sock state 1
RPC:       wake_up_first(ffff800077e9e170 "xprt_sending")
RPC:     2 __rpc_execute flags=0x681
RPC:     2 xprt_connect_status: retrying
RPC:     2 call_connect_status (status -11)
RPC:     2 call_timeout (minor)
RPC:     2 call_bind (status 0)
RPC:     2 call_connect xprt ffff800077e9e000 is connected
RPC:     2 call_transmit (status 0)
RPC:     2 xprt_prepare_transmit
RPC:     2 rpc_xdr_encode (status 0)
RPC:     2 marshaling UNIX cred ffff800077ee5e40
RPC:     2 using AUTH_UNIX cred ffff800077ee5e40 to wrap rpc data
RPC:     2 encoding PMAP_GETPORT call (100005, 1, 6, 0)
RPC:     2 xprt_transmit(92)
RPC:       xs_tcp_data_ready...
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 28
RPC:       reading XID (4 bytes)
RPC:       reading request with XID 591ea4ad
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 591ea4ad
RPC:       XID 591ea4ad read 20 bytes
RPC:       xprt = ffff800077e9e000, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
RPC:     2 xid 591ea4ad complete (28 bytes received)
RPC:       xs_tcp_data_recv done
RPC:       xs_tcp_send_request(92) = 0
RPC:     2 xmit complete
RPC:       wake_up_first(ffff800077e9e170 "xprt_sending")
RPC:     2 call_status (status 28)
RPC:     2 call_decode (status 28)
RPC:     2 validating UNIX cred ffff800077ee5e40
RPC:     2 using AUTH_UNIX cred ffff800077ee5e40 to unwrap rpc data
RPC:     2 PMAP_GETPORT result: 58401
RPC:     2 call_decode result 0
RPC:       setting port for xprt ffff800077e9d000 to 58401
RPC:     2 rpcb_getport_done(status 0, port 58401)
RPC:     2 return 0, status 0
RPC:     2 release task
RPC:       freeing buffer of size 512 at ffff800077e9e800
RPC:     2 release request ffff8000787a7e00
RPC:       wake_up_first(ffff800077e9e2c0 "xprt_backlog")
RPC:       rpc_release_client(ffff800078688000)
RPC:       destroying rpcbind client for your.nfs.server
RPC:       destroying transport ffff800077e9e000
RPC:       xs_destroy xprt ffff800077e9e000
RPC:       xs_close xprt ffff800077e9e000
RPC:       xs_reset xprt ffff800077e9e000
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
RPC:       disconnected transport ffff800077e9e000
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
RPC:       disconnected transport ffff800077e9e000
RPC:       xs_tcp_data_ready...
RPC:       xs_reset xprt ffff800077e9e000
RPC:       xs_tcp_state_change client ffff800077e9e000...
RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
RPC:       disconnected transport ffff800077e9e000
RPC:       wake_up_first(ffff800077e9e170 "xprt_sending")
------------[ cut here ]------------
kernel BUG at fs/inode.c:1493!
Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
Modules linked in:
CPU: 2 PID: 1 Comm: swapper/0 Tainted: G S              4.3.0-rc1+ #885
Hardware name: FVP Base (DT)
task: ffff800078478000 ti: ffff800078454000 task.ti: ffff800078454000
PC is at iput+0x144/0x170
LR is at sock_release+0xbc/0xdc
pc : [<ffff8000001b38a8>] lr : [<ffff8000004d0a0c>] pstate: 40400045
sp : ffff8000784574e0
x29: ffff8000784574e0 x28: 0000000000000002
x27: ffff800078688000 x26: ffff800077ee7cc0
x25: ffff80000062c000 x24: ffff800077e9d388
x23: ffff800077e9d0c8 x22: ffff800077f08180
x21: ffff80007808e628 x20: ffff80007808e6d8
x19: ffff80007808e5b0 x18: 0000000000000007
x17: 000000000000000e x16: ffff000000294fff
x15: ffffffffffffffff x14: 0ffffffffffffffe
x13: 0000000000000020 x12: 0101010101010101
x11: 0000000000000167 x10: 0000000000000750
x9 : ffff8000784573c0 x8 : ffff8000784787b0
x7 : ffff80000087a610 x6 : 0000000000000001
x5 : 0000000000000000 x4 : 00000000fffffffe
x3 : 0000000000000000 x2 : ffffffffffffffff
x1 : ffff800078454000 x0 : 0000000000000060

Call trace:
[<ffff8000001b38a8>] iput+0x144/0x170
[<ffff8000004d0a08>] sock_release+0xb8/0xdc
[<ffff800000577e88>] xs_reset_transport+0x98/0xcc
[<ffff800000577f0c>] xs_close+0x50/0x6c
[<ffff800000577f50>] xs_destroy+0x28/0x64
[<ffff800000575000>] xprt_destroy+0x68/0x8c
[<ffff80000057680c>] xprt_put+0x24/0x30
[<ffff800000571754>] rpc_free_client+0x78/0xd8
[<ffff80000057191c>] rpc_release_client+0x94/0xec
[<ffff800000584aa4>] rpcb_getport_async+0x2d8/0x490
[<ffff800000571218>] call_bind+0x58/0x88
[<ffff80000057b540>] __rpc_execute+0x64/0x338
[<ffff80000057bb20>] rpc_execute+0x5c/0x6c
[<ffff800000573eac>] rpc_run_task+0x8c/0xb0
[<ffff800000573f14>] rpc_call_sync+0x44/0xb0
[<ffff800000573fd0>] rpc_ping+0x50/0x70
[<ffff8000005740a0>] rpc_create_xprt+0xb0/0xcc
[<ffff80000057415c>] rpc_create+0xa0/0x150
[<ffff8000002774e0>] nfs_mount+0xcc/0x234
[<ffff80000026bc14>] nfs_request_mount+0xa8/0x12c
[<ffff80000026d4f0>] nfs_try_mount+0x54/0x2b4
[<ffff80000026e0cc>] nfs_fs_mount+0x5cc/0xac0
[<ffff80000019e124>] mount_fs+0x38/0x158
[<ffff8000001b7130>] vfs_kern_mount+0x48/0x11c
[<ffff8000001ba314>] do_mount+0x204/0xc00
[<ffff8000001bb034>] SyS_mount+0x78/0xd0
[<ffff8000007e9fac>] mount_root+0x80/0x148
[<ffff8000007ea1ac>] prepare_namespace+0x138/0x184
[<ffff8000007e9b20>] kernel_init_freeable+0x1cc/0x1f4
[<ffff8000005a1a18>] kernel_init+0xc/0xd8
Code: b5fffc00 17ffffed d4210000 17ffffd7 (d4210000)
---[ end trace 9b8c1c0ef92dab57 ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b


Thanks
Suzuki

