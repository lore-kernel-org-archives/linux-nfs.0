Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751078AbdFAOzR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 10:55:17 -0400
Date: Thu, 1 Jun 2017 10:55:08 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
Cc: Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@parisplace.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] security/selinux: allow security_sb_clone_mnt_opts to
 enable/disable native labeling behavior
Message-ID: <20170601145508.crubttulnnfm2hd5@tonberry.usersys.redhat.com>
References: <1495813358.4586.1.camel@tycho.nsa.gov>
 <20170601144628.26535-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170601144628.26535-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 01 Jun 2017, Scott Mayhew wrote:

> When an NFSv4 client performs a mount operation, it first mounts the
> NFSv4 root and then does path walk to the exported path and performs a
> submount on that, cloning the security mount options from the root's
> superblock to the submount's superblock in the process.
> 
> Unless the NFS server has an explicit fsid=0 export with the
> "security_label" option, the NFSv4 root superblock will not have
> SBLABEL_MNT set, and neither will the submount superblock after cloning
> the security mount options.  As a result, setxattr's of security labels
> over NFSv4.2 will fail.  In a similar fashion, NFSv4.2 mounts mounted
> with the context= mount option will not show the correct labels because
> the nfs_server->caps flags of the cloned superblock will still have
> NFS_CAP_SECURITY_LABEL set.
> 
> Allowing the NFSv4 client to enable or disable SECURITY_LSM_NATIVE_LABELS
> behavior will ensure that the SBLABEL_MNT flag has the correct value
> when the client traverses from an exported path without the
> "security_label" option to one with the "security_label" option and
> vice versa.  Similarly, checking to see if SECURITY_LSM_NATIVE_LABELS is
> set upon return from security_sb_clone_mnt_opts() and clearing
> NFS_CAP_SECURITY_LABEL if necessary will allow the correct labels to
> be displayed for NFSv4.2 mounts mounted with the context= mount option.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/super.c            | 18 +++++++++++++++++-
>  include/linux/lsm_hooks.h |  4 +++-
>  include/linux/security.h  |  8 ++++++--
>  security/security.c       |  7 +++++--
>  security/selinux/hooks.c  | 43 ++++++++++++++++++++++++++++++++++++++-----
>  5 files changed, 69 insertions(+), 11 deletions(-)

With this patch, the behavior and flags fields of the superblock_security_struct
and the nfs_server->caps all have the correct values when crossing from an
export without the "security_label" option to one with the "security_label"
option and vice versa.

Here /export/export1 and /export/export1/export2/export3 have the
"security_label" option; /export and /export/export1/export2 do not:

[root@rhel7u4 ~]# exportfs -v
/export       	<world>(rw,sync,wdelay,hide,no_subtree_check,sec=sys,secure,no_root_squash,no_all_squash)
/export/export1
		<world>(rw,sync,wdelay,hide,no_subtree_check,security_label,sec=sys,secure,no_root_squash,no_all_squash)
/export/export1/export2
		<world>(rw,sync,wdelay,hide,no_subtree_check,sec=sys,secure,no_root_squash,no_all_squash)
/export/export1/export2/export3
		<world>(rw,sync,wdelay,hide,no_subtree_check,security_label,sec=sys,secure,no_root_squash,no_all_squash)


[root@fedora25 ~]# mount -o v4.2 rhel7u4:/export /mnt/t
[root@fedora25 ~]# ls -lZ /mnt/t
total 8
drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0 4096 May 30 14:09 export1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file3
drwxrwxrwx. 3 root root system_u:object_r:nfs_t:s0   22 Apr 21 12:58 scratch
drwxrwxrwx. 7 root root system_u:object_r:nfs_t:s0 4096 Apr 21 12:55 test
[root@fedora25 ~]# ls -lZ /mnt/t/export1
total 20
drwxr-xr-x. 4 root root system_u:object_r:unlabeled_t:s0  4096 May 30 14:09 export2
-rw-r--r--. 1 root root system_u:object_r:etc_t:s0           0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:bin_t:s0           0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0           0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:unlabeled_t:s0 16384 May 30 14:02 lost+found
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2
total 20
drwxr-xr-x. 3 root root system_u:object_r:nfs_t:s0  4096 May 30 14:08 export3
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:nfs_t:s0 16384 May 30 14:02 lost+found
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2/export3
total 16
-rw-r--r--. 1 root root system_u:object_r:etc_t:s0           0 May 30 14:08 file1
-rw-r--r--. 1 root root system_u:object_r:bin_t:s0           0 May 30 14:08 file2
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0           0 May 30 14:08 file3
drwx------. 2 root root system_u:object_r:unlabeled_t:s0 16384 May 30 14:02 lost+found

