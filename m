From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] nfsd hangs 2.6.28 through 2.6.28.7
Date: Fri, 13 Mar 2009 16:16:57 -0400
Message-ID: <20090313201657.GB30252@fieldses.org>
References: <49AC747F.6010001@atmos.washington.edu> <49ACF77F.303@suse.de> <49B6D9A2.8050106@atmos.washington.edu> <49B8AFF8.6080203@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org, linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40086 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZCMURB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 16:17:01 -0400
In-Reply-To: <49B8AFF8.6080203@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:17:20PM +0530, Suresh Jayaraman wrote:
> David Warren wrote:
> >>> We are seeing nfsd getting stuck in d wait at boot time. The fix seems
> >>> to be stopping in single user mode prior to nfs starting, renaming
> >>> /var/lib/nfs/v4recovery/ and making a new one, then letting the system
> >>> continue. When it boots and hangs, all processes that touch
> >>> /var/lib/nfs/v4recovery/ go into D-wait. However, if you rename it and
...
> [748031.952208] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [748272.256202] SysRq : Show Blocked State
> [748272.260073]   task                        PC stack   pid father
> [748272.260073] rpc.nfsd      D 0000000000001000     0 26913  26906
> [748272.260073]  ffff88010efa7798 0000000000000086 ffff88012fb34300 ffff88005d4af380
> [748272.260073]  ffffffff805e6e40 ffff88005d4af380 ffff88001b077c00 ffff88012f99e050
> [748272.260073]  ffff88012d670cf0 ffff88012f99e2c0 0000000100000000 ffff88012f99e2c0
> [748272.260073] Call Trace:
> [748272.260073]  [<ffffffff804000ab>] udp_push_pending_frames+0x2bf/0x320
> [748272.260073]  [<ffffffff8042e309>] schedule_timeout+0x1e/0xc9
> [748272.260073]  [<ffffffff8042ec71>] __down+0x5e/0x8b
> [748272.260073]  [<ffffffff802471fb>] down+0x27/0x36
> [748272.260073]  [<ffffffffa019af10>] _xfs_buf_find+0x163/0x1f6 [xfs]
> [748272.260073]  [<ffffffffa019affd>] xfs_buf_get_flags+0x5a/0x148 [xfs]
> [748272.260073]  [<ffffffffa019b0fd>] xfs_buf_read_flags+0x12/0x81 [xfs]
> [748272.260073]  [<ffffffffa0190ef1>] xfs_trans_read_buf+0x47/0x2af [xfs]
> [748272.260073]  [<ffffffffa016be99>] xfs_da_do_buf+0x410/0x622 [xfs]
> [748272.260073]  [<ffffffff80228a4b>] dequeue_entity+0x18/0x11f
> [748272.260073]  [<ffffffffa016c115>] xfs_da_read_buf+0x24/0x29 [xfs]
> [748272.260073]  [<ffffffffa016f784>] xfs_dir2_block_lookup_int+0x47/0x1b2 [xfs]
> [748272.260073]  [<ffffffffa016f784>] xfs_dir2_block_lookup_int+0x47/0x1b2 [xfs]
> [748272.260073]  [<ffffffffa016fd2b>] xfs_dir2_block_lookup+0x18/0xb1 [xfs]
> [748272.260073]  [<ffffffffa016ea5d>] xfs_dir_lookup+0xdd/0x14f [xfs]
> [748272.260073]  [<ffffffffa019539a>] xfs_lookup+0x48/0xa5 [xfs]
> [748272.260073]  [<ffffffff80388b8b>] wait_for_xmitr+0x40/0x87
> [748272.260073]  [<ffffffffa019d9ef>] xfs_vn_lookup+0x3c/0x78 [xfs]
> [748272.260073]  [<ffffffff8029e3d9>] __lookup_hash+0xfa/0x11e
> [748272.260073]  [<ffffffff8029e523>] lookup_one_len+0x6c/0x7f
> [748272.260073]  [<ffffffffa034e2d8>] nfsd4_build_dentrylist+0x2f/0x7a [nfsd]
> [748272.260073]  [<ffffffffa016fb00>] xfs_dir2_block_getdents+0x15d/0x1bc [xfs]
> [748272.260073]  [<ffffffffa034e2a9>] nfsd4_build_dentrylist+0x0/0x7a [nfsd]
> [748272.260073]  [<ffffffffa034e2a9>] nfsd4_build_dentrylist+0x0/0x7a [nfsd]
> [748272.260073]  [<ffffffffa016e834>] xfs_readdir+0x93/0xb8 [xfs]
> [748272.260073]  [<ffffffffa034e2a9>] nfsd4_build_dentrylist+0x0/0x7a [nfsd]
> [748272.260073]  [<ffffffffa019b4c9>] xfs_file_readdir+0x31/0x40 [xfs]
> [748272.260073]  [<ffffffff802a31f7>] vfs_readdir+0x75/0xa7
> [748272.260073]  [<ffffffffa034e323>] load_recdir+0x0/0x2a [nfsd]
> [748272.260073]  [<ffffffffa034e197>] nfsd4_list_rec_dir+0xde/0x1b9 [nfsd]
> [748272.260073]  [<ffffffffa034e286>] nfsd4_recdir_load+0x14/0x37 [nfsd]
> [748272.260073]  [<ffffffffa034a09d>] nfs4_state_start+0x2b/0xf6 [nfsd]
> [748272.260073]  [<ffffffffa0332592>] nfsd_svc+0x5a/0xfd [nfsd]
> [748272.260073]  [<ffffffffa033321b>] write_threads+0x0/0xad [nfsd]
> [748272.260073]  [<ffffffffa0333280>] write_threads+0x65/0xad [nfsd]
> [748272.260073]  [<ffffffff802757b3>] get_zeroed_page+0x1a/0x7d
> [748272.260073]  [<ffffffff802ae3c1>] simple_transaction_get+0x8a/0xa4
> [748272.260073]  [<ffffffffa033321b>] write_threads+0x0/0xad [nfsd]
> [748272.260073]  [<ffffffffa0332985>] nfsctl_transaction_write+0x43/0x72 [nfsd]
> [748272.260073]  [<ffffffff8029777c>] vfs_write+0xad/0x156
> [748272.260073]  [<ffffffff802978e1>] sys_write+0x45/0x6e
> [748272.260073]  [<ffffffff8020bd7b>] system_call_fastpath+0x16/0x1b

