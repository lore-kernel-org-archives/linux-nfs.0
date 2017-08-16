Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35658 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdHPSyE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 14:54:04 -0400
Received: by mail-io0-f195.google.com with SMTP id h70so2783896ioi.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 11:54:04 -0700 (PDT)
Subject: Re: [PATCH v2 1/6] SUNRPC: Don't hold the transport lock across
 socket copy operations
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20170816161929.11271-1-trond.myklebust@primarydata.com>
 <20170816161929.11271-2-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <aa8d3a63-63d1-779c-7fc2-70e9c4cecce8@gmail.com>
Date: Wed, 16 Aug 2017 14:54:01 -0400
MIME-Version: 1.0
In-Reply-To: <20170816161929.11271-2-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 08/16/2017 12:19 PM, Trond Myklebust wrote:
> Instead add a mechanism to ensure that the request doesn't disappear
> from underneath us while copying from the socket. We do this by
> preventing xprt_release() from freeing the XDR buffers until the
> flag RPC_TASK_MSG_RECV has been cleared from the request.

I'm seeing a different oops on this version, still with xfstests generic/089:

[   67.896287] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   67.897466] IP: xprt_release+0x100/0x3b0 [sunrpc]
[   67.897911] PGD 39014067 
[   67.897911] P4D 39014067 
[   67.898169] PUD 32b36067 
[   67.898424] PMD 0 
[   67.898675] 
[   67.898928] Oops: 0000 [#1] PREEMPT SMP
[   67.899188] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache rpcrdma cfg80211 rfkill crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc vmwgfx snd_hda_codec_generic joydev mousedev ppdev drm_kms_helper snd_hda_intel syscopyarea sysfillrect sysimgblt fb_sys_fops aesni_intel snd_hda_codec ttm aes_x86_64 snd_hwdep crypto_simd cryptd snd_hda_core glue_helper snd_pcm drm evdev input_leds led_class psmouse snd_timer pcspkr mac_hid snd parport_pc intel_agp pvpanic parport i2c_piix4 soundcore intel_gtt button sch_fq_codel nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ip_tables x_tables ata_generic pata_acpi serio_raw atkbd libps2 uhci_hcd ehci_pci ehci_hcd floppy i8042 serio ata_piix usbcore usb_common libata scsi_mod xfs libcrc32c crc32c_generic virtio_balloon crc32c_intel
[   67.903802]  virtio_net virtio_pci virtio_blk virtio_ring virtio
[   67.904206] CPU: 1 PID: 728 Comm: NFSv4 callback Not tainted 4.13.0-rc5-ANNA+ #9642
[   67.904716] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   67.905097] task: ffff88003c735880 task.stack: ffffc900015cc000
[   67.905801] RIP: 0010:xprt_release+0x100/0x3b0 [sunrpc]
[   67.906436] RSP: 0000:ffffc900015cfd18 EFLAGS: 00010212
[   67.907064] RAX: ffff8800375e24b8 RBX: ffff88003db1e800 RCX: ffffffff81a054c8
[   67.907824] RDX: ffff88003db1ec80 RSI: 00000000fffef000 RDI: ffff88003db1e800
[   67.908579] RBP: ffffc900015cfd48 R08: 0000000000000000 R09: 0000000000000000
[   67.909328] R10: 0000000000000010 R11: 0000000000000000 R12: ffff8800375cce00
[   67.910071] R13: ffff880037874600 R14: ffff8800375cceb8 R15: ffff88003db1ec38
[   67.910816] FS:  0000000000000000(0000) GS:ffff88003fd00000(0000) knlGS:0000000000000000
[   67.911916] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   67.912592] CR2: 0000000000000030 CR3: 0000000032a5f000 CR4: 00000000001406e0
[   67.913369] Call Trace:
[   67.913858]  ? _raw_spin_unlock_bh+0x31/0x40
[   67.914477]  rpc_release_resources_task+0x25/0x50 [sunrpc]
[   67.915161]  __rpc_execute+0x1ef/0x430 [sunrpc]
[   67.915776]  rpc_execute+0x70/0xe0 [sunrpc]
[   67.916361]  rpc_run_bc_task+0x9a/0xf0 [sunrpc]
[   67.916963]  bc_svc_process+0x26a/0x330 [sunrpc]
[   67.917569]  nfs41_callback_svc+0x12e/0x1c0 [nfsv4]
[   67.918178]  ? wait_woken+0x90/0x90
[   67.918689]  kthread+0x134/0x150
[   67.919178]  ? nfs_map_gid_to_group+0x130/0x130 [nfsv4]
[   67.919786]  ? kthread_create_on_node+0x80/0x80
[   67.920345]  ret_from_fork+0x25/0x30
[   67.920838] Code: 35 a6 03 75 e1 48 8b 83 80 04 00 00 48 8d 93 80 04 00 00 48 39 c2 48 89 b3 18 04 00 00 0f 84 4c 02 00 00 4d 8b 84 24 88 00 00 00 <49> 8b 40 30 a8 08 0f 85 09 01 00 00 4c 89 ff e8 2c 4b 43 e1 49 
[   67.922831] RIP: xprt_release+0x100/0x3b0 [sunrpc] RSP: ffffc900015cfd18
[   67.924646] CR2: 0000000000000030
[   67.925582] ---[ end trace 69addd132abaa51b ]---
[   67.926568] Kernel panic - not syncing: Fatal exception in interrupt
[   67.927826] Kernel Offset: disabled
[   67.928655] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