I can do chcon on /mnt/t/export1 and /mnt/t/export1/export2/export3
but not /mnt/t or /mnt/t/export1/export2:

[root@fedora25 ~]# chcon -t usr_t /mnt/t/file1
chcon: failed to change context of '/mnt/t/file1' to ‘system_u:object_r:usr_t:s0’: Operation not supported
[root@fedora25 ~]# chcon -t usr_t /mnt/t/export1/file1
[root@fedora25 ~]# chcon -t usr_t /mnt/t/export1/export2/file1
chcon: failed to change context of '/mnt/t/export1/export2/file1' to ‘system_u:object_r:usr_t:s0’: Operation not supported
[root@fedora25 ~]# chcon -t usr_t /mnt/t/export1/export2/export3/file1
[root@fedora25 ~]# ls -lZ /mnt/t/file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0 0 May 30 14:09 /mnt/t/file1
[root@fedora25 ~]# ls -lZ /mnt/t/export1/file1
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0 0 May 30 14:09 /mnt/t/export1/file1
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2/file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0 0 May 30 14:09 /mnt/t/export1/export2/file1
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2/export3/file1
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0 0 May 30 14:08 /mnt/t/export1/export2/export3/file1
[root@fedora25 ~]# chcon -t etc_t /mnt/t/export1/file1
[root@fedora25 ~]# chcon -t etc_t /mnt/t/export1/export2/export3/file1

/mnt/t/export1 and /mnt/t/export1/export2/export3 have the "seclabel"
mount option; /mnt/t and /mnt/t/export1/export do not:

[root@fedora25 ~]# cat /proc/mounts
...
rhel7u4:/export /mnt/t nfs4 rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1 /mnt/t/export1 nfs4 rw,seclabel,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1/export2 /mnt/t/export1/export2 nfs4 rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1/export2/export3 /mnt/t/export1/export2/export3 nfs4 rw,seclabel,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0

The capabilities flags has NFS_CAP_SECURITY_LABEL set on /mnt/t/export1 and
/mnt/t/export1/export2/export3; it is not set on /mnt/t and /mnt/t/export1/export2:

[root@fedora25 ~]# egrep "rhel7u4|caps" /proc/self/mountstats
device rhel7u4:/export mounted on /mnt/t with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1 mounted on /mnt/t/export1 with fstype nfs4 statvers=1.1
	caps:	caps=0x1ffffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1/export2 mounted on /mnt/t/export1/export2 with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1/export2/export3 mounted on /mnt/t/export1/export2/export3 with fstype nfs4 statvers=1.1
	caps:	caps=0x1ffffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
[root@fedora25 ~]# printf "%x\n" $(( 0x1fbffdf & (1<<18) ))
0
[root@fedora25 ~]# printf "%x\n" $(( 0x1ffffdf & (1<<18) ))
40000
[root@fedora25 ~]# 

The context= mount option now works correctly:

