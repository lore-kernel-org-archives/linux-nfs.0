Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:56579 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab3JHIQn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Oct 2013 04:16:43 -0400
Received: by mail-wi0-f171.google.com with SMTP id hm2so6105171wib.10
        for <linux-nfs@vger.kernel.org>; Tue, 08 Oct 2013 01:16:41 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: nadav@primarydata.com, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH] SQUASHME: pnfsd: destroy fi_lo_lock at put time
Date: Tue,  8 Oct 2013 11:16:37 +0300
Message-Id: <1381220197-378-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the mutex lock is destroyed at nfsd4_free_file time
but on the nfsd4_process_open2 -> nfsd4_is_deleg_cur path, open->op_file
points to a nfs4_file that was never properly initialized and destroy_mutex
rightfully warns about that.

The following test reproduces the warning:
python testserver.py 192.168.122.37:/server --maketree open

Oct  7 20:10:49 localhost kernel: nfsv4 compound op #5/6: 18 (OP_OPEN)
Oct  7 20:10:49 localhost kernel: nfsd4_check_resp_size length 352, xb->page_len 0 tlen 0 pad 232
Oct  7 20:10:49 localhost kernel: NFSD: nfsd4_open filename DELEG1_1381165848 op_openowner           (null)
Oct  7 20:10:49 localhost kernel: renewing client (clientid 5252ea55/00000003)
Oct  7 20:10:49 localhost kernel: nfsd: fh_verify(16: 01010001 00000000 00004277 f9f8a80e 00000000 00000000)
Oct  7 20:10:49 localhost kernel: nfsd: nfsd_lookup(fh 16: 01010001 00000000 00004277 f9f8a80e 00000000 00000000, DELEG1_1381165848)
Oct  7 20:10:49 localhost kernel: nfsd: fh_compose(exp fd:01/18170 tmp/DELEG1_1381165848, ino=17154)
Oct  7 20:10:49 localhost kernel: nfsd: fh_verify(16: 01010001 00000000 00004302 9ad5e870 00000000 00000000)
Oct  7 20:10:49 localhost kernel: NFSD alloc_init_deleg
Oct  7 20:10:49 localhost kernel: NFSD: delegation stateid=(5252ea55/00000003/00000002/00000001)
Oct  7 20:10:49 localhost kernel: nfsd4_process_open2: stateid=(5252ea55/00000003/00000000/00000002)
Oct  7 20:10:49 localhost kernel: ------------[ cut here ]------------
Oct  7 20:10:49 localhost kernel: WARNING: CPU: 1 PID: 309 at /usr0/home/bhalevy/dev/linux-pnfs/kernel/mutex-debug.c:106 mutex_destroy+0x57/0x60()
Oct  7 20:10:49 localhost kernel: DEBUG_LOCKS_WARN_ON(mutex_is_locked(lock))
Oct  7 20:10:49 localhost kernel: Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc autofs4
Oct  7 20:10:49 localhost kernel: CPU: 1 PID: 309 Comm: nfsd Not tainted 3.12.0-rc3-pnfs+ #19
Oct  7 20:10:49 localhost kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Oct  7 20:10:49 localhost kernel: 0000000000000009 ffff880036f4fbd0 ffffffff81702320 ffff880036f4fc18
Oct  7 20:10:49 localhost kernel: ffff880036f4fc08 ffffffff81068b5d ffff88003b665628 ffff88003c2e4c40
Oct  7 20:10:49 localhost kernel: ffff88003b670160 0000000000000000 ffff88003d7efc80 ffff880036f4fc68
Oct  7 20:10:49 localhost kernel: Call Trace:
Oct  7 20:10:49 localhost kernel: [<ffffffff81702320>] dump_stack+0x54/0x74
Oct  7 20:10:49 localhost kernel: [<ffffffff81068b5d>] warn_slowpath_common+0x7d/0xa0
Oct  7 20:10:49 localhost kernel: [<ffffffff81068bcc>] warn_slowpath_fmt+0x4c/0x50
Oct  7 20:10:49 localhost kernel: [<ffffffff810df9a7>] mutex_destroy+0x57/0x60
Oct  7 20:10:49 localhost kernel: [<ffffffffa013ac7d>] nfsd4_cleanup_open_state+0x6d/0xd0 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa0125249>] nfsd4_open+0x1b9/0xa80 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa0125095>] ? nfsd4_open+0x5/0xa80 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa012607a>] nfsd4_proc_compound+0x56a/0x7b0 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa010ef0b>] nfsd_dispatch+0xbb/0x200 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa001f18d>] svc_process_common+0x46d/0x6e0 [sunrpc]
Oct  7 20:10:49 localhost kernel: [<ffffffffa001f507>] svc_process+0x107/0x170 [sunrpc]
Oct  7 20:10:49 localhost kernel: [<ffffffffa010e2a3>] nfsd+0xd3/0x160 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffffa010e1d0>] ? nfsd_destroy+0x220/0x220 [nfsd]
Oct  7 20:10:49 localhost kernel: [<ffffffff8109468d>] kthread+0xed/0x100
Oct  7 20:10:49 localhost kernel: [<ffffffff810e036d>] ? trace_hardirqs_off+0xd/0x10
Oct  7 20:10:49 localhost kernel: [<ffffffff810e3aed>] ? trace_hardirqs_on_caller+0xfd/0x1c0
Oct  7 20:10:49 localhost kernel: [<ffffffff810945a0>] ? insert_kthread_work+0x80/0x80
Oct  7 20:10:49 localhost kernel: [<ffffffff817155bc>] ret_from_fork+0x7c/0xb0
Oct  7 20:10:49 localhost kernel: [<ffffffff810945a0>] ? insert_kthread_work+0x80/0x80
Oct  7 20:10:49 localhost kernel: ---[ end trace 3f1862caf9f88967 ]---

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6918316..7306190 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -238,9 +238,6 @@ void put_client_renew(struct nfs4_client *clp)
 
 static void nfsd4_free_file(struct nfs4_file *f)
 {
-#if defined(CONFIG_PNFSD)
-	mutex_destroy(&f->fi_lo_lock);
-#endif /* CONFIG_PNFSD */
 	kmem_cache_free(file_slab, f);
 }
 
@@ -252,6 +249,9 @@ static struct inode *put_nfs4_file_common(struct nfs4_file *fi)
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&recall_lock);
 		ino = fi->fi_inode;
+#if defined(CONFIG_PNFSD)
+		mutex_destroy(&f->fi_lo_lock);
+#endif /* CONFIG_PNFSD */
 		nfsd4_free_file(fi);
 
 		return ino;
-- 
1.8.3.1

