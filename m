Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:20285 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3K0HyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 02:54:16 -0500
Message-ID: <5295A51A.7070909@huawei.com>
Date: Wed, 27 Nov 2013 15:54:02 +0800
From: Weng Meiling <wengmeiling.weng@huawei.com>
MIME-Version: 1.0
To: <stable@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <containers@lists.linux-foundation.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: Li Zefan <lizefan@huawei.com>, Huang Qiang <h.huangqiang@huawei.com>
Subject: [stable bug] NFSd NULL pointer trigger kernel panic
References: <52959F5D.4000200@huawei.com>
In-Reply-To: <52959F5D.4000200@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi guys,

When I try to test NFS in different network namespace with stable-3.4,
I trigger a kernel panic. When NFSd was started in one non init_net network
namespace, and stopped in another one. This will trigger kernel panic, because
RPCBIND client is stored per net, and will be NULL on NFSd shutdown.

The detail steps are:

#ip netns add test
#ip netns exec test service nfsserver start
#service nfsserver stop

The main call trace:

[  293.358078] BUG: unable to handle kernel NULL pointer dereference at 0000000000000060
[  293.358089] IP: [<ffffffffa0446150>] call_start+0x10/0x30 [sunrpc]

[  293.358215] Pid: 5323, comm: nfsd Not tainted 3.4.69-default-stable+

[  293.358321] Call Trace:
[  293.358336]  [<ffffffffa044f401>] __rpc_execute+0x91/0x160 [sunrpc]
[  293.358351]  [<ffffffffa044f541>] rpc_execute+0x71/0x80 [sunrpc]
[  293.358362]  [<ffffffffa04479a9>] rpc_run_task+0x89/0xa0 [sunrpc]
[  293.358374]  [<ffffffffa0447abd>] rpc_call_sync+0x3d/0x70 [sunrpc]
[  293.358390]  [<ffffffffa0457bc6>] rpcb_register+0xa6/0xd0 [sunrpc]
[  293.358406]  [<ffffffffa0452345>] svc_unregister+0x95/0xf0 [sunrpc]
[  293.358418]  [<ffffffffa04ab8a0>] ? nfsd_last_thread+0x50/0x50 [nfsd]
[  293.358433]  [<ffffffffa04523b1>] svc_rpcb_cleanup+0x11/0x20 [sunrpc]
[  293.358442]  [<ffffffffa04ab877>] nfsd_last_thread+0x27/0x50 [nfsd]
[  293.358457]  [<ffffffffa0452280>] svc_shutdown_net+0x30/0x40 [sunrpc]
[  293.358466]  [<ffffffffa04ab9ed>] nfsd+0x14d/0x1a0 [nfsd]
[  293.358475]  [<ffffffffa04ab8a0>] ? nfsd_last_thread+0x50/0x50 [nfsd]
[  293.358487]  [<ffffffff8106459e>] kthread+0x9e/0xb0
[  293.358496]  [<ffffffff81465014>] kernel_thread_helper+0x4/0x10
[  293.358503]  [<ffffffff81064500>] ? kthread_freezable_should_stop+0x70/0x70
[  293.358509]  [<ffffffff81465010>] ? gs_change+0x13/0x13

Walk through the code, this problem also exists in stable-3.5 to stable-3.7.
Stanislav Kinsbursky had committed a fixed patch for 3.8:
commit f7fb86c6e639360ad9c253cec534819ef928a674 (nfsd: use "init_net" for portmapper).
This patch is suitable for stable-3.4, but it causes another bug, When starting NFSd
in a non init_net network namespace will trigger kernel panic. Because RPCBIND client
will be NULL when register RPC service with the local portmapper in svc_addsock(). This
new bug also exists in 3.8, but disappears after patch commit 11f779421a39b86da8a523d97e5fd3477878d44f
("containerize NFSd filesystem") in 3.9.

The detail steps are:

#ip netns add test
#ip netns exec test service nfsserver start

The main call trace:

[  136.877527] BUG: unable to handle kernel NULL pointer dereference at 0000000000000060
[  136.877538] IP: [<ffffffffa0451150>] call_start+0x10/0x30 [sunrpc]

[  136.877664] Pid: 4854, comm: rpc.nfsd Not tainted 3.4.69-default-stable-nfs-test+