[root@fedora25 ~]# mount -o v4.2,context="system_u:object_r:user_home_t:s0" rhel7u4:/export /mnt/t
[root@fedora25 ~]# ls -lZ /mnt/t
total 8
drwxr-xr-x. 4 root root system_u:object_r:user_home_t:s0 4096 May 30 14:09 export1
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0    0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0    0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0    0 May 30 14:09 file3
drwxrwxrwx. 3 root root system_u:object_r:user_home_t:s0   22 Apr 21 12:58 scratch
drwxrwxrwx. 7 root root system_u:object_r:user_home_t:s0 4096 Apr 21 12:55 test
[root@fedora25 ~]# ls -lZ /mnt/t/export1
total 20
drwxr-xr-x. 4 root root system_u:object_r:user_home_t:s0  4096 May 30 14:09 export2
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:user_home_t:s0 16384 May 30 14:02 lost+found
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2
total 20
drwxr-xr-x. 3 root root system_u:object_r:user_home_t:s0  4096 May 30 14:08 export3
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:user_home_t:s0 16384 May 30 14:02 lost+found
[root@fedora25 ~]# ls -lZ /mnt/t/export1/export2/export3
total 16
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:08 file1
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:08 file2
-rw-r--r--. 1 root root system_u:object_r:user_home_t:s0     0 May 30 14:08 file3
drwx------. 2 root root system_u:object_r:user_home_t:s0 16384 May 30 14:02 lost+found

[root@fedora25 ~]# cat /proc/mounts
...
rhel7u4:/export /mnt/t nfs4 rw,context=system_u:object_r:user_home_t:s0,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1 /mnt/t/export1 nfs4 rw,context=system_u:object_r:user_home_t:s0,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1/export2 /mnt/t/export1/export2 nfs4 rw,context=system_u:object_r:user_home_t:s0,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0
rhel7u4:/export/export1/export2/export3 /mnt/t/export1/export2/export3 nfs4 rw,context=system_u:object_r:user_home_t:s0,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.236,local_lock=none,addr=192.168.122.83 0 0

[root@fedora25 ~]# egrep "rhel7u4|caps" /proc/self/mountstats
device rhel7u4:/export mounted on /mnt/t with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1 mounted on /mnt/t/export1 with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1/export2 mounted on /mnt/t/export1/export2 with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
device rhel7u4:/export/export1/export2/export3 mounted on /mnt/t/export1/export2/export3 with fstype nfs4 statvers=1.1
	caps:	caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255

-Scott

> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 2f3822a..6a11535 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2544,10 +2544,26 @@ EXPORT_SYMBOL_GPL(nfs_set_sb_security);
>  int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
>  			  struct nfs_mount_info *mount_info)
>  {
> +	int error;
> +	unsigned long kflags = 0, kflags_out = 0;
> +
>  	/* clone any lsm security options from the parent to the new sb */
>  	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
>  		return -ESTALE;
> -	return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
> +
> +	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
> +		kflags |= SECURITY_LSM_NATIVE_LABELS;
> +
> +	error = security_sb_clone_mnt_opts(mount_info->cloned->sb, s, kflags, &kflags_out);
> +	if (error)
> +		goto err;
> +
> +	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
> +		!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
> +		NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
> +err:
> +	return error;
> +
>  }
>  EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
>  
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index 080f34e..2f54bfb 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -1388,7 +1388,9 @@ union security_list_options {
>  				unsigned long kern_flags,
>  				unsigned long *set_kern_flags);
>  	int (*sb_clone_mnt_opts)(const struct super_block *oldsb,
> -					struct super_block *newsb);
> +					struct super_block *newsb,
> +					unsigned long kern_flags,
> +					unsigned long *set_kern_flags);
>  	int (*sb_parse_opts_str)(char *options, struct security_mnt_opts *opts);
>  	int (*dentry_init_security)(struct dentry *dentry, int mode,
>  					const struct qstr *name, void **ctx,
> diff --git a/include/linux/security.h b/include/linux/security.h
> index af675b5..a55ae9c 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -240,7 +240,9 @@ int security_sb_set_mnt_opts(struct super_block *sb,
>  				unsigned long kern_flags,
>  				unsigned long *set_kern_flags);
>  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> -				struct super_block *newsb);
> +				struct super_block *newsb,
> +				unsigned long kern_flags,
> +				unsigned long *set_kern_flags);
>  int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
>  int security_dentry_init_security(struct dentry *dentry, int mode,
>  					const struct qstr *name, void **ctx,
> @@ -581,7 +583,9 @@ static inline int security_sb_set_mnt_opts(struct super_block *sb,
>  }
>  
>  static inline int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> -					      struct super_block *newsb)
> +					      struct super_block *newsb,
> +					      unsigned long kern_flags,
> +					      unsigned long *set_kern_flags)
>  {
>  	return 0;
>  }
> diff --git a/security/security.c b/security/security.c
> index b9fea39..7b70ea2 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -380,9 +380,12 @@ int security_sb_set_mnt_opts(struct super_block *sb,
>  EXPORT_SYMBOL(security_sb_set_mnt_opts);
>  
>  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> -				struct super_block *newsb)
> +				struct super_block *newsb,
> +				unsigned long kern_flags,
> +				unsigned long *set_kern_flags)
>  {
> -	return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb);
> +	return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb,
> +				kern_flags, set_kern_flags);
>  }
>  EXPORT_SYMBOL(security_sb_clone_mnt_opts);
>  
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index e67a526..80d9acf 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -529,8 +529,14 @@ static int sb_finish_set_opts(struct super_block *sb)
>  		       sb->s_id, sb->s_type->name);
>  
>  	sbsec->flags |= SE_SBINITIALIZED;
> +
> +	/* Explicitly set or clear SBLABEL_MNT.  It's not sufficient to simply
> +	   leave the flag untouched because sb_clone_mnt_opts might be handing
> +	   us a superblock that needs the flag to be cleared. */
>  	if (selinux_is_sblabel_mnt(sb))
>  		sbsec->flags |= SBLABEL_MNT;
> +	else
> +		sbsec->flags &= ~SBLABEL_MNT;
>  
>  	/* Initialize the root inode. */
>  	rc = inode_doinit_with_dentry(root_inode, root);
> @@ -963,8 +969,11 @@ static int selinux_cmp_sb_context(const struct super_block *oldsb,
>  }
>  
>  static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> -					struct super_block *newsb)
> +					struct super_block *newsb,
> +					unsigned long kern_flags,
> +					unsigned long *set_kern_flags)
>  {
> +	int rc = 0;
>  	const struct superblock_security_struct *oldsbsec = oldsb->s_security;
>  	struct superblock_security_struct *newsbsec = newsb->s_security;
>  
> @@ -977,14 +986,23 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	 * mount options.  thus we can safely deal with this superblock later
>  	 */
>  	if (!ss_initialized)
> -		return 0;
> +		goto out;
> +
> +	if (kern_flags && !set_kern_flags) {
> +		/* Specifying internal flags without providing a place to
> +		 * place the results is not allowed */
> +		rc = -EINVAL;
> +		goto out;
> +	}
>  
>  	/* how can we clone if the old one wasn't set up?? */
>  	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
>  
>  	/* if fs is reusing a sb, make sure that the contexts match */
> -	if (newsbsec->flags & SE_SBINITIALIZED)
> -		return selinux_cmp_sb_context(oldsb, newsb);
> +	if (newsbsec->flags & SE_SBINITIALIZED) {
> +		rc = selinux_cmp_sb_context(oldsb, newsb);
> +		goto out;
> +	}
>  
>  	mutex_lock(&newsbsec->lock);
>  
> @@ -994,6 +1012,19 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	newsbsec->def_sid = oldsbsec->def_sid;
>  	newsbsec->behavior = oldsbsec->behavior;
>  
> +	if (newsbsec->behavior == SECURITY_FS_USE_NATIVE
> +			&& !(kern_flags & SECURITY_LSM_NATIVE_LABELS)
> +			&& !set_context) {
> +		rc = security_fs_use(newsb);
> +		if (rc)
> +			goto out_unlock;
> +	}
> +
> +	if (kern_flags & SECURITY_LSM_NATIVE_LABELS && !set_context) {
> +		newsbsec->behavior = SECURITY_FS_USE_NATIVE;
> +		*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
> +	}
> +
>  	if (set_context) {
>  		u32 sid = oldsbsec->mntpoint_sid;
>  
> @@ -1013,8 +1044,10 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	}
>  
>  	sb_finish_set_opts(newsb);
> +out_unlock:
>  	mutex_unlock(&newsbsec->lock);
> -	return 0;
> +out:
> +	return rc;
>  }
>  
>  static int selinux_parse_opts_str(char *options,
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
