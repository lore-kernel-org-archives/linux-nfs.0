Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:56856 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757659Ab2FUHJG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2012 03:09:06 -0400
Message-ID: <4FE2C8D2.8000809@cn.fujitsu.com>
Date: Thu, 21 Jun 2012 15:10:10 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [patch] nfs client oops when receive a 'read reply Malformed
 Packet'
References: <4FE14C0C.9050400@cn.fujitsu.com> <1340203729.4587.5.camel@lade.trondhjem.org>
In-Reply-To: <1340203729.4587.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond 写道:
> On Wed, 2012-06-20 at 12:05 +0800, fanchaoting wrote:
>> nfs client oops when receive a "read reply Malformed Packet".
>> I find that the xdr->iov may be NULL when client receive a 
>> Malformed Packet(only have 'Status' and 'file_attributes').
>>
>> rpcauth_unwrap_req_decode
>>     nfs3_xdr_dec_read3res
>>          decode_read3resok  
>>              ......
>>              hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;    (oops  xdr->iov is NULL)
>>              ......
>>
>> rpcauth_unwrap_req_decode
>>     nfs3_xdr_dec_readlink3res
>>          decode_nfspath3
>>              .....
>>              hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;    (oops  xdr->iov is NULL)
>>              .....
>>        
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874745] BUG: unable to handle kernel NULL pointer dereference at   (null)
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874823] IP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874905] *pdpt = 00000000368c6001 *pde = 0000000000000000
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874961] Oops: 0000 [#1] SMP
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874998] Modules linked in: nfs nfs_acl auth_rpcgss fscache lockd sunrpc ppdev snd_hda_codec_realtek parport_pc snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_timer iTCO_wdt iTCO_vendor_support microcode parport snd i2c_i801 serio_raw r8169 soundcore 8139too 8139cp mii usb_storage i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875393]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875411] Pid: 4, comm: kworker/0:0 Not tainted 3.3.4-5.fc17.i686.PAE #1 Acer ASPIRE AG1720/E945GCZ
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875501] EIP: 0060:[<f963d31a>] EFLAGS: 00010246 CPU: 0
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875566] EIP is at nfs3_xdr_dec_read3res+0x6a/0x120 [nfs]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875618] EAX: ff6f300c EBX: f4887ebc ECX: 00000000 EDX: 00000000
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875673] ESI: f37bdf5c EDI: 00000000 EBP: f4887ea0 ESP: f4887e7c
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Process kworker/0:0 (pid: 4, ti=f4886000 task=f485a5b0 task.ti=f4886000)
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Stack:
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  f7207b80 00000137 00000001 0251f8b2 00000000 00000000 f963d2b0 00000000
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  f6897000 f4887ee4 f958d563 f43a3b00 f7207b80 00000082 f4887ee0 f963d2b0
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  ff6f300c f689702c ff6f3032 00000000 00000000 00000000 f37bdf9c f37bde00
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Call Trace:
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958d563>] rpcauth_unwrap_resp+0x73/0xb0 [sunrpc]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f9583cdb>] call_decode+0x17b/0x820 [sunrpc]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c1b2>] __rpc_execute+0x52/0x2a0 [sunrpc]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c410>] rpc_async_schedule+0x10/0x20 [sunrpc]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045e4b8>] process_one_work+0x108/0x370
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045d440>] ? do_work_for_cpu+0x20/0x20
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c400>] ? __rpc_execute+0x2a0/0x2a0 [sunrpc]
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045fa09>] worker_thread+0xf9/0x280
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c046f26e>] ? complete+0x4e/0x60
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045f910>] ? manage_workers.isra.24+0x1d0/0x1d0
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c04642e2>] kthread+0x72/0x80
>>
>> Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
>>  kernel:[ 1339.875700] Process kworker/0:0 (pid: 4, ti=f4886000 task=f485a5b0 task.ti=f4886000)
>>
>> Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
>>  kernel:[ 1339.875700] Stack:
>>
>> Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
>>  kernel:[ 1339.875700] Call Trace:
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c0464270>] ? flush_kthread_worker+0x70/0x70
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c094b3be>] kernel_thread_helper+0x6/0x10
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Code: 0c 00 00 00 89 d8 e8 d6 8d f5 ff 85 c0 74 68 8b 08 8b 50 04 0f c9 0f ca 89 55 ec 8b 50 08 89 cf 0f ca 39 d1 75 67 8b 53 0c 8b 03 <2b> 02 8b 53 04 8b 52 24 29 c2 39 d1 89 55 e8 77 75 89 d8 89 fa
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] EIP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs] SS:ESP 0068:f4887e7c
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] CR2: 0000000000000000
>> Jun 18 00:54:42 RHEL5GA kernel: [ 1339.899416] ---[ end trace 286ccde0ddd5fc09 ]---
>>
>> Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
>>  kernel:[ 1339.875700] Code: 0c 00 00 00 89 d8 e8 d6 8d f5 ff 85 c0 74 68 8b 08 8b 50 04 0f c9 0f ca 89 55 ec 8b 50 08 89 cf 0f ca 39 d1 75 67 8b 53 0c 8b 03 <2b> 02 8b 53 04 8b 52 24 29 c2 39 d1 89 55 e8 77 75 89 d8 89 fa
>>
>> Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
>>  kernel:[ 1339.875700] EIP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs] SS:ESP 0068:f4887e7c
>>
>>
>>
>>
>> messages-20130414:Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182093] BUG: unable to handle kernel NULL pointer dereference at           (null)
>> messages-20130414:Apr 13 22:53:00 RHEL7alpha1 kernel: [  964.326085] BUG: unable to handle kernel NULL pointer dereference at           (null)
>> [root@RHEL7alpha1 log]# vim messages-20130414
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182719] FS:  00007f12eeadc7c0(0000) GS:ffff88003c200000(0000) knlGS:0000000000000000
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182788] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182827] CR2: 0000000000000000 CR3: 000000003950d000 CR4: 00000000000006f0
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182872] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Process ls (pid: 1676, threadinfo ffff880037ae2000, task ffff880037cbcce0)
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Stack:
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b30 ffff8800371c2e38 ffff880037ae3b08 ffffffffa02ca5d8
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b90 0000000000000082 ffff88003434aa00 ffff88003887a764
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b98 ffffffffa00e1d3d ffff880037ae3b68 ffff8800371c2e38
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Call Trace:
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02ca5d8>] nfs3_xdr_dec_readlink3res+0x58/0x70 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e1d3d>] rpcauth_unwrap_resp+0x9d/0xd0 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02ca580>] ? nfs3_xdr_dec_create3res+0x80/0x80 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d653e>] call_decode+0x17e/0x250 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e02a6>] __rpc_execute+0x66/0x1d0 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e06d3>] rpc_execute+0x43/0x50 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d7af5>] rpc_run_task+0x75/0x90 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d7c13>] rpc_call_sync+0x43/0x70 [sunrpc]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02b6234>] ? nfs_alloc_fattr+0x24/0x70 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c74bb>] nfs3_rpc_wrapper.constprop.7+0x4b/0x80 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c796b>] nfs3_proc_readlink+0x8b/0xf0 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1f50>] nfs_symlink_filler+0x30/0x70 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c5f2>] do_read_cache_page+0x82/0x1a0
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02e53c0>] ? nfs_mark_delegation_referenced+0x10/0x10 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1f20>] ? nfs_follow_link+0xc0/0xc0 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c75c>] read_cache_page_async+0x1c/0x20
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c76e>] read_cache_page+0xe/0x20
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1ec8>] nfs_follow_link+0x68/0xc0 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811c0712>] generic_readlink+0x42/0xa0
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811b9e0d>] sys_readlinkat+0xad/0xb0
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff810f4bbe>] ? audit_syscall_entry+0x30e/0x330
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811b9e2b>] sys_readlink+0x1b/0x20
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff81639202>] system_call_fastpath+0x16/0x1b
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Code: 2f e2 ff 48 85 c0 74 4d 44 8b 20 48 8b 53 08 41 0f cc 41 81 fc 00 10 00 00 77 71 44 39 62 2c 76 6b 48 8b 4b 18 48 8b 03 8b 52 38 <48> 2b 01 29 c2 44 39 e2 72 36 48 89 df 44 89 e6 e8 1a 2c e2 ff
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] RIP  [<ffffffffa02c96e1>] decode_nfspath3+0x41/0xd0 [nfs]
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  RSP <ffff880037ae3ac8>
>> Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] CR2: 0000000000000000
>>
>>
>>
>> Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
>> ---
>>  fs/nfs/nfs3xdr.c |   10 ++++++++++
>>  1 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>> index 183c6b1..6f53070 100644
>> --- a/fs/nfs/nfs3xdr.c
>> +++ b/fs/nfs/nfs3xdr.c
>> @@ -250,6 +250,8 @@ static int decode_nfspath3(struct xdr_stream *xdr)
>>  	p = xdr_inline_decode(xdr, 4);
>>  	if (unlikely(p == NULL))
>>  		goto out_overflow;
>> +	if (unlikely(xdr->iov == NULL))
>> +		goto iov_null;
> 
> Hmm... Isn't the problem here rather that we are reading beyond the RPC
> reply message boundary?

