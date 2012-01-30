Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab2A3Unj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 15:43:39 -0500
Message-ID: <4F2700E2.9020803@RedHat.com>
Date: Mon, 30 Jan 2012 15:43:14 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: initialize delayed work on each rpc_inode allocation
References: <1327426850-14837-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327426850-14837-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/24/2012 12:40 PM, Jeff Layton wrote:
> The debugobjects code will sometimes pop a warning like this when the
> queue_timeout job is queued to a workqueue:
> 
> [ 5157.128514] WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
> [ 5157.128742] Hardware name: Bochs
> [ 5157.128742] ODEBUG: activate not available (active state 0) object type: timer_list hint: stub_timer+0x0/0x20
> [ 5157.128742] Modules linked in: nfsd(O) nfs_acl auth_rpcgss lockd sunrpc floppy virtio_net i2c_piix4 i2c_core virtio_balloon joydev pcspkr virtio_blk [last unloaded: nfsd]
> [ 5157.128742] Pid: 1312, comm: rpc.nfsd Tainted: G        W  O 3.3.0-rc1+ #1
> [ 5157.128742] Call Trace:
> [ 5157.128742]  [<ffffffff8106135f>] warn_slowpath_common+0x7f/0xc0
> [ 5157.128742]  [<ffffffff81061456>] warn_slowpath_fmt+0x46/0x50
> [ 5157.128742]  [<ffffffff8132ba2c>] debug_print_object+0x8c/0xb0
> [ 5157.128742]  [<ffffffff81070db0>] ? timer_debug_hint+0x10/0x10
> [ 5157.128742]  [<ffffffff8132c02b>] debug_object_activate+0xfb/0x190
> [ 5157.128742]  [<ffffffff81072728>] ? lock_timer_base.isra.24+0x38/0x70
> [ 5157.128742]  [<ffffffff81074676>] mod_timer+0xf6/0x450
> [ 5157.128742]  [<ffffffff810749e8>] add_timer+0x18/0x20
> [ 5157.128742]  [<ffffffff8108168e>] queue_delayed_work_on+0xbe/0x140
> [ 5157.128742]  [<ffffffff81084441>] queue_delayed_work+0x21/0x40
> [ 5157.128742]  [<ffffffffa006e568>] rpc_queue_upcall+0xe8/0x100 [sunrpc]
> [ 5157.128742]  [<ffffffffa012a121>] __cld_pipe_upcall+0x61/0xc0 [nfsd]
> [ 5157.128742]  [<ffffffffa012ad98>] nfsd4_cld_init+0x48/0x140 [nfsd]
> [ 5157.128742]  [<ffffffffa012b22a>] nfsd4_client_tracking_init+0x2a/0xc0 [nfsd]
> [ 5157.128742]  [<ffffffff8169797e>] ? mutex_unlock+0xe/0x10
> [ 5157.128742]  [<ffffffffa01266fa>] nfs4_state_start+0x1a/0x100 [nfsd]
> [ 5157.128742]  [<ffffffffa01028c5>] nfsd_svc+0x135/0x200 [nfsd]
> [ 5157.128742]  [<ffffffffa0103df0>] ? write_maxblksize+0x130/0x130 [nfsd]
> [ 5157.128742]  [<ffffffffa0103e6d>] write_threads+0x7d/0xd0 [nfsd]
> [ 5157.128742]  [<ffffffff811dd16a>] ? simple_transaction_get+0xca/0xe0
> [ 5157.128742]  [<ffffffffa0102ee7>] nfsctl_transaction_write+0x57/0x90 [nfsd]
> [ 5157.128742]  [<ffffffff811b4c9f>] vfs_write+0xaf/0x190
> [ 5157.128742]  [<ffffffff811b4fdd>] sys_write+0x4d/0x90
> [ 5157.128742]  [<ffffffff816a3469>] system_call_fastpath+0x16/0x1b
> 
> This occurs when an rpc_inode object is recycled. The slab constructor
> routine doesn't necessarily get called on it again, so the debugobjects
> code isn't aware that it's already initialized.
> 
> Work around this problem by initializing the delayed work every time
> an inode is allocated out of the slab, not just when a new slab is.
> 
> Cc: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
I was seeing this warning as well and this patch did remove that warning...

Tested-by: Steve Dickson <steved@redhat.com>

steved.

> ---
>  net/sunrpc/rpc_pipe.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 63a7a7a..58e1dd1 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -178,6 +178,8 @@ rpc_alloc_inode(struct super_block *sb)
>  	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, GFP_KERNEL);
>  	if (!rpci)
>  		return NULL;
> +
> +	INIT_DELAYED_WORK(&rpci->queue_timeout, rpc_timeout_upcall_queue);
>  	return &rpci->vfs_inode;
>  }
>  
> @@ -1073,8 +1075,6 @@ init_once(void *foo)
>  	INIT_LIST_HEAD(&rpci->pipe);
>  	rpci->pipelen = 0;
>  	init_waitqueue_head(&rpci->waitq);
> -	INIT_DELAYED_WORK(&rpci->queue_timeout,
> -			    rpc_timeout_upcall_queue);
>  	rpci->ops = NULL;
>  }
>  
