Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:55813 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755587Ab2DSQD4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 12:03:56 -0400
MIME-Version: 1.0
In-Reply-To: <20120419140625.17272.23303.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419140625.17272.23303.stgit@warthog.procyon.org.uk>
Date: Thu, 19 Apr 2012 11:03:54 -0500
Message-ID: <CAH2r5mtHj6LnOcRDv37_S-tZmc42sTLwE8Z02+27XZbjEVzZfg@mail.gmail.com>
Subject: Re: [PATCH 2/6] xstat: Ext4: Return extended attributes
From: Steve French <smfrench@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch reminds me of a question on time stamps - how can an
application query the time granularity ie sb_s_time_gran for a mount
(e.g. 1 second for some file systems, 100 nanoseconds for cifs/smb2, 1
nanosecond for others etc.)

On Thu, Apr 19, 2012 at 9:06 AM, David Howells <dhowells@redhat.com> wrote:
> Return extended attributes from the Ext4 filesystem.  This includes the
> following:
>
>  (1) The inode creation time (i_crtime) as i_btime.
>
>  (2) The inode i_generation as i_gen if not the root directory.
>
>  (3) The inode i_version as st_data_version if a file with I_VERSION set or a
>     directory.
>
>  (4) FS_xxx_FL flags are returned as for ioctl(FS_IOC_GETFLAGS).
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  fs/ext4/ext4.h    |    2 ++
>  fs/ext4/file.c    |    2 +-
>  fs/ext4/inode.c   |   32 +++++++++++++++++++++++++++++---
>  fs/ext4/namei.c   |    2 ++
>  fs/ext4/super.c   |    1 +
>  fs/ext4/symlink.c |    2 ++
>  6 files changed, 37 insertions(+), 4 deletions(-)
>
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index ab2594a..81806da 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -1899,6 +1899,8 @@ extern int  ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
>                                struct kstat *stat);
>  extern void ext4_evict_inode(struct inode *);
>  extern void ext4_clear_inode(struct inode *);
> +extern int  ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
> +                             struct kstat *stat);
>  extern int  ext4_sync_inode(handle_t *, struct inode *);
>  extern void ext4_dirty_inode(struct inode *, int);
>  extern int ext4_change_inode_journal_flag(struct inode *, int);
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index cb70f18..ae8654c 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -249,7 +249,7 @@ const struct file_operations ext4_file_operations = {
>
>  const struct inode_operations ext4_file_inode_operations = {
>        .setattr        = ext4_setattr,
> -       .getattr        = ext4_getattr,
> +       .getattr        = ext4_file_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
>        .setxattr       = generic_setxattr,
>        .getxattr       = generic_getxattr,
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index c77b0bd..eafc188 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4191,11 +4191,37 @@ err_out:
>  int ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
>                 struct kstat *stat)
>  {
> -       struct inode *inode;
> -       unsigned long delalloc_blocks;
> +       struct inode *inode = dentry->d_inode;
> +       struct ext4_inode_info *ei = EXT4_I(inode);
> +
> +       stat->result_mask |= XSTAT_BTIME;
> +       stat->btime.tv_sec = ei->i_crtime.tv_sec;
> +       stat->btime.tv_nsec = ei->i_crtime.tv_nsec;
> +
> +       if (inode->i_ino != EXT4_ROOT_INO) {
> +               stat->result_mask |= XSTAT_GEN;
> +               stat->gen = inode->i_generation;
> +       }
> +       if (S_ISDIR(inode->i_mode) || IS_I_VERSION(inode)) {
> +               stat->result_mask |= XSTAT_VERSION;
> +               stat->version = inode->i_version;
> +       }
> +
> +       ext4_get_inode_flags(ei);
> +       stat->ioc_flags |= ei->i_flags & EXT4_FL_USER_VISIBLE;
> +       stat->result_mask |= XSTAT_IOC_FLAGS;
>
> -       inode = dentry->d_inode;
>        generic_fillattr(inode, stat);
> +       return 0;
> +}
> +
> +int ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
> +                     struct kstat *stat)
> +{
> +       struct inode *inode = dentry->d_inode;
> +       u64 delalloc_blocks;
> +
> +       ext4_getattr(mnt, dentry, stat);
>
>        /*
>         * We can't update i_blocks if the block allocation is delayed
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index 349d7b3..6162387 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -2579,6 +2579,7 @@ const struct inode_operations ext4_dir_inode_operations = {
>        .mknod          = ext4_mknod,
>        .rename         = ext4_rename,
>        .setattr        = ext4_setattr,
> +       .getattr        = ext4_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
>        .setxattr       = generic_setxattr,
>        .getxattr       = generic_getxattr,
> @@ -2591,6 +2592,7 @@ const struct inode_operations ext4_dir_inode_operations = {
>
>  const struct inode_operations ext4_special_inode_operations = {
>        .setattr        = ext4_setattr,
> +       .getattr        = ext4_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
>        .setxattr       = generic_setxattr,
>        .getxattr       = generic_getxattr,
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index ceebaf8..2d395bf 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -3040,6 +3040,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>        if (sb->s_magic != EXT4_SUPER_MAGIC)
>                goto cantfind_ext4;
>        sbi->s_kbytes_written = le64_to_cpu(es->s_kbytes_written);
> +       memcpy(sb->s_volume_id, es->s_uuid, sizeof(sb->s_volume_id));
>
>        /* Set defaults before we parse the mount options */
>        def_mount_opts = le32_to_cpu(es->s_default_mount_opts);
> diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
> index ed9354a..d8fe7fb 100644
> --- a/fs/ext4/symlink.c
> +++ b/fs/ext4/symlink.c
> @@ -35,6 +35,7 @@ const struct inode_operations ext4_symlink_inode_operations = {
>        .follow_link    = page_follow_link_light,
>        .put_link       = page_put_link,
>        .setattr        = ext4_setattr,
> +       .getattr        = ext4_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
>        .setxattr       = generic_setxattr,
>        .getxattr       = generic_getxattr,
> @@ -47,6 +48,7 @@ const struct inode_operations ext4_fast_symlink_inode_operations = {
>        .readlink       = generic_readlink,
>        .follow_link    = ext4_follow_link,
>        .setattr        = ext4_setattr,
> +       .getattr        = ext4_getattr,
>  #ifdef CONFIG_EXT4_FS_XATTR
>        .setxattr       = generic_setxattr,
>        .getxattr       = generic_getxattr,
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,

Steve
