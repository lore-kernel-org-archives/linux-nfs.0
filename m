Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34787 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbbG0Hbu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 03:31:50 -0400
Received: by pdbbh15 with SMTP id bh15so47422034pdb.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 00:31:49 -0700 (PDT)
Message-ID: <55B5DE5A.2060507@gmail.com>
Date: Mon, 27 Jul 2015 15:31:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeffrey Layton <jeff.layton@primarydata.com>, kinglongmee@gmail.com
Subject: [PATCH] nfs: Fix an oops caused by using other thread's stack space
 in ASYNC mode
References: <CAB6yy34dK0zPTB=FyEGb=Ljc7jAc_xi7ci17LU3JA=nEeXdkUA@mail.gmail.com>
In-Reply-To: <CAB6yy34dK0zPTB=FyEGb=Ljc7jAc_xi7ci17LU3JA=nEeXdkUA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An oops caused by using other thread's stack space in sunrpc ASYNC sending thread.

[ 9839.007187] ------------[ cut here ]------------
[ 9839.007923] kernel BUG at fs/nfs/nfs4xdr.c:910!
[ 9839.008069] invalid opcode: 0000 [#1] SMP
[ 9839.008069] Modules linked in: blocklayoutdriver rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm joydev iosf_mbi crct10dif_pclmul snd_timer crc32_pclmul crc32c_intel ghash_clmulni_intel snd soundcore ppdev pvpanic parport_pc i2c_piix4 serio_raw virtio_balloon parport acpi_cpufreq nfsd nfs_acl lockd grace auth_rpcgss sunrpc qxl drm_kms_helper virtio_net virtio_console virtio_blk ttm drm virtio_pci virtio_ring virtio ata_generic pata_acpi
[ 9839.008069] CPU: 0 PID: 308 Comm: kworker/0:1H Not tainted 4.0.0-0.rc4.git1.3.fc23.x86_64 #1
[ 9839.008069] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 9839.008069] Workqueue: rpciod rpc_async_schedule [sunrpc]
[ 9839.008069] task: ffff8800d8b4d8e0 ti: ffff880036678000 task.ti: ffff880036678000
[ 9839.008069] RIP: 0010:[<ffffffffa0339cc9>]  [<ffffffffa0339cc9>] reserve_space.part.73+0x9/0x10 [nfsv4]
[ 9839.008069] RSP: 0018:ffff88003667ba58  EFLAGS: 00010246
[ 9839.008069] RAX: 0000000000000000 RBX: 000000001fc15e18 RCX: ffff8800c0193800
[ 9839.008069] RDX: ffff8800e4ae3f24 RSI: 000000001fc15e2c RDI: ffff88003667bcd0
[ 9839.008069] RBP: ffff88003667ba58 R08: ffff8800d9173008 R09: 0000000000000003
[ 9839.008069] R10: ffff88003667bcd0 R11: 000000000000000c R12: 0000000000010000
[ 9839.008069] R13: ffff8800d9173350 R14: 0000000000000000 R15: ffff8800c0067b98
[ 9839.008069] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000) knlGS:0000000000000000
[ 9839.008069] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 9839.008069] CR2: 00007f988c9c8bb0 CR3: 00000000d99b6000 CR4: 00000000000407f0
[ 9839.008069] Stack:
[ 9839.008069]  ffff88003667bbc8 ffffffffa03412c5 00000000c6c55680 ffff880000000003
[ 9839.008069]  0000000000000088 00000010c6c55680 0001000000000002 ffffffff816e87e9
[ 9839.008069]  0000000000000000 00000000477290e2 ffff88003667bab8 ffffffff81327ba3
[ 9839.008069] Call Trace:
[ 9839.008069]  [<ffffffffa03412c5>] encode_attrs+0x435/0x530 [nfsv4]
[ 9839.008069]  [<ffffffff816e87e9>] ? inet_sendmsg+0x69/0xb0
[ 9839.008069]  [<ffffffff81327ba3>] ? selinux_socket_sendmsg+0x23/0x30
[ 9839.008069]  [<ffffffff8164c1df>] ? do_sock_sendmsg+0x9f/0xc0
[ 9839.008069]  [<ffffffff8164c278>] ? kernel_sendmsg+0x58/0x70
[ 9839.008069]  [<ffffffffa011acc0>] ? xdr_reserve_space+0x20/0x170 [sunrpc]
[ 9839.008069]  [<ffffffffa011acc0>] ? xdr_reserve_space+0x20/0x170 [sunrpc]
[ 9839.008069]  [<ffffffffa0341b40>] ? nfs4_xdr_enc_open_noattr+0x130/0x130 [nfsv4]
[ 9839.008069]  [<ffffffffa03419a5>] encode_open+0x2d5/0x340 [nfsv4]
[ 9839.008069]  [<ffffffffa0341b40>] ? nfs4_xdr_enc_open_noattr+0x130/0x130 [nfsv4]
[ 9839.008069]  [<ffffffffa011ab89>] ? xdr_encode_opaque+0x19/0x20 [sunrpc]
[ 9839.008069]  [<ffffffffa0339cfb>] ? encode_string+0x2b/0x40 [nfsv4]
[ 9839.008069]  [<ffffffffa0341bf3>] nfs4_xdr_enc_open+0xb3/0x140 [nfsv4]
[ 9839.008069]  [<ffffffffa0110a4c>] rpcauth_wrap_req+0xac/0xf0 [sunrpc]
[ 9839.008069]  [<ffffffffa01017db>] call_transmit+0x18b/0x2d0 [sunrpc]
[ 9839.008069]  [<ffffffffa0101650>] ? call_decode+0x860/0x860 [sunrpc]
[ 9839.008069]  [<ffffffffa0101650>] ? call_decode+0x860/0x860 [sunrpc]
[ 9839.008069]  [<ffffffffa010caa0>] __rpc_execute+0x90/0x460 [sunrpc]
[ 9839.008069]  [<ffffffffa010ce85>] rpc_async_schedule+0x15/0x20 [sunrpc]
[ 9839.008069]  [<ffffffff810b452b>] process_one_work+0x1bb/0x410
[ 9839.008069]  [<ffffffff810b47d3>] worker_thread+0x53/0x470
[ 9839.008069]  [<ffffffff810b4780>] ? process_one_work+0x410/0x410
[ 9839.008069]  [<ffffffff810b4780>] ? process_one_work+0x410/0x410
[ 9839.008069]  [<ffffffff810ba7b8>] kthread+0xd8/0xf0
[ 9839.008069]  [<ffffffff810ba6e0>] ? kthread_worker_fn+0x180/0x180
[ 9839.008069]  [<ffffffff81786418>] ret_from_fork+0x58/0x90
[ 9839.008069]  [<ffffffff810ba6e0>] ? kthread_worker_fn+0x180/0x180
[ 9839.008069] Code: 00 00 48 c7 c7 21 fa 37 a0 e8 94 1c d6 e0 c6 05 d2 17 05 00 01 8b 03 eb d7 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 <0f> 0b 0f 1f 44 00 00 66 66 66 66 90 55 48 89 e5 41 54 53 89 f3
[ 9839.008069] RIP  [<ffffffffa0339cc9>] reserve_space.part.73+0x9/0x10 [nfsv4]
[ 9839.008069]  RSP <ffff88003667ba58>
[ 9839.071114] ---[ end trace cc14c03adb522e94 ]---

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/internal.h | 16 ++++++++++++++++
 fs/nfs/nfs4proc.c | 10 +++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7e3c460..5594fe4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -296,6 +296,22 @@ extern struct rpc_procinfo nfs4_procedures[];
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 extern struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags);
+static inline struct nfs4_label *
+nfs4_label_copy(struct nfs4_label *dst, struct nfs4_label *src)
+{
+	if (!dst || !src)
+		return NULL;
+
+	if (src->len > NFS4_MAXLABELLEN)
+		return NULL;
+
+	dst->lfs = src->lfs;
+	dst->pi = src->pi;
+	dst->len = src->len;
+	memcpy(dst->label, src->label, src->len);
+
+	return dst;
+}
 static inline void nfs4_label_free(struct nfs4_label *label)
 {
 	if (label) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8bee934..295bb6f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -910,6 +910,7 @@ struct nfs4_opendata {
 	struct nfs_open_confirmres c_res;
 	struct nfs4_string owner_name;
 	struct nfs4_string group_name;
+	struct nfs4_label *a_label;
 	struct nfs_fattr f_attr;
 	struct nfs4_label *f_label;
 	struct dentry *dir;
@@ -1013,6 +1014,10 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	if (IS_ERR(p->f_label))
 		goto err_free_p;
 
+	p->a_label = nfs4_label_alloc(server, gfp_mask);
+	if (IS_ERR(p->f_label))
+		goto err_free_f;
+
 	alloc_seqid = server->nfs_client->cl_mvops->alloc_seqid;
 	p->o_arg.seqid = alloc_seqid(&sp->so_seqid, gfp_mask);
 	if (IS_ERR(p->o_arg.seqid))
@@ -1041,7 +1046,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = nfs4_bitmask(server, label);
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
-	p->o_arg.label = label;
+	p->o_arg.label = nfs4_label_copy(p->a_label, label);
 	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
 	switch (p->o_arg.claim) {
 	case NFS4_OPEN_CLAIM_NULL:
@@ -1074,6 +1079,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	return p;
 
 err_free_label:
+	nfs4_label_free(p->a_label);
+err_free_f:
 	nfs4_label_free(p->f_label);
 err_free_p:
 	kfree(p);
@@ -1093,6 +1100,7 @@ static void nfs4_opendata_free(struct kref *kref)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
 
+	nfs4_label_free(p->a_label);
 	nfs4_label_free(p->f_label);
 
 	dput(p->dir);
-- 
2.4.3


