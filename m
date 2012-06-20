Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:50597 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab2FTEEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 00:04:24 -0400
Received: from fnstmail02.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id q5K44J6P019038
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 12:04:20 +0800
Message-ID: <4FE14C0C.9050400@cn.fujitsu.com>
Date: Wed, 20 Jun 2012 12:05:32 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: =?UTF-8?B?6IyD5pyd5oy6?= <fanchaoting@cn.fujitsu.com>,
        linux-nfs@vger.kernel.org
Subject: [patch] nfs client oops when receive a 'read reply Malformed Packet'
Content-Type: multipart/mixed;
 boundary="------------010205040603090308070604"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--------------010205040603090308070604
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8

nfs client oops when receive a "read reply Malformed Packet".
I find that the xdr->iov may be NULL when client receive a 
Malformed Packet(only have 'Status' and 'file_attributes').

rpcauth_unwrap_req_decode
    nfs3_xdr_dec_read3res
         decode_read3resok  
             ......
             hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;    (oops  xdr->iov is NULL)
             ......

rpcauth_unwrap_req_decode
    nfs3_xdr_dec_readlink3res
         decode_nfspath3
             .....
             hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;    (oops  xdr->iov is NULL)
             .....
       
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874745] BUG: unable to handle kernel NULL pointer dereference at   (null)
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874823] IP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874905] *pdpt = 00000000368c6001 *pde = 0000000000000000
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874961] Oops: 0000 [#1] SMP
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.874998] Modules linked in: nfs nfs_acl auth_rpcgss fscache lockd sunrpc ppdev snd_hda_codec_realtek parport_pc snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_timer iTCO_wdt iTCO_vendor_support microcode parport snd i2c_i801 serio_raw r8169 soundcore 8139too 8139cp mii usb_storage i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875393]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875411] Pid: 4, comm: kworker/0:0 Not tainted 3.3.4-5.fc17.i686.PAE #1 Acer ASPIRE AG1720/E945GCZ
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875501] EIP: 0060:[<f963d31a>] EFLAGS: 00010246 CPU: 0
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875566] EIP is at nfs3_xdr_dec_read3res+0x6a/0x120 [nfs]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875618] EAX: ff6f300c EBX: f4887ebc ECX: 00000000 EDX: 00000000
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875673] ESI: f37bdf5c EDI: 00000000 EBP: f4887ea0 ESP: f4887e7c
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Process kworker/0:0 (pid: 4, ti=f4886000 task=f485a5b0 task.ti=f4886000)
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Stack:
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  f7207b80 00000137 00000001 0251f8b2 00000000 00000000 f963d2b0 00000000
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  f6897000 f4887ee4 f958d563 f43a3b00 f7207b80 00000082 f4887ee0 f963d2b0
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  ff6f300c f689702c ff6f3032 00000000 00000000 00000000 f37bdf9c f37bde00
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Call Trace:
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958d563>] rpcauth_unwrap_resp+0x73/0xb0 [sunrpc]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f9583cdb>] call_decode+0x17b/0x820 [sunrpc]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f963d2b0>] ? nfs3_xdr_dec_readdir3res+0xf0/0xf0 [nfs]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c1b2>] __rpc_execute+0x52/0x2a0 [sunrpc]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c410>] rpc_async_schedule+0x10/0x20 [sunrpc]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045e4b8>] process_one_work+0x108/0x370
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045d440>] ? do_work_for_cpu+0x20/0x20
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<f958c400>] ? __rpc_execute+0x2a0/0x2a0 [sunrpc]
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045fa09>] worker_thread+0xf9/0x280
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c046f26e>] ? complete+0x4e/0x60
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c045f910>] ? manage_workers.isra.24+0x1d0/0x1d0
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c04642e2>] kthread+0x72/0x80

Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
 kernel:[ 1339.875700] Process kworker/0:0 (pid: 4, ti=f4886000 task=f485a5b0 task.ti=f4886000)

Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
 kernel:[ 1339.875700] Stack:

Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
 kernel:[ 1339.875700] Call Trace:
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c0464270>] ? flush_kthread_worker+0x70/0x70
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700]  [<c094b3be>] kernel_thread_helper+0x6/0x10
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] Code: 0c 00 00 00 89 d8 e8 d6 8d f5 ff 85 c0 74 68 8b 08 8b 50 04 0f c9 0f ca 89 55 ec 8b 50 08 89 cf 0f ca 39 d1 75 67 8b 53 0c 8b 03 <2b> 02 8b 53 04 8b 52 24 29 c2 39 d1 89 55 e8 77 75 89 d8 89 fa
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] EIP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs] SS:ESP 0068:f4887e7c
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.875700] CR2: 0000000000000000
Jun 18 00:54:42 RHEL5GA kernel: [ 1339.899416] ---[ end trace 286ccde0ddd5fc09 ]---

Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
 kernel:[ 1339.875700] Code: 0c 00 00 00 89 d8 e8 d6 8d f5 ff 85 c0 74 68 8b 08 8b 50 04 0f c9 0f ca 89 55 ec 8b 50 08 89 cf 0f ca 39 d1 75 67 8b 53 0c 8b 03 <2b> 02 8b 53 04 8b 52 24 29 c2 39 d1 89 55 e8 77 75 89 d8 89 fa

