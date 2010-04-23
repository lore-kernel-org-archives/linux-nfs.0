From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: A share can be mounted multiple times on the same mountpoint
 when using the option 'noac'
Date: Fri, 23 Apr 2010 13:25:15 -0400
Message-ID: <20100423132515.5c592904.akpm@linux-foundation.org>
References: <21099631.1471272040654142.JavaMail.sprabhu@sprabhu.fab.redhat.com>
	<12694330.1491272040714232.JavaMail.sprabhu@sprabhu.fab.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Sachin Prabhu <sprabhu@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12694330.1491272040714232.JavaMail.sprabhu@sprabhu.fab.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Fri, 23 Apr 2010 12:38:38 -0400 (EDT) Sachin Prabhu <sprabhu@redhat.com> wrote:

> When you normally attempt to mount a share twice on the same mountpoint, a check in do_add_mount causes it to return an error
> 
> # mount localhost:/nfsv3 /mnt
> # mount localhost:/nfsv3 /mnt
> mount.nfs: /mnt is already mounted or busy
> 
> However when using the option 'noac', the user is able to mount the same share on the same mountpoint multiple times. This happens because a share mounted with the noac option is automatically assigned the 'sync' flag MS_SYNCHRONOUS in nfs_initialise_sb(). This flag is set after the check for already existing superblocks is done in sget(). The check for the mount flags in nfs_compare_mount_options() does not take into account the 'sync' flag applied later on in the code path. This means that when using 'noac', a new superblock structure is assigned for every new mount of the same share and multiple shares on the same mountpoint are allowed.
> 
> ie. 
> # mount -onoac localhost:/nfsv3 /mnt
> can be run multiple times.
> 
> Could the existing behavior be considered to be a bug? If yes, one possible fix for this issue is to move the 'sync' flag assignment before the sget() is called to obtain an already existing superblock structure.
> 
> Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> 
> diff -up linux-2.6/fs/nfs/super.c.noac_multiple_mount linux-2.6/fs/nfs/super.c
> --- linux-2.6/fs/nfs/super.c.noac_multiple_mount	2010-04-22 17:08:25.000000000 +0100
> +++ linux-2.6/fs/nfs/super.c	2010-04-22 17:27:48.000000000 +0100
> @@ -1992,9 +1992,6 @@ static inline void nfs_initialise_sb(str
>  		sb->s_blocksize = nfs_block_bits(server->wsize,
>  						 &sb->s_blocksize_bits);
>  
> -	if (server->flags & NFS_MOUNT_NOAC)
> -		sb->s_flags |= MS_SYNCHRONOUS;
> -
>  	sb->s_bdi = &server->backing_dev_info;
>  
>  	nfs_super_set_maxbytes(sb, server->maxfilesize);
> @@ -2202,6 +2199,9 @@ static int nfs_get_sb(struct file_system
>  	if (server->flags & NFS_MOUNT_UNSHARED)
>  		compare_super = NULL;
>  
> +	if (server->flags & NFS_MOUNT_NOAC)
> +		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
>  	if (IS_ERR(s)) {
> @@ -2317,6 +2317,9 @@ static int nfs_xdev_get_sb(struct file_s
>  	if (server->flags & NFS_MOUNT_UNSHARED)
>  		compare_super = NULL;
>  
> +	if (server->flags & NFS_MOUNT_NOAC)
> +		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
>  	if (IS_ERR(s)) {
> @@ -2572,6 +2575,9 @@ static int nfs4_remote_get_sb(struct fil
>  	if (server->flags & NFS4_MOUNT_UNSHARED)
>  		compare_super = NULL;
>  
> +	if (server->flags & NFS_MOUNT_NOAC)
> +		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
>  	if (IS_ERR(s)) {
> @@ -2808,6 +2814,9 @@ static int nfs4_xdev_get_sb(struct file_
>  	if (server->flags & NFS4_MOUNT_UNSHARED)
>  		compare_super = NULL;
>  
> +	if (server->flags & NFS_MOUNT_NOAC)
> +		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
>  	if (IS_ERR(s)) {
> @@ -2893,6 +2902,9 @@ static int nfs4_remote_referral_get_sb(s
>  	if (server->flags & NFS4_MOUNT_UNSHARED)
>  		compare_super = NULL;
>  
> +	if (server->flags & NFS_MOUNT_NOAC)
> +		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
>  	if (IS_ERR(s)) {
> --
