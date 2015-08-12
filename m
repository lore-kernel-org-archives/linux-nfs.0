Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34458 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345AbbHLKaf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2015 06:30:35 -0400
Received: by pawu10 with SMTP id u10so11978498paw.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2015 03:30:35 -0700 (PDT)
From: Viresh Kumar <viresh.kumar@linaro.org>
To: trivial@kernel.org
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
        Viresh Kumar <viresh.kumar@linaro.org>,
        David Howells <dhowells@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Andrew Morton <akpm@linux-foundation.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Boaz Harrosh <ooo@electrozaur.com>, Christoph Hellwig <hch@lst.de>,
        ecryptfs@vger.kernel.org (open list:ECRYPT FILE SYSTEM),
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        linux-cifs@vger.kernel.org (open list:COMMON INTERNET FILE SYSTEM
	(CIFS)),
        linux-ext4@vger.kernel.org (open list:EXT4 FILE SYSTEM),
        linux-fsdevel@vger.kernel.org (open list:FILESYSTEMS (VFS and
	infrastructure)),
        linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND LOCKD CLIENTS),
        Peng Tao <tao.peng@primarydata.com>,
        Petr Vandrovec <petr@vandrovec.name>,
        samba-technical@lists.samba.org (moderated list:COMMON INTERNET FILE
	SYSTEM (CIFS)),
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Tom Haynes <loghyr@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH V1 Resend 07/10] fs: Drop unlikely before IS_ERR(_OR_NULL)
Date: Wed, 12 Aug 2015 15:59:44 +0530
Message-Id: <2efb962cb72884f625116cba24fc4fb203c6621f.1439375087.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
is no need to do that again from its callers. Drop it.

Reviewed-by: David Howells <dhowells@redhat.com>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 fs/cifs/readdir.c            | 2 +-
 fs/ecryptfs/inode.c          | 2 +-
 fs/ext4/extents.c            | 6 +++---
 fs/ext4/namei.c              | 2 +-
 fs/namei.c                   | 4 ++--
 fs/ncpfs/dir.c               | 2 +-
 fs/nfs/objlayout/objio_osd.c | 2 +-
 fs/proc/proc_sysctl.c        | 2 +-
 8 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/cifs/readdir.c b/fs/cifs/readdir.c
index b1eede3678a9..0557c45e9c33 100644
--- a/fs/cifs/readdir.c
+++ b/fs/cifs/readdir.c
@@ -84,7 +84,7 @@ cifs_prime_dcache(struct dentry *parent, struct qstr *name,
 	cifs_dbg(FYI, "%s: for %s\n", __func__, name->name);
 
 	dentry = d_hash_and_lookup(parent, name);
-	if (unlikely(IS_ERR(dentry)))
+	if (IS_ERR(dentry))
 		return;
 
 	if (dentry) {
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 3c4db1172d22..e2e47ba5d313 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -270,7 +270,7 @@ ecryptfs_create(struct inode *directory_inode, struct dentry *ecryptfs_dentry,
 
 	ecryptfs_inode = ecryptfs_do_create(directory_inode, ecryptfs_dentry,
 					    mode);
-	if (unlikely(IS_ERR(ecryptfs_inode))) {
+	if (IS_ERR(ecryptfs_inode)) {
 		ecryptfs_printk(KERN_WARNING, "Failed to create file in"
 				"lower filesystem\n");
 		rc = PTR_ERR(ecryptfs_inode);
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 2553aa8b608d..799f01714767 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -899,7 +899,7 @@ ext4_find_extent(struct inode *inode, ext4_lblk_t block,
 
 		bh = read_extent_tree_block(inode, path[ppos].p_block, --i,
 					    flags);
-		if (unlikely(IS_ERR(bh))) {
+		if (IS_ERR(bh)) {
 			ret = PTR_ERR(bh);
 			goto err;
 		}
@@ -5792,7 +5792,7 @@ ext4_swap_extents(handle_t *handle, struct inode *inode1,
 		int split = 0;
 
 		path1 = ext4_find_extent(inode1, lblk1, NULL, EXT4_EX_NOCACHE);
-		if (unlikely(IS_ERR(path1))) {
+		if (IS_ERR(path1)) {
 			*erp = PTR_ERR(path1);
 			path1 = NULL;
 		finish:
@@ -5800,7 +5800,7 @@ ext4_swap_extents(handle_t *handle, struct inode *inode1,
 			goto repeat;
 		}
 		path2 = ext4_find_extent(inode2, lblk2, NULL, EXT4_EX_NOCACHE);
-		if (unlikely(IS_ERR(path2))) {
+		if (IS_ERR(path2)) {
 			*erp = PTR_ERR(path2);
 			path2 = NULL;
 			goto finish;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 9f61e7679a6d..f12b277ad2af 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -1429,7 +1429,7 @@ static struct buffer_head * ext4_find_entry (struct inode *dir,
 				}
 				num++;
 				bh = ext4_getblk(NULL, dir, b++, 0);
-				if (unlikely(IS_ERR(bh))) {
+				if (IS_ERR(bh)) {
 					if (ra_max == 0) {
 						ret = bh;
 						goto cleanup_and_exit;
diff --git a/fs/namei.c b/fs/namei.c
index cacc51ddcf54..67d419e55547 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1942,7 +1942,7 @@ static int link_path_walk(const char *name, struct nameidata *nd)
 		if (err) {
 			const char *s = get_link(nd);
 
-			if (unlikely(IS_ERR(s)))
+			if (IS_ERR(s))
 				return PTR_ERR(s);
 			err = 0;
 			if (unlikely(!s)) {
@@ -3430,7 +3430,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 		return ERR_PTR(-ELOOP);
 
 	filename = getname_kernel(name);
-	if (unlikely(IS_ERR(filename)))
+	if (IS_ERR(filename))
 		return ERR_CAST(filename);
 
 	set_nameidata(&nd, -1, filename);
diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
index 93575e91a7aa..356816e7bc90 100644
--- a/fs/ncpfs/dir.c
+++ b/fs/ncpfs/dir.c
@@ -597,7 +597,7 @@ ncp_fill_cache(struct file *file, struct dir_context *ctx,
 	qname.name = __name;
 
 	newdent = d_hash_and_lookup(dentry, &qname);
-	if (unlikely(IS_ERR(newdent)))
+	if (IS_ERR(newdent))
 		goto end_advance;
 	if (!newdent) {
 		newdent = d_alloc(dentry, &qname);
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 5aaed363556a..5c0c6b58157f 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -124,7 +124,7 @@ objio_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 
 retry_lookup:
 	od = osduld_info_lookup(&odi);
-	if (unlikely(IS_ERR(od))) {
+	if (IS_ERR(od)) {
 		err = PTR_ERR(od);
 		dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
 		if (err == -ENODEV && retry_flag) {
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index fdda62e6115e..fe5b6e6c4671 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -948,7 +948,7 @@ static struct ctl_dir *get_subdir(struct ctl_dir *dir,
 found:
 	subdir->header.nreg++;
 failed:
-	if (unlikely(IS_ERR(subdir))) {
+	if (IS_ERR(subdir)) {
 		pr_err("sysctl could not get directory: ");
 		sysctl_print_dir(dir);
 		pr_cont("/%*.*s %ld\n",
-- 
2.4.0