Thanks for the report; does this (only lightly tested!) fix the problem?

--b.

commit 33954a0f2cba831801f047813566791ef254b80b
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Mar 13 16:02:59 2009 -0400

    nfsd4: don't do lookup within readdir in recovery code
    
    The main nfsd code was recently modified to no longer do lookups from
    withing the readdir callback, to avoid locking problems on certain
    filesystems.
    
    This (rather hacky, and overdue for replacement) NFSv4 recovery code has
    the same problem.  Fix it to build up a list of names (instead of
    dentries) and do the lookups afterwards.
    
    Reported symptoms were a deadlock in the xfs code (called from
    nfsd4_recdir_load), with /var/lib/nfs on xfs.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Reported-by: David Warren <warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 74f7b67..b0fdc33 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -182,36 +182,26 @@ out_unlock:
 
 typedef int (recdir_func)(struct dentry *, struct dentry *);
 
-struct dentry_list {
-	struct dentry *dentry;
+struct name_list {
+	char name[HEXDIR_LEN];
 	struct list_head list;
 };
 
-struct dentry_list_arg {
-	struct list_head dentries;
-	struct dentry *parent;
-};
-
 static int
-nfsd4_build_dentrylist(void *arg, const char *name, int namlen,
+nfsd4_build_namelist(void *arg, const char *name, int namlen,
 		loff_t offset, u64 ino, unsigned int d_type)
 {
-	struct dentry_list_arg *dla = arg;
-	struct list_head *dentries = &dla->dentries;
-	struct dentry *parent = dla->parent;
-	struct dentry *dentry;
-	struct dentry_list *child;
+	struct list_head *names = arg;
+	struct name_list *entry;
 
-	if (name && isdotent(name, namlen))
+	if (namlen != HEXDIR_LEN -1)
 		return 0;
-	dentry = lookup_one_len(name, parent, namlen);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-	child = kmalloc(sizeof(*child), GFP_KERNEL);
-	if (child == NULL)
+	entry = kmalloc(sizeof(struct name_list), GFP_KERNEL);
+	if (entry == NULL)
 		return -ENOMEM;
-	child->dentry = dentry;
-	list_add(&child->list, dentries);
+	memcpy(entry->name, name, HEXDIR_LEN - 1);
+	entry->name[HEXDIR_LEN] = '\0';
+	list_add(&entry->list, names);
 	return 0;
 }
 
@@ -220,11 +210,9 @@ nfsd4_list_rec_dir(struct dentry *dir, recdir_func *f)
 {
 	const struct cred *original_cred;
 	struct file *filp;
-	struct dentry_list_arg dla = {
-		.parent = dir,
-	};
-	struct list_head *dentries = &dla.dentries;
-	struct dentry_list *child;
+	LIST_HEAD(names);
+	struct name_list *entry;
+	struct dentry *dentry;
 	int status;
 
 	if (!rec_dir_init)
@@ -233,31 +221,34 @@ nfsd4_list_rec_dir(struct dentry *dir, recdir_func *f)
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return status;
-	INIT_LIST_HEAD(dentries);
 
 	filp = dentry_open(dget(dir), mntget(rec_dir.mnt), O_RDONLY,
 			   current_cred());
 	status = PTR_ERR(filp);
 	if (IS_ERR(filp))
 		goto out;
-	INIT_LIST_HEAD(dentries);
-	status = vfs_readdir(filp, nfsd4_build_dentrylist, &dla);
+	status = vfs_readdir(filp, nfsd4_build_namelist, &names);
 	fput(filp);
-	while (!list_empty(dentries)) {
-		child = list_entry(dentries->next, struct dentry_list, list);
-		status = f(dir, child->dentry);
+	while (!list_empty(&names)) {
+		entry = list_entry(names.next, struct name_list, list);
+
+		dentry = lookup_one_len(entry->name, dir, HEXDIR_LEN-1);
+		if (IS_ERR(dentry)) {
+			status = PTR_ERR(dentry);
+			goto out;
+		}
+		status = f(dir, dentry);
+		dput(dentry);
 		if (status)
 			goto out;
-		list_del(&child->list);
-		dput(child->dentry);
-		kfree(child);
+		list_del(&entry->list);
+		kfree(entry);
 	}
 out:
-	while (!list_empty(dentries)) {
-		child = list_entry(dentries->next, struct dentry_list, list);
-		list_del(&child->list);
-		dput(child->dentry);
-		kfree(child);
+	while (!list_empty(&names)) {
+		entry = list_entry(names.next, struct name_list, list);
+		list_del(&entry->list);
+		kfree(entry);
 	}
 	nfs4_reset_creds(original_cred);
 	return status;
