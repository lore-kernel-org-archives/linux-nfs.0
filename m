Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36883 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751370AbdHPPqB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 11:46:01 -0400
Received: by mail-io0-f194.google.com with SMTP id c74so2494331iod.4
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 08:46:00 -0700 (PDT)
Subject: Re: [PATCH 1/3] SUNRPC: Don't hold the transport lock across socket
 copy operations
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20170814191652.18263-1-trond.myklebust@primarydata.com>
 <20170814191652.18263-2-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <a71e206a-71cd-7b67-8fb6-34db7dc25954@gmail.com>
Date: Wed, 16 Aug 2017 11:45:56 -0400
MIME-Version: 1.0
In-Reply-To: <20170814191652.18263-2-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 08/14/2017 03:16 PM, Trond Myklebust wrote:
> Instead add a mechanism to ensure that the request doesn't disappear
> from underneath us while copying from the socket. We do this by
> preventing xprt_release() from freeing the XDR buffers until the
> flag RPC_TASK_MSG_RECV has been cleared from the request.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

I see the following kernel crash after applying this patch and running xfstests generic/089:

[   25.408414] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   25.409253] IP: xprt_pin_rqst+0x23/0x30 [sunrpc]
[   25.409728] PGD 32ef2067 
[   25.409729] P4D 32ef2067 
[   25.410003] PUD 32ed0067 
[   25.410276] PMD 0 
[   25.410561] 
[   25.410935] Oops: 0002 [#1] PREEMPT SMP
[   25.411326] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs fscache rpcrdma cfg80211 rfkill crct10dif_pclmul crc32_pclmul ghash_
clmulni_intel pcbc joydev vmwgfx mousedev ppdev snd_hda_codec_generic aesni_intel drm_kms_helper aes_x86_64 crypto_simd snd_hda_
intel cryptd evdev glue_helper input_leds led_class snd_hda_codec psmouse mac_hid pcspkr snd_hwdep syscopyarea snd_hda_core sysf
illrect sysimgblt fb_sys_fops snd_pcm ttm snd_timer parport_pc drm pvpanic parport snd intel_agp soundcore intel_gtt i2c_piix4 b
utton sch_fq_codel nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ip_tables x_tables ata_generic pata_acpi serio_raw a
tkbd libps2 ata_piix i8042 serio floppy libata scsi_mod uhci_hcd ehci_pci ehci_hcd usbcore usb_common virtio_balloon xfs libcrc3
2c crc32c_generic crc32c_intel virtio_net
[   25.418332]  virtio_pci virtio_blk virtio_ring virtio
[   25.418853] CPU: 1 PID: 84 Comm: kworker/1:1H Not tainted 4.13.0-rc5-ANNA+ #4039
[   25.419603] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   25.420166] Workqueue: xprtiod xs_tcp_data_receive_workfn [sunrpc]
[   25.420796] task: ffff88003c645880 task.stack: ffffc9000054c000
[   25.421702] RIP: 0010:xprt_pin_rqst+0x23/0x30 [sunrpc]
[   25.422507] RSP: 0018:ffffc9000054fd08 EFLAGS: 00010282
[   25.423327] RAX: 0000000000000000 RBX: 00000000000000cc RCX: 0000000000001000
[   25.424340] RDX: 0000000000000001 RSI: 0000100000000000 RDI: ffff880037bcfc00
[   25.425338] RBP: ffffc9000054fd08 R08: ffff880038778568 R09: ffff88003fc18780
[   25.426329] R10: ffff88003dbe7300 R11: 0000000000000000 R12: ffff880038778438
[   25.427324] R13: ffff880038778000 R14: ffffffffa02ba1bb R15: ffff880037bcfc00
[   25.428316] FS:  0000000000000000(0000) GS:ffff88003fd00000(0000) knlGS:0000000000000000
[   25.429704] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   25.430585] CR2: 0000000000000030 CR3: 0000000032ea7000 CR4: 00000000001406e0
[   25.431613] Call Trace:
[   25.432188]  xs_tcp_data_recv+0x598/0xa40 [sunrpc]
[   25.432988]  ? rpc_wake_up_first_on_wq+0xa0/0x1d0 [sunrpc]
[   25.434403]  ? call_decode+0x830/0x830 [sunrpc]
[   25.435263]  ? xprt_release_xprt+0x86/0x90 [sunrpc]
[   25.436074]  tcp_read_sock+0x98/0x1d0
[   25.436760]  ? xs_tcp_check_fraghdr.part.0+0x60/0x60 [sunrpc]
[   25.437702]  xs_tcp_data_receive_workfn+0xc2/0x170 [sunrpc]
[   25.438554]  process_one_work+0x1ed/0x430
[   25.439242]  worker_thread+0x56/0x400
[   25.439942]  kthread+0x134/0x150
[   25.440554]  ? process_one_work+0x430/0x430
[   25.441235]  ? kthread_create_on_node+0x80/0x80
[   25.441946]  ret_from_fork+0x25/0x30
[   25.442555] Code: 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 48 81 ec 20 10 00 00 48 83 0c 24 00 48 81 c4 20 10 00 00
 48 8b 87 88 00 00 00 <f0> 80 48 30 08 5d c3 66 0f 1f 44 00 00 0f 1f 44 00 00 48 8b 87 
[   25.445096] RIP: xprt_pin_rqst+0x23/0x30 [sunrpc] RSP: ffffc9000054fd08
[   25.446007] CR2: 0000000000000030
[   25.446601] ---[ end trace 9d711ee39d595517 ]---
[   25.447320] Kernel panic - not syncing: Fatal exception in interrupt
[   25.448292] Kernel Offset: disabled
[   25.448904] ---[ end Kernel panic - not syncing: Fatal exception in interrupt


> ---
>  include/linux/sunrpc/sched.h |  2 ++
>  include/linux/sunrpc/xprt.h  |  2 ++
>  net/sunrpc/xprt.c            | 42 ++++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/xprtsock.c        | 27 ++++++++++++++++++++++-----
>  4 files changed, 68 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 15bc1cd6ee5c..e972d9e05426 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -141,6 +141,8 @@ struct rpc_task_setup {
>  #define RPC_TASK_ACTIVE		2
>  #define RPC_TASK_MSG_XMIT	3
>  #define RPC_TASK_MSG_XMIT_WAIT	4
> +#define RPC_TASK_MSG_RECV	5
> +#define RPC_TASK_MSG_RECV_WAIT	6
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
> index 788c1b6138c2..62c379865f7c 100644
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
> @@ -1301,6 +1342,7 @@ void xprt_release(struct rpc_task *task)
>  		list_del(&req->rq_list);
>  	xprt->last_used = jiffies;
>  	xprt_schedule_autodisconnect(xprt);
> +	xprt_wait_on_pinned_rqst(req);
>  	spin_unlock_bh(&xprt->transport_lock);
>  	if (req->rq_buffer)
>  		xprt->ops->buf_free(task);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 4f154d388748..222993fbaf99 100644
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
> @@ -1385,12 +1398,16 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
>  		xprt_force_disconnect(xprt);
>  		return -1;
>  	}
> +	xprt_pin_rqst(req);
> +	spin_unlock_bh(&xprt->transport_lock);
>  
>  	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
>  	xs_tcp_read_common(xprt, desc, req);
>  
> +	spin_lock_bh(&xprt->transport_lock);
>  	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>  		xprt_complete_bc_request(req, transport->tcp_copied);
> +	xprt_unpin_rqst(req);
>  	spin_unlock_bh(&xprt->transport_lock);
>  
>  	return 0;
> 
