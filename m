Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50374 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750941AbdEDHCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 03:02:48 -0400
From: Jan Kara <jack@suse.cz>
To: Jens Axboe <axboe@kernel.dk>
Cc: <linux-block@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        Jan Kara <jack@suse.cz>
Subject: [PATCH] nfs: Fix bdi handling for cloned superblocks
Date: Thu,  4 May 2017 09:02:42 +0200
Message-Id: <20170504070242.31501-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In commit 0d3b12584972 "nfs: Convert to separately allocated bdi" I have
wrongly cloned bdi reference in nfs_clone_super(). Further inspection
has shown that originally the code was actually allocating a new bdi (in
->clone_server callback) which was later registered in
nfs_fs_mount_common() and used for sb->s_bdi in nfs_initialise_sb().
This could later result in bdi for the original superblock not getting
unregistered when that superblock got shutdown (as the cloned sb still
held bdi reference) and later when a new superblock was created under
the same anonymous device number, a clash in sysfs has happened on bdi
registration:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 10284 at /linux-next/fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x74
sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:32'
Modules linked in: axp20x_usb_power gpio_axp209 nvmem_sunxi_sid sun4i_dma sun4i_ss virt_dma
CPU: 1 PID: 10284 Comm: mount.nfs Not tainted 4.11.0-rc4+ #14
Hardware name: Allwinner sun7i (A20) Family
[<c010f19c>] (unwind_backtrace) from [<c010bc74>] (show_stack+0x10/0x14)
[<c010bc74>] (show_stack) from [<c03c6e24>] (dump_stack+0x78/0x8c)
[<c03c6e24>] (dump_stack) from [<c0122200>] (__warn+0xe8/0x100)
[<c0122200>] (__warn) from [<c0122250>] (warn_slowpath_fmt+0x38/0x48)
[<c0122250>] (warn_slowpath_fmt) from [<c02ac178>] (sysfs_warn_dup+0x64/0x74)
[<c02ac178>] (sysfs_warn_dup) from [<c02ac254>] (sysfs_create_dir_ns+0x84/0x94)
[<c02ac254>] (sysfs_create_dir_ns) from [<c03c8b8c>] (kobject_add_internal+0x9c/0x2ec)
[<c03c8b8c>] (kobject_add_internal) from [<c03c8e24>] (kobject_add+0x48/0x98)
[<c03c8e24>] (kobject_add) from [<c048d75c>] (device_add+0xe4/0x5a0)
[<c048d75c>] (device_add) from [<c048ddb4>] (device_create_groups_vargs+0xac/0xbc)
[<c048ddb4>] (device_create_groups_vargs) from [<c048dde4>] (device_create_vargs+0x20/0x28)
[<c048dde4>] (device_create_vargs) from [<c02075c8>] (bdi_register_va+0x44/0xfc)
[<c02075c8>] (bdi_register_va) from [<c023d378>] (super_setup_bdi_name+0x48/0xa4)
[<c023d378>] (super_setup_bdi_name) from [<c0312ef4>] (nfs_fill_super+0x1a4/0x204)
[<c0312ef4>] (nfs_fill_super) from [<c03133f0>] (nfs_fs_mount_common+0x140/0x1e8)
[<c03133f0>] (nfs_fs_mount_common) from [<c03335cc>] (nfs4_remote_mount+0x50/0x58)
[<c03335cc>] (nfs4_remote_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
[<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
[<c025cba0>] (vfs_kern_mount) from [<c033352c>] (nfs_do_root_mount+0x80/0xa0)
[<c033352c>] (nfs_do_root_mount) from [<c0333818>] (nfs4_try_mount+0x28/0x3c)
[<c0333818>] (nfs4_try_mount) from [<c0313874>] (nfs_fs_mount+0x2cc/0x8c4)
[<c0313874>] (nfs_fs_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
[<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
[<c025cba0>] (vfs_kern_mount) from [<c02600f0>] (do_mount+0x158/0xc7c)
[<c02600f0>] (do_mount) from [<c0260f98>] (SyS_mount+0x8c/0xb4)
[<c0260f98>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)

Fix the problem by always creating new bdi for a superblock as we used
to do.

Reported-and-tested-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Fixes: 0d3b12584972ce5781179ad3f15cca3cdb5cae05
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/internal.h |  6 +++---
 fs/nfs/super.c    | 28 ++++++++++------------------
 2 files changed, 13 insertions(+), 21 deletions(-)

Hi Jens,

can you please merge this fix to my series converting BDI handling in
filesystems? Thanks!

								Honza

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9dc65d7ae754..7b38fedb7e03 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -139,7 +139,7 @@ struct nfs_mount_request {
 };
 
 struct nfs_mount_info {
-	int (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
 	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
 	struct nfs_clone_mount *cloned;
@@ -407,7 +407,7 @@ struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *
 struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
 		const char *, struct nfs_mount_info *);
 void nfs_kill_super(struct super_block *);
-int nfs_fill_super(struct super_block *, struct nfs_mount_info *);
+void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 
 extern struct rpc_stat nfs_rpcstat;
 
@@ -458,7 +458,7 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
-int nfs_clone_super(struct super_block *, struct nfs_mount_info *);
+void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index dc69314d455e..2f3822a4a7d5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2321,11 +2321,10 @@ inline void nfs_initialise_sb(struct super_block *sb)
 /*
  * Finish setting up an NFS2/3 superblock
  */
-int nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	struct nfs_parsed_mount_data *data = mount_info->parsed;
 	struct nfs_server *server = NFS_SB(sb);
-	int ret;
 
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
@@ -2343,21 +2342,13 @@ int nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	}
 
  	nfs_initialise_sb(sb);
-
-	ret = super_setup_bdi_name(sb, "%u:%u", MAJOR(server->s_dev),
-				   MINOR(server->s_dev));
-	if (ret)
-		return ret;
-	sb->s_bdi->ra_pages = server->rpages * NFS_MAX_READAHEAD;
-	return 0;
-
 }
 EXPORT_SYMBOL_GPL(nfs_fill_super);
 
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-int nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 {
 	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
@@ -2377,10 +2368,6 @@ int nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	}
 
  	nfs_initialise_sb(sb);
-
-	sb->s_bdi = bdi_get(old_sb->s_bdi);
-
-	return 0;
 }
 
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
@@ -2600,14 +2587,19 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
+		error = super_setup_bdi_name(s, "%u:%u", MAJOR(server->s_dev),
+					     MINOR(server->s_dev));
+		if (error) {
+			mntroot = ERR_PTR(error);
+			goto error_splat_super;
+		}
+		s->s_bdi->ra_pages = server->rpages * NFS_MAX_READAHEAD;
 		server->super = s;
 	}
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		error = mount_info->fill_super(s, mount_info);
-		if (error)
-			goto error_splat_super;
+		mount_info->fill_super(s, mount_info);
 		nfs_get_cache_cookie(s, mount_info->parsed, mount_info->cloned);
 	}
 
-- 
2.12.0