Message from syslogd@RHEL5GA at Jun 18 00:54:42 ...
 kernel:[ 1339.875700] EIP: [<f963d31a>] nfs3_xdr_dec_read3res+0x6a/0x120 [nfs] SS:ESP 0068:f4887e7c




messages-20130414:Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182093] BUG: unable to handle kernel NULL pointer dereference at           (null)
messages-20130414:Apr 13 22:53:00 RHEL7alpha1 kernel: [  964.326085] BUG: unable to handle kernel NULL pointer dereference at           (null)
[root@RHEL7alpha1 log]# vim messages-20130414
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182719] FS:  00007f12eeadc7c0(0000) GS:ffff88003c200000(0000) knlGS:0000000000000000
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182788] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182827] CR2: 0000000000000000 CR3: 000000003950d000 CR4: 00000000000006f0
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182872] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Process ls (pid: 1676, threadinfo ffff880037ae2000, task ffff880037cbcce0)
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Stack:
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b30 ffff8800371c2e38 ffff880037ae3b08 ffffffffa02ca5d8
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b90 0000000000000082 ffff88003434aa00 ffff88003887a764
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  ffff880037ae3b98 ffffffffa00e1d3d ffff880037ae3b68 ffff8800371c2e38
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Call Trace:
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02ca5d8>] nfs3_xdr_dec_readlink3res+0x58/0x70 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e1d3d>] rpcauth_unwrap_resp+0x9d/0xd0 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02ca580>] ? nfs3_xdr_dec_create3res+0x80/0x80 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d653e>] call_decode+0x17e/0x250 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e02a6>] __rpc_execute+0x66/0x1d0 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00e06d3>] rpc_execute+0x43/0x50 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d7af5>] rpc_run_task+0x75/0x90 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa00d7c13>] rpc_call_sync+0x43/0x70 [sunrpc]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02b6234>] ? nfs_alloc_fattr+0x24/0x70 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c74bb>] nfs3_rpc_wrapper.constprop.7+0x4b/0x80 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c796b>] nfs3_proc_readlink+0x8b/0xf0 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1f50>] nfs_symlink_filler+0x30/0x70 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c5f2>] do_read_cache_page+0x82/0x1a0
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02e53c0>] ? nfs_mark_delegation_referenced+0x10/0x10 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1f20>] ? nfs_follow_link+0xc0/0xc0 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c75c>] read_cache_page_async+0x1c/0x20
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff8114c76e>] read_cache_page+0xe/0x20
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffffa02c1ec8>] nfs_follow_link+0x68/0xc0 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811c0712>] generic_readlink+0x42/0xa0
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811b9e0d>] sys_readlinkat+0xad/0xb0
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff810f4bbe>] ? audit_syscall_entry+0x30e/0x330
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff811b9e2b>] sys_readlink+0x1b/0x20
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  [<ffffffff81639202>] system_call_fastpath+0x16/0x1b
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] Code: 2f e2 ff 48 85 c0 74 4d 44 8b 20 48 8b 53 08 41 0f cc 41 81 fc 00 10 00 00 77 71 44 39 62 2c 76 6b 48 8b 4b 18 48 8b 03 8b 52 38 <48> 2b 01 29 c2 44 39 e2 72 36 48 89 df 44 89 e6 e8 1a 2c e2 ff
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] RIP  [<ffffffffa02c96e1>] decode_nfspath3+0x41/0xd0 [nfs]
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914]  RSP <ffff880037ae3ac8>
Apr 13 04:29:40 RHEL7alpha1 kernel: [  963.182914] CR2: 0000000000000000



Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
---
 fs/nfs/nfs3xdr.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 183c6b1..6f53070 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -250,6 +250,8 @@ static int decode_nfspath3(struct xdr_stream *xdr)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
+	if (unlikely(xdr->iov == NULL))
+		goto iov_null;
 	count = be32_to_cpup(p);
 	if (unlikely(count >= xdr->buf->page_len || count > NFS3_MAXPATHLEN))
 		goto out_nametoolong;
@@ -269,6 +271,9 @@ out_cheating:
 	dprintk("NFS: server cheating in pathname result: "
 		"count %u > recvd %u\n", count, recvd);
 	return -EIO;
+iov_null:
+	dprintk("NFS: %s:xdr->iov is NULL\n", __func__);
+	return -EIO;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
@@ -1588,6 +1593,8 @@ static int decode_read3resok(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 4 + 4 + 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
+	if (unlikely(xdr->iov == NULL))
+		goto iov_null;
 	count = be32_to_cpup(p++);
 	eof = be32_to_cpup(p++);
 	ocount = be32_to_cpup(p++);
@@ -1613,6 +1620,9 @@ out_cheating:
 	count = recvd;
 	eof = 0;
 	goto out;
+iov_null:
+	dprintk("NFS: %s:xdr->iov is NULL\n", __func__);
+	return -EIO;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
-- 
1.7.7

--------------010205040603090308070604
Content-Type: application/octet-stream;
 name="dump.pcap"
Content-Disposition: attachment;
 filename="dump.pcap"
Content-Transfer-Encoding: base64

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
Pa4vkqiz


--------------010205040603090308070604--

