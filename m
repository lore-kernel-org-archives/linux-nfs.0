Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33572 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756492AbbIUKDj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 06:03:39 -0400
Received: by pacex6 with SMTP id ex6so112769574pac.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 03:03:39 -0700 (PDT)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFS: Skip checking ds_cinfo.buckets when lseg's
 commit_through_mds is set
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>, kinglongmee@gmail.com
Message-ID: <55FFD5F0.5030600@gmail.com>
Date: Mon, 21 Sep 2015 18:03:28 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When lseg's commit_through_mds is set, pnfs client always WARN once
in nfs_direct_select_verf when checking ds_cinfo.nbuckets.

But, filelayout_alloc_commit_info will not initialize the ds_cinfo.nbuckets.
It's wrong of checking ds_cinfo.nbuckets, client should skip it.

[17844.666094] ------------[ cut here ]------------
[17844.667071] WARNING: CPU: 0 PID: 21758 at /root/source/linux-pnfs/fs/nfs/direct.c:174 nfs_direct_select_verf+0x5a/0x70 [nfs]()
[17844.668650] Modules linked in: nfs_layout_nfsv41_files(OE) nfsv4(OE) nfs(OE) fscache(E) nfsd(OE) xfs libcrc32c btrfs ppdev coretemp crct10dif_pclmul auth_rpcgss crc32_pclmul crc32c_intel nfs_acl ghash_clmulni_intel lockd vmw_balloon xor vmw_vmci grace raid6_pq shpchp sunrpc parport_pc i2c_piix4 parport vmwgfx drm_kms_helper ttm drm serio_raw mptspi e1000 scsi_transport_spi mptscsih mptbase ata_generic pata_acpi [last unloaded: fscache]
[17844.686676] CPU: 0 PID: 21758 Comm: kworker/0:1 Tainted: G        W  OE   4.3.0-rc1-pnfs+ #245
[17844.687352] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/20/2014
[17844.698502] Workqueue: nfsiod rpc_async_release [sunrpc]
[17844.699212]  0000000000000009 0000000043e58010 ffff8800454fbc10 ffffffff813680c4
[17844.699990]  ffff8800454fbc48 ffffffff8108b49d ffff88004eb20000 ffff88004eb20000
[17844.700844]  ffff880062e26000 0000000000000000 0000000000000001 ffff8800454fbc58
[17844.701637] Call Trace:
[17844.725252]  [<ffffffff813680c4>] dump_stack+0x19/0x25
[17844.732693]  [<ffffffff8108b49d>] warn_slowpath_common+0x7d/0xb0
[17844.733855]  [<ffffffff8108b5da>] warn_slowpath_null+0x1a/0x20
[17844.735015]  [<ffffffffa04a27ca>] nfs_direct_select_verf+0x5a/0x70 [nfs]
[17844.735999]  [<ffffffffa04a2b83>] nfs_direct_set_hdr_verf+0x23/0x90 [nfs]
[17844.736846]  [<ffffffffa04a2e17>] nfs_direct_write_completion+0x227/0x260 [nfs]
[17844.737782]  [<ffffffffa04a433c>] nfs_pgio_release+0x1c/0x20 [nfs]
[17844.738597]  [<ffffffffa0502df3>] pnfs_generic_rw_release+0x23/0x30 [nfsv4]
[17844.739486]  [<ffffffffa01cbbea>] rpc_free_task+0x2a/0x70 [sunrpc]
[17844.740326]  [<ffffffffa01cbcd5>] rpc_async_release+0x15/0x20 [sunrpc]
[17844.741173]  [<ffffffff810a387c>] process_one_work+0x21c/0x4c0
[17844.741984]  [<ffffffff810a37cd>] ? process_one_work+0x16d/0x4c0
[17844.742837]  [<ffffffff810a3b6a>] worker_thread+0x4a/0x440
[17844.743639]  [<ffffffff810a3b20>] ? process_one_work+0x4c0/0x4c0
[17844.744399]  [<ffffffff810a3b20>] ? process_one_work+0x4c0/0x4c0
[17844.745176]  [<ffffffff810a8d75>] kthread+0xf5/0x110
[17844.745927]  [<ffffffff810a8c80>] ? kthread_create_on_node+0x240/0x240
[17844.747105]  [<ffffffff8172ce1f>] ret_from_fork+0x3f/0x70
[17844.747856]  [<ffffffff810a8c80>] ? kthread_create_on_node+0x240/0x240
[17844.748642] ---[ end trace 336a2845d42b83f0 ]---

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/direct.c                | 2 +-
 fs/nfs/filelayout/filelayout.c | 5 ++++-
 include/linux/nfs_xdr.h        | 1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 38678d9..df3b6f4 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -166,7 +166,7 @@ nfs_direct_select_verf(struct nfs_direct_req *dreq,
 	struct nfs_writeverf *verfp = &dreq->verf;
 
 #ifdef CONFIG_NFS_V4_1
-	if (ds_clp) {
+	if (ds_clp && !dreq->ds_cinfo.through_mds) {
 		/* pNFS is in use, use the DS verf */
 		if (commit_idx >= 0 && commit_idx < dreq->ds_cinfo.nbuckets)
 			verfp = &dreq->ds_cinfo.buckets[commit_idx].direct_verf;
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index b34f2e2..a0ceedd 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -774,8 +774,10 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	struct pnfs_commit_bucket *buckets;
 	int size, i;
 
-	if (fl->commit_through_mds)
+	if (fl->commit_through_mds) {
+		cinfo->ds->through_mds = true;
 		return 0;
+	}
 
 	size = (fl->stripe_type == STRIPE_SPARSE) ?
 		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
@@ -816,6 +818,7 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	}
 	swap(cinfo->ds->buckets, buckets);
 	cinfo->ds->nbuckets = size;
+	cinfo->ds->through_mds = false;
 out:
 	spin_unlock(cinfo->lock);
 	kfree(buckets);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52faf7e..fb49189 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1161,6 +1161,7 @@ struct pnfs_commit_bucket {
 };
 
 struct pnfs_ds_commit_info {
+	bool through_mds;
 	int nwritten;
 	int ncommitting;
 	int nbuckets;
-- 
2.5.0