[  136.877769] Call Trace:
[  136.877785]  [<ffffffffa045a401>] __rpc_execute+0x91/0x160 [sunrpc]
[  136.877799]  [<ffffffffa045a541>] rpc_execute+0x71/0x80 [sunrpc]
[  136.877811]  [<ffffffffa04529a9>] rpc_run_task+0x89/0xa0 [sunrpc]
[  136.877822]  [<ffffffffa0452abd>] rpc_call_sync+0x3d/0x70 [sunrpc]
[  136.877839]  [<ffffffffa0462bc6>] rpcb_register+0xa6/0xd0 [sunrpc]
[  136.877854]  [<ffffffffa045ca9e>] __svc_register+0x1ae/0x1c0 [sunrpc]
[  136.877870]  [<ffffffffa045cb3f>] svc_register+0x8f/0xc0 [sunrpc]
[  136.877882]  [<ffffffff8114d855>] ? kmem_cache_alloc_trace+0xc5/0x1e0
[  136.877897]  [<ffffffffa045ec38>] svc_setup_socket+0x1a8/0x2c0 [sunrpc]
[  136.877907]  [<ffffffff81009546>] ? read_tsc+0x16/0x40
[  136.877922]  [<ffffffffa045f9b8>] svc_addsock+0x118/0x1c0 [sunrpc]
[  136.877930]  [<ffffffff8108f225>] ? do_gettimeofday+0x15/0x50
[  136.877941]  [<ffffffffa04aa69c>] ? nfsd_create_serv+0xdc/0x150 [nfsd]
[  136.877951]  [<ffffffffa04abdce>] __write_ports+0x1fe/0x230 [nfsd]
[  136.877961]  [<ffffffffa04abe37>] write_ports+0x37/0x60 [nfsd]
[  136.877970]  [<ffffffffa04abe00>] ? __write_ports+0x230/0x230 [nfsd]
[  136.877979]  [<ffffffffa04aadd2>] nfsctl_transaction_write+0x72/0x90 [nfsd]
[  136.877987]  [<ffffffff8115b4ab>] vfs_write+0xcb/0x130
[  136.877992]  [<ffffffff8115b600>] sys_write+0x50/0x90
[  136.878000]  [<ffffffff81463cb9>] system_call_fastpath+0x16/0x1b


Here is a way to resolve the problem:
Maybe we can backport the following patches from 3.8 to cleanup init_net reference:

---

Stanislav Kinsbursky (7):
      nfsd: use "init_net" for portmapper 			commit f7fb86c6e639360ad9c253cec534819ef928a674
      nfsd: pass net to nfsd_init_socks() 			commit db6e182c17cb1a7069f7f8924721ce58ac05d9a3
      nfsd: pass net to nfsd_startup() and nfsd_shutdown() 	commit db42d1a76a8dfcaba7a2dc9c591fa4e231db22b3
      nfsd: pass net to nfsd_create_serv() 			commit 6777436b0f072fb20a025a73e9b67a35ad8a5451
      nfsd: pass net to nfsd_svc() 				commit d41a9417cd89a69f58a26935034b4264a2d882d6		
      nfsd: pass net to nfsd_set_nrthreads() 			commit 3938a0d5eb5effcc89c6909741403f4e6a37252d
      nfsd: pass net to __write_ports() and down 		commit 081603520b25f7b35ef63a363376a17c36ef74ed


 fs/nfsd/nfsctl.c |   27 +++++++++++++++------------
 fs/nfsd/nfsd.h   |    6 +++---
 fs/nfsd/nfssvc.c |   35 ++++++++++++++---------------------
 3 files changed, 32 insertions(+), 36 deletions(-)

Stanislav Kinsbursky:
	nfsd: pass proper net to nfsd_destroy() from NFSd kthreads  commit 88c47666171989ed4c5b1a5687df09511e8c5e35

 fs/nfsd/nfssvc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

and then just a simple patch which uses the current->nsproxy->net_ns to repalce the
init_net to make NFSd keep using a consistent network namespace all the time can
resolve the problem. Maybe this is not optimal, what do you think about this problem?

The related patches' links:
http://linux-kernel.2935.n7.nabble.com/PATCH-0-7-nfsd-cleanup-quot-init-net-quot-references-td567366.html
https://lkml.org/lkml/2012/12/6/161