yes 

> 
> If so, won't something like the following patch fix the problem?
> 

I apply you patch, but the system panic also.

> Cheers
>   Trond
> 8<---------------------------------------------------
> From 6aab66457f7059ed8e047cf8915c61ede842a637 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 20 Jun 2012 09:58:35 -0400
> Subject: [PATCH] SUNRPC: Don't decode beyond the end of the RPC reply message
> 
> Now that xdr_inline_decode() will automatically cross into the page
> buffers, we need to ensure that it doesn't exceed the total reply
> message length.
> 
> This patch sets up a counter that tracks the number of bytes
> remaining in the reply message, and ensures that xdr_inline_decode
> doesn't cross the end of message boundary.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  include/linux/sunrpc/xdr.h |    5 +++--
>  net/sunrpc/xdr.c           |   29 ++++++++++++++++++++++-------
>  2 files changed, 25 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index af70af3..caa282b 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -205,6 +205,7 @@ struct xdr_stream {
>  	struct kvec *iov;	/* pointer to the current kvec */
>  	struct kvec scratch;	/* Scratch buffer */
>  	struct page **page_ptr;	/* pointer to the current page */
> +	size_t nwords;		/* Remaining decode buffer length */
>  };
>  
>  /*
> @@ -222,8 +223,8 @@ extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
>  		struct page **pages, unsigned int len);
>  extern void xdr_set_scratch_buffer(struct xdr_stream *xdr, void *buf, size_t buflen);
>  extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
> -extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
> -extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
> +extern int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
> +extern int xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
>  extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
>  
>  #endif /* __KERNEL__ */
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index fddcccf..5900d66 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -632,6 +632,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
>  	xdr->buf = buf;
>  	xdr->scratch.iov_base = NULL;
>  	xdr->scratch.iov_len = 0;
> +	xdr->nwords = XDR_QUADLEN(buf->len);
>  	if (buf->head[0].iov_len != 0)
>  		xdr_set_iov(xdr, buf->head, p, buf->len);
>  	else if (buf->page_len != 0)
> @@ -660,12 +661,14 @@ EXPORT_SYMBOL_GPL(xdr_init_decode_pages);
>  
>  static __be32 * __xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
>  {
> +	size_t nwords = XDR_QUADLEN(nbytes);
>  	__be32 *p = xdr->p;
> -	__be32 *q = p + XDR_QUADLEN(nbytes);
> +	__be32 *q = p + nwords;
>  
> -	if (unlikely(q > xdr->end || q < p))
> +	if (unlikely(nwords > xdr->nwords || q > xdr->end || q < p))
>  		return NULL;
>  	xdr->p = q;
> +	xdr->nwords -= nwords;
>  	return p;
>  }
>  
> @@ -741,14 +744,17 @@ EXPORT_SYMBOL_GPL(xdr_inline_decode);
>   * into the page list. Any data that lies beyond current position + "len"
>   * bytes is moved into the XDR tail[].
>   */
> -void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
> +int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
>  {
>  	struct xdr_buf *buf = xdr->buf;
>  	struct kvec *iov;
> +	size_t nwords = XDR_QUADLEN(len);
>  	ssize_t shift;
>  	unsigned int end;
>  	int padding;
>  
> +	if (nwords > xdr->nwords)
> +		return -EFAULT;
>  	/* Realign pages to current pointer position */
>  	iov  = buf->head;
>  	shift = iov->iov_len + (char *)iov->iov_base - (char *)xdr->p;
> @@ -758,7 +764,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
>  	/* Truncate page data and move it into the tail */
>  	if (buf->page_len > len)
>  		xdr_shrink_pagelen(buf, buf->page_len - len);
> -	padding = (XDR_QUADLEN(len) << 2) - len;
> +	padding = (nwords << 2) - len;
>  	xdr->iov = iov = buf->tail;
>  	/* Compute remaining message length.  */
>  	end = iov->iov_len;
> @@ -773,6 +779,8 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
>  	 */
>  	xdr->p = (__be32 *)((char *)iov->iov_base + padding);
>  	xdr->end = (__be32 *)((char *)iov->iov_base + end);
> +	xdr->nwords -= nwords;
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(xdr_read_pages);
>  
> @@ -786,14 +794,21 @@ EXPORT_SYMBOL_GPL(xdr_read_pages);
>   * bytes is moved into the XDR tail[]. The current pointer is then
>   * repositioned at the beginning of the first XDR page.
>   */
> -void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
> +int xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
>  {
> -	xdr_read_pages(xdr, len);
> +	size_t save_nwords = xdr->nwords;
> +	int ret;
> +
> +	ret = xdr_read_pages(xdr, len);
> +	if (ret < 0)
> +		return ret;
>  	/*
>  	 * Position current pointer at beginning of tail, and
> -	 * set remaining message length.
> +	 * reset remaining message length.
>  	 */
>  	xdr_set_page_base(xdr, 0, len);
> +	xdr->nwords = save_nwords;
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(xdr_enter_page);
>  



