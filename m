Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755011Ab1G2NuJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 09:50:09 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6TDo9wO004883
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 09:50:09 -0400
Received: from [10.33.0.52] (sprabhu.fab.redhat.com [10.33.0.52])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6TDo8eA015400
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 09:50:08 -0400
Subject: [PATCH] nfs: Do not allow multiple mounts on same mountpoint when
 using -o noac
From: Sachin Prabhu <sprabhu@redhat.com>
To: NFS <linux-nfs@vger.kernel.org>
Date: Fri, 29 Jul 2011 14:50:08 +0100
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311947408.29400.40.camel@sprabhu.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When you normally attempt to mount a share twice on the same mountpoint,
a check in do_add_mount causes it to return an error

# mount localhost:/nfsv3 /mnt
# mount localhost:/nfsv3 /mnt
mount.nfs: /mnt is already mounted or busy

However when using the option 'noac', the user is able to mount the same
share on the same mountpoint multiple times. This happens because a
share mounted with the noac option is automatically assigned the 'sync'
flag MS_SYNCHRONOUS in nfs_initialise_sb(). This flag is set after the
check for already existing superblocks is done in sget(). The check for
the mount flags in nfs_compare_mount_options() does not take into
account the 'sync' flag applied later on in the code path. This means
that when using 'noac', a new superblock structure is assigned for every
new mount of the same share and multiple shares on the same mountpoint
are allowed.

ie. 
# mount -onoac localhost:/nfsv3 /mnt
can be run multiple times.

The patch checks for noac and assigns the sync flag before sget() is
called to obtain an already existing superblock structure.


Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b961cea..9b7dd70 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2035,9 +2035,6 @@ static inline void nfs_initialise_sb(struct
super_block *sb)
 		sb->s_blocksize = nfs_block_bits(server->wsize,
 						 &sb->s_blocksize_bits);
 
-	if (server->flags & NFS_MOUNT_NOAC)
-		sb->s_flags |= MS_SYNCHRONOUS;
-
 	sb->s_bdi = &server->backing_dev_info;
 
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
@@ -2249,6 +2246,10 @@ static struct dentry *nfs_fs_mount(struct
file_system_type *fs_type,
 	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already
exists */
 	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
@@ -2361,6 +2362,10 @@ nfs_xdev_mount(struct file_system_type *fs_type,
int flags,
 	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already
exists */
 	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
@@ -2628,6 +2633,10 @@ nfs4_remote_mount(struct file_system_type
*fs_type, int flags,
 	if (server->flags & NFS4_MOUNT_UNSHARED)
 		compare_super = NULL;
 
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already
exists */
 	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
@@ -2916,6 +2925,10 @@ nfs4_xdev_mount(struct file_system_type *fs_type,
int flags,
 	if (server->flags & NFS4_MOUNT_UNSHARED)
 		compare_super = NULL;
 
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already
exists */
 	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
@@ -3003,6 +3016,10 @@ nfs4_remote_referral_mount(struct
file_system_type *fs_type, int flags,
 	if (server->flags & NFS4_MOUNT_UNSHARED)
 		compare_super = NULL;
 
+	/* -o noac implies -o sync */
+	if (server->flags & NFS_MOUNT_NOAC)
+		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
+
 	/* Get a superblock - note that we may end up sharing one that already
exists */
 	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {


