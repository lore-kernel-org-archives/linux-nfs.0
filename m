Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35303 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965836AbbD1QKV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 12:10:21 -0400
Received: by pabli10 with SMTP id li10so45888593pab.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2015 09:10:20 -0700 (PDT)
Message-ID: <553FB0E7.7070601@gmail.com>
Date: Wed, 29 Apr 2015 00:10:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Avoid race of locking parent's mutex at cross mount
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pseudo root, there is a mutex race between
nfsd and rpc.mountd for locking parent inode.

nfs-utils commit 6091c0a4c4 
("mountd: add support for case-insensitive file names")
adds using name_to_handle_at which will locking parent.

Apr 27 19:57:03 ntest kernel: rpc.mountd      D ffff88006ac5fc28     0  1152      1 0x00000000
Apr 27 19:57:03 ntest kernel: ffff88006ac5fc28 ffff880068c38970 ffff880068c3de60 ffff88006ac5fc08
Apr 27 19:57:03 ntest kernel: ffff88006ac60000 ffff880035ecf694 ffff880068c3de60 00000000ffffffff
Apr 27 19:57:03 ntest kernel: ffff880035ecf698 ffff88006ac5fc48 ffffffff8177ffd7 0000000000000000
Apr 27 19:57:03 ntest kernel: Call Trace:
Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
Apr 27 19:57:03 ntest kernel: [<ffffffff8178031e>] schedule_preempt_disabled+0xe/0x10
Apr 27 19:57:03 ntest kernel: [<ffffffff81781e92>] __mutex_lock_slowpath+0xb2/0x120
Apr 27 19:57:03 ntest kernel: [<ffffffff81781f23>] mutex_lock+0x23/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff81230714>] lookup_slow+0x34/0xc0
Apr 27 19:57:03 ntest kernel: [<ffffffff812358ee>] path_lookupat+0x89e/0xc60
Apr 27 19:57:03 ntest kernel: [<ffffffff81205192>] ? kmem_cache_alloc+0x1e2/0x260
Apr 27 19:57:03 ntest kernel: [<ffffffff812367a6>] ? getname_flags+0x56/0x200
Apr 27 19:57:03 ntest kernel: [<ffffffff81235cd7>] filename_lookup+0x27/0xc0
Apr 27 19:57:03 ntest kernel: [<ffffffff81237b53>] user_path_at_empty+0x63/0xd0
Apr 27 19:57:03 ntest kernel: [<ffffffff8121d722>] ? put_object+0x32/0x60
Apr 27 19:57:03 ntest kernel: [<ffffffff8121d94d>] ? delete_object_full+0x2d/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff8123e273>] ? dput+0x33/0x230
Apr 27 19:57:03 ntest kernel: [<ffffffff81237bd1>] user_path_at+0x11/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffff81286489>] SyS_name_to_handle_at+0x59/0x200
Apr 27 19:57:03 ntest kernel: [<ffffffff81783f6e>] system_call_fastpath+0x12/0x71
Apr 27 19:57:03 ntest kernel: nfsd            S ffff88006e92b708     0  1170      2 0x00000000
Apr 27 19:57:03 ntest kernel: ffff88006e92b708 ffffffff81c12480 ffff88006acbcb80 ffff88006e92b758
Apr 27 19:57:03 ntest kernel: ffff88006e92c000 ffffffff82290040 ffff88006e92b758 ffffffff82290040
Apr 27 19:57:03 ntest kernel: 00000000fffffff5 ffff88006e92b728 ffffffff8177ffd7 0000000100043a09
Apr 27 19:57:03 ntest kernel: Call Trace:
Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
Apr 27 19:57:03 ntest kernel: [<ffffffff81782e97>] schedule_timeout+0x117/0x230
Apr 27 19:57:03 ntest kernel: [<ffffffff8110b240>] ? internal_add_timer+0xb0/0xb0
Apr 27 19:57:03 ntest kernel: [<ffffffff81780ff3>] wait_for_completion_interruptible_timeout+0xf3/0x150
Apr 27 19:57:03 ntest kernel: [<ffffffff810cb090>] ? wake_up_state+0x20/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffffa01350cc>] cache_wait_req.isra.10+0x9c/0x110 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0134760>] ? sunrpc_init_cache_detail+0xc0/0xc0 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0135c54>] cache_check+0x1d4/0x380 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffff8133248c>] ? inode_doinit_with_dentry+0x48c/0x6a0
Apr 27 19:57:03 ntest kernel: [<ffffffffa045e132>] exp_get_by_name+0x82/0xb0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffff81776d0a>] ? kmemleak_free+0x3a/0xa0
Apr 27 19:57:03 ntest kernel: [<ffffffff81332210>] ? inode_doinit_with_dentry+0x210/0x6a0
Apr 27 19:57:03 ntest kernel: [<ffffffff813326bc>] ? selinux_d_instantiate+0x1c/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffff8123def7>] ? _d_rehash+0x37/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff8123f776>] ? d_splice_alias+0xa6/0x2d0
Apr 27 19:57:03 ntest kernel: [<ffffffff812be90b>] ? ext4_lookup+0xdb/0x160
Apr 27 19:57:03 ntest kernel: [<ffffffffa0460114>] rqst_exp_get_by_name+0x64/0x140 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045a8f6>] nfsd_cross_mnt+0x76/0x1b0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0475300>] nfsd4_encode_dirent+0x160/0x3d0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa04751a0>] ? nfsd4_encode_getattr+0x40/0x40 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045c631>] nfsd_readdir+0x1c1/0x2a0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045a1e0>] ? nfsd_direct_splice_actor+0x20/0x20 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa046bd70>] nfsd4_encode_readdir+0x120/0x220 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa047573d>] nfsd4_encode_operation+0x7d/0x190 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa046a51d>] nfsd4_proc_compound+0x24d/0x6f0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0455f83>] nfsd_dispatch+0xc3/0x220 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa012a01b>] svc_process_common+0x43b/0x690 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa012b133>] svc_process+0x103/0x1b0 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045596f>] nfsd+0xff/0x170 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0455870>] ? nfsd_destroy+0x80/0x80 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd378>] kthread+0xd8/0xf0
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x180/0x180
Apr 27 19:57:03 ntest kernel: [<ffffffff81784362>] ret_from_fork+0x42/0x70
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x180/0x180

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 12 +++++++-----
 fs/nfsd/vfs.c     |  5 ++++-
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 158badf..b1aa934 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2800,11 +2800,11 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
 			const char *name, int namlen)
 {
 	struct svc_export *exp = cd->rd_fhp->fh_export;
-	struct dentry *dentry;
+	struct dentry *dentry, *parent = cd->rd_fhp->fh_dentry;
 	__be32 nfserr;
 	int ignore_crossmnt = 0;
 
-	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
+	dentry = lookup_one_len(name, parent, namlen);
 	if (IS_ERR(dentry))
 		return nfserrno(PTR_ERR(dentry));
 	if (d_really_is_negative(dentry)) {
@@ -2826,7 +2826,7 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
 	 * directly from the mountpoint dentry.
 	 */
 	if (nfsd_mountpoint(dentry, exp)) {
-		int err;
+		int err, lock_err;
 
 		if (!(exp->ex_flags & NFSEXP_V4ROOT)
 				&& !attributes_need_mount(cd->rd_bmval)) {
@@ -2838,9 +2838,11 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
 		 * Different "."/".." handling?  Something else?
 		 * At least, add a comment here to explain....
 		 */
+		mutex_unlock(&d_inode(parent)->i_mutex);
 		err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
-		if (err) {
-			nfserr = nfserrno(err);
+		lock_err = mutex_lock_killable(&d_inode(parent)->i_mutex);
+		if (err || lock_err) {
+			nfserr = nfserrno(err ? err : lock_err);
 			goto out_put;
 		}
 		nfserr = check_nfsd_access(exp, cd->rd_rqstp);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84d770b..44420e4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -221,7 +221,10 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 * check if we have crossed a mount point ...
 		 */
 		if (nfsd_mountpoint(dentry, exp)) {
-			if ((host_err = nfsd_cross_mnt(rqstp, &dentry, &exp))) {
+			mutex_unlock(&d_inode(dparent)->i_mutex);
+			host_err = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			mutex_lock_nested(&d_inode(dparent)->i_mutex, I_MUTEX_PARENT);
+			if (host_err) {
 				dput(dentry);
 				goto out_nfserr;
 			}
-- 
2.3.6