Thanks,
Anna

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/sched.h |  2 ++
>  include/linux/sunrpc/xprt.h  |  2 ++
>  net/sunrpc/xprt.c            | 42 ++++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/xprtsock.c        | 23 ++++++++++++++++++-----
>  4 files changed, 64 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 50a99a117da7..c1768f9d993b 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -139,6 +139,8 @@ struct rpc_task_setup {
>  #define RPC_TASK_RUNNING	0
>  #define RPC_TASK_QUEUED		1
>  #define RPC_TASK_ACTIVE		2
> +#define RPC_TASK_MSG_RECV	3
> +#define RPC_TASK_MSG_RECV_WAIT	4
>  
>  #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
>  #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index eab1c749e192..65b9e0224753 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -372,6 +372,8 @@ void			xprt_write_space(struct rpc_xprt *xprt);
>  void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
>  struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
>  void			xprt_complete_rqst(struct rpc_task *task, int copied);
> +void			xprt_pin_rqst(struct rpc_rqst *req);
> +void			xprt_unpin_rqst(struct rpc_rqst *req);
>  void			xprt_release_rqst_cong(struct rpc_task *task);
>  void			xprt_disconnect_done(struct rpc_xprt *xprt);
>  void			xprt_force_disconnect(struct rpc_xprt *xprt);
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 4654a9934269..a558e8c620c0 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -844,6 +844,47 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
>  }
>  EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
>  
> +/**
> + * xprt_pin_rqst - Pin a request on the transport receive list
> + * @req: Request to pin
> + *
> + * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
> + * so should be holding the xprt transport lock.
> + */
> +void xprt_pin_rqst(struct rpc_rqst *req)
> +{
> +	set_bit(RPC_TASK_MSG_RECV, &req->rq_task->tk_runstate);
> +}
> +
> +/**
> + * xprt_unpin_rqst - Unpin a request on the transport receive list
> + * @req: Request to pin
> + *
> + * Caller should be holding the xprt transport lock.
> + */
> +void xprt_unpin_rqst(struct rpc_rqst *req)
> +{
> +	struct rpc_task *task = req->rq_task;
> +
> +	clear_bit(RPC_TASK_MSG_RECV, &task->tk_runstate);
> +	if (test_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate))
> +		wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_RECV);
> +}
> +
> +static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
> +__must_hold(&req->rq_xprt->transport_lock)
> +{
> +	struct rpc_task *task = req->rq_task;
> +	if (test_bit(RPC_TASK_MSG_RECV, &task->tk_runstate)) {
> +		spin_unlock_bh(&req->rq_xprt->transport_lock);
> +		set_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
> +		wait_on_bit(&task->tk_runstate, RPC_TASK_MSG_RECV,
> +				TASK_UNINTERRUPTIBLE);
> +		clear_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
> +		spin_lock_bh(&req->rq_xprt->transport_lock);
> +	}
> +}
> +
>  static void xprt_update_rtt(struct rpc_task *task)
>  {
>  	struct rpc_rqst *req = task->tk_rqstp;
> @@ -1295,6 +1336,7 @@ void xprt_release(struct rpc_task *task)
>  		list_del(&req->rq_list);
>  	xprt->last_used = jiffies;
>  	xprt_schedule_autodisconnect(xprt);
> +	xprt_wait_on_pinned_rqst(req);
>  	spin_unlock_bh(&xprt->transport_lock);
>  	if (req->rq_buffer)
>  		xprt->ops->buf_free(task);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 4f154d388748..04dbc7027712 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -973,6 +973,8 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
>  	rovr = xprt_lookup_rqst(xprt, *xp);
>  	if (!rovr)
>  		goto out_unlock;
> +	xprt_pin_rqst(rovr);
> +	spin_unlock_bh(&xprt->transport_lock);
>  	task = rovr->rq_task;
>  
>  	copied = rovr->rq_private_buf.buflen;
> @@ -981,11 +983,14 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
>  
>  	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
>  		dprintk("RPC:       sk_buff copy failed\n");
> -		goto out_unlock;
> +		spin_lock_bh(&xprt->transport_lock);
> +		goto out_unpin;
>  	}
>  
> +	spin_lock_bh(&xprt->transport_lock);
>  	xprt_complete_rqst(task, copied);
> -
> +out_unpin:
> +	xprt_unpin_rqst(rovr);
>   out_unlock:
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
> @@ -1054,6 +1059,8 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
>  	rovr = xprt_lookup_rqst(xprt, *xp);
>  	if (!rovr)
>  		goto out_unlock;
> +	xprt_pin_rqst(rovr);
> +	spin_unlock_bh(&xprt->transport_lock);
>  	task = rovr->rq_task;
>  
>  	if ((copied = rovr->rq_private_buf.buflen) > repsize)
> @@ -1062,14 +1069,17 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
>  	/* Suck it into the iovec, verify checksum if not done by hw. */
>  	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
>  		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
> -		goto out_unlock;
> +		spin_lock_bh(&xprt->transport_lock);
> +		goto out_unpin;
>  	}
>  
>  	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
>  
> +	spin_lock_bh(&xprt->transport_lock);
>  	xprt_adjust_cwnd(xprt, task, copied);
>  	xprt_complete_rqst(task, copied);
> -
> +out_unpin:
> +	xprt_unpin_rqst(rovr);
>   out_unlock:
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
> @@ -1351,12 +1361,15 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
>  		spin_unlock_bh(&xprt->transport_lock);
>  		return -1;
>  	}
> +	xprt_pin_rqst(req);
> +	spin_unlock_bh(&xprt->transport_lock);
>  
>  	xs_tcp_read_common(xprt, desc, req);
>  
> +	spin_lock_bh(&xprt->transport_lock);
>  	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>  		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
> -
> +	xprt_unpin_rqst(req);
>  	spin_unlock_bh(&xprt->transport_lock);
>  	return 0;
>  }
> 
