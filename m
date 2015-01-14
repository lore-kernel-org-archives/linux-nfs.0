Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58272 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241AbbANTFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 14:05:07 -0500
Date: Wed, 14 Jan 2015 14:05:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs: don't call blocking operations while
 !TASK_RUNNING
Message-ID: <20150114190506.GB5069@fieldses.org>
References: <1421249572-12038-1-git-send-email-jlayton@primarydata.com>
 <1421258937-18613-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421258937-18613-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 01:08:57PM -0500, Jeff Layton wrote:
> Bruce reported seeing this warning pop when mounting using v4.1:
> 
>      ------------[ cut here ]------------
>      WARNING: CPU: 1 PID: 1121 at kernel/sched/core.c:7300 __might_sleep+0xbd/0xd0()
>     do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810ff58f>] prepare_to_wait+0x2f/0x90
>     Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace sunrpc fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_pcm snd_timer ppdev joydev snd virtio_console virtio_balloon pcspkr serio_raw parport_pc parport pvpanic floppy soundcore i2c_piix4 virtio_blk virtio_net qxl drm_kms_helper ttm drm virtio_pci virtio_ring ata_generic virtio pata_acpi
>     CPU: 1 PID: 1121 Comm: nfsv4.1-svc Not tainted 3.19.0-rc4+ #25
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
>      0000000000000000 000000004e5e3f73 ffff8800b998fb48 ffffffff8186ac78
>      0000000000000000 ffff8800b998fba0 ffff8800b998fb88 ffffffff810ac9da
>      ffff8800b998fb68 ffffffff81c923e7 00000000000004d9 0000000000000000
>     Call Trace:
>      [<ffffffff8186ac78>] dump_stack+0x4c/0x65
>      [<ffffffff810ac9da>] warn_slowpath_common+0x8a/0xc0
>      [<ffffffff810aca65>] warn_slowpath_fmt+0x55/0x70
>      [<ffffffff810ff58f>] ? prepare_to_wait+0x2f/0x90
>      [<ffffffff810ff58f>] ? prepare_to_wait+0x2f/0x90
>      [<ffffffff810dd2ad>] __might_sleep+0xbd/0xd0
>      [<ffffffff8124c973>] kmem_cache_alloc_trace+0x243/0x430
>      [<ffffffff810d941e>] ? groups_alloc+0x3e/0x130
>      [<ffffffff810d941e>] groups_alloc+0x3e/0x130
>      [<ffffffffa0301b1e>] svcauth_unix_accept+0x16e/0x290 [sunrpc]
>      [<ffffffffa0300571>] svc_authenticate+0xe1/0xf0 [sunrpc]
>      [<ffffffffa02fc564>] svc_process_common+0x244/0x6a0 [sunrpc]
>      [<ffffffffa02fd044>] bc_svc_process+0x1c4/0x260 [sunrpc]
>      [<ffffffffa03d5478>] nfs41_callback_svc+0x128/0x1f0 [nfsv4]
>      [<ffffffff810ff970>] ? wait_woken+0xc0/0xc0
>      [<ffffffffa03d5350>] ? nfs4_callback_svc+0x60/0x60 [nfsv4]
>      [<ffffffff810d45bf>] kthread+0x11f/0x140
>      [<ffffffff810ea815>] ? local_clock+0x15/0x30
>      [<ffffffff810d44a0>] ? kthread_create_on_node+0x250/0x250
>      [<ffffffff81874bfc>] ret_from_fork+0x7c/0xb0
>      [<ffffffff810d44a0>] ? kthread_create_on_node+0x250/0x250
>     ---[ end trace 675220a11e30f4f2 ]---
> 
> nfs41_callback_svc does most of its work while in TASK_INTERRUPTIBLE,
> which is just wrong. Fix that by finishing the wait immediately if we've
> found that the list has something on it.
> 
> Also, we don't expect this kthread to accept signals, so we should be
> using a TASK_UNINTERRUPTIBLE sleep instead. That however, opens us up
> hung task warnings from the watchdog, so have the schedule_timeout
> wake up every 60s if there's no callback activity.

Works for me, for what it's worth.

> 
> Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfs/callback.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index b8fb3a4ef649..351be9205bf8 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -128,22 +128,24 @@ nfs41_callback_svc(void *vrqstp)
>  		if (try_to_freeze())
>  			continue;
>  
> -		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
> +		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_UNINTERRUPTIBLE);
>  		spin_lock_bh(&serv->sv_cb_lock);
>  		if (!list_empty(&serv->sv_cb_list)) {
>  			req = list_first_entry(&serv->sv_cb_list,
>  					struct rpc_rqst, rq_bc_list);
>  			list_del(&req->rq_bc_list);
>  			spin_unlock_bh(&serv->sv_cb_lock);
> +			finish_wait(&serv->sv_cb_waitq, &wq);
>  			dprintk("Invoking bc_svc_process()\n");
>  			error = bc_svc_process(serv, req, rqstp);
>  			dprintk("bc_svc_process() returned w/ error code= %d\n",
>  				error);
>  		} else {
>  			spin_unlock_bh(&serv->sv_cb_lock);
> -			schedule();
> +			/* schedule_timeout to game the hung task watchdog */
> +			schedule_timeout(60 * HZ);
> +			finish_wait(&serv->sv_cb_waitq, &wq);
>  		}
> -		finish_wait(&serv->sv_cb_waitq, &wq);
>  	}
>  	return 0;
>  }
> -- 
> 2.1.0
> 
