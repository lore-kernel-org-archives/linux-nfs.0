From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 1/2] LSM/SELinux: Interfaces to allow FS to control mount options
Date: Wed, 5 Mar 2008 09:27:41 -0800 (PST)
Message-ID: <700613.94697.qm@web36615.mail.mud.yahoo.com>
References: <1204731114.3216.237.camel@localhost.localdomain>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, jlayton@redhat.com, sds@tycho.nsa.gov,
	jmorris@namei.org, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com,
	hch@infradead.org, akpm@linux-foundation.org
To: Eric Paris <eparis@redhat.com>, linux-nfs@vger.kernel.org,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web36615.mail.mud.yahoo.com ([209.191.85.32]:47887 "HELO
	web36615.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757296AbYCER1r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2008 12:27:47 -0500
In-Reply-To: <1204731114.3216.237.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--- Eric Paris <eparis@redhat.com> wrote:

> Introduce new LSM interfaces to allow an FS to deal with their own mount
> options.  This includes a new string parsing function exported from the
> LSM that an FS can use to get a security data blob and a new security
> data blob.  This is particularly useful for an FS which uses binary
> mount data, like NFS, which does not pass strings into the vfs to be
> handled by the loaded LSM.  Also fix a BUG() in both SELinux and SMACK
> when dealing with binary mount data.  If the binary mount data is less
> than one page the copy_page() in security_sb_copy_data() can cause an
> illegal page fault and boom.  Remove all NFSisms from the SELinux code
> since they were broken by past NFS changes.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>

Acked-by: Casey Schaufler <casey@schaufler-ca.com>

> ---
> 
> As this fixes a rather easily triggered BUG() this needs to go into .25
> as soon as possible.  It also lays the foundation to fix the NFS
> functionality regression in the next patch.
> 
>  fs/super.c                          |    4 
>  include/linux/security.h            |   99 +++++++++++++++-----
>  security/dummy.c                    |   23 ++--
>  security/security.c                 |   23 +++-
>  security/selinux/hooks.c            |  175
> +++++++++++++++++++-----------------
>  security/selinux/include/security.h |    5 +
>  security/smack/smack_lsm.c          |    9 -
>  7 files changed, 204 insertions(+), 134 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 88811f6..010446d 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -870,12 +870,12 @@ vfs_kern_mount(struct file_system_type *type, int
> flags, const char *name, void
>  	if (!mnt)
>  		goto out;
>  
> -	if (data) {
> +	if (data && !(type->fs_flags & FS_BINARY_MOUNTDATA)) {
>  		secdata = alloc_secdata();
>  		if (!secdata)
>  			goto out_mnt;
>  
> -		error = security_sb_copy_data(type, data, secdata);
> +		error = security_sb_copy_data(data, secdata);
>  		if (error)
>  			goto out_free_secdata;
>  	}
> diff --git a/include/linux/security.h b/include/linux/security.h
> index fe52cde..4ca8630 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -34,12 +34,6 @@
>  #include <linux/xfrm.h>
>  #include <net/flow.h>
>  
> -/* only a char in selinux superblock security struct flags */
> -#define FSCONTEXT_MNT		0x01
> -#define CONTEXT_MNT		0x02
> -#define ROOTCONTEXT_MNT		0x04
> -#define DEFCONTEXT_MNT		0x08
> -
>  extern unsigned securebits;
>  
>  struct ctl_table;
> @@ -114,6 +108,32 @@ struct request_sock;
>  
>  #ifdef CONFIG_SECURITY
>  
> +struct security_mnt_opts {
> +	char **mnt_opts;
> +	int *mnt_opts_flags;
> +	int num_mnt_opts;
> +};
> +
> +static inline void security_init_mnt_opts(struct security_mnt_opts *opts)
> +{
> +	opts->mnt_opts = NULL;
> +	opts->mnt_opts_flags = NULL;
> +	opts->num_mnt_opts = 0;
> +}
> +
> +static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
> +{
> +	int i;
> +	if (opts->mnt_opts)
> +		for(i = 0; i < opts->num_mnt_opts; i++)
> +			kfree(opts->mnt_opts[i]);
> +	kfree(opts->mnt_opts);
> +	opts->mnt_opts = NULL;
> +	kfree(opts->mnt_opts_flags);
> +	opts->mnt_opts_flags = NULL;
> +	opts->num_mnt_opts = 0;
> +}
> +
>  /**
>   * struct security_operations - main security structure
>   *
> @@ -262,19 +282,19 @@ struct request_sock;
>   * @sb_get_mnt_opts:
>   *	Get the security relevant mount options used for a superblock
>   *	@sb the superblock to get security mount options from
> - *	@mount_options array for pointers to mount options
> - *	@mount_flags array of ints specifying what each mount options is
> - *	@num_opts number of options in the arrays
> + *	@opts binary data structure containing all lsm mount data
>   * @sb_set_mnt_opts:
>   *	Set the security relevant mount options used for a superblock
>   *	@sb the superblock to set security mount options for
> - *	@mount_options array for pointers to mount options
> - *	@mount_flags array of ints specifying what each mount options is
> - *	@num_opts number of options in the arrays
> + *	@opts binary data structure containing all lsm mount data
>   * @sb_clone_mnt_opts:
>   *	Copy all security options from a given superblock to another
>   *	@oldsb old superblock which contain information to clone
>   *	@newsb new superblock which needs filled in
> + * @sb_parse_opts_str:
> + *	Parse a string of security data filling in the opts structure
> + *	@options string containing all mount options known by the LSM
> + *	@opts binary data structure usable by the LSM
>   *
>   * Security hooks for inode operations.
>   *
> @@ -1238,8 +1258,7 @@ struct security_operations {
>  
>  	int (*sb_alloc_security) (struct super_block * sb);
>  	void (*sb_free_security) (struct super_block * sb);
> -	int (*sb_copy_data)(struct file_system_type *type,
> -			    void *orig, void *copy);
> +	int (*sb_copy_data)(char *orig, char *copy);
>  	int (*sb_kern_mount) (struct super_block *sb, void *data);
>  	int (*sb_statfs) (struct dentry *dentry);
>  	int (*sb_mount) (char *dev_name, struct nameidata * nd,
> @@ -1257,12 +1276,12 @@ struct security_operations {
>  	void (*sb_post_pivotroot) (struct nameidata * old_nd,
>  				   struct nameidata * new_nd);
>  	int (*sb_get_mnt_opts) (const struct super_block *sb,
> -				char ***mount_options, int **flags,
> -				int *num_opts);
> -	int (*sb_set_mnt_opts) (struct super_block *sb, char **mount_options,
> -				int *flags, int num_opts);
> +				struct security_mnt_opts *opts);
> +	int (*sb_set_mnt_opts) (struct super_block *sb,
> +				struct security_mnt_opts *opts);
>  	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
>  				   struct super_block *newsb);
> +	int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
>  
>  	int (*inode_alloc_security) (struct inode *inode);	
>  	void (*inode_free_security) (struct inode *inode);
> @@ -1507,7 +1526,7 @@ int security_bprm_check(struct linux_binprm *bprm);
>  int security_bprm_secureexec(struct linux_binprm *bprm);
>  int security_sb_alloc(struct super_block *sb);
>  void security_sb_free(struct super_block *sb);
> -int security_sb_copy_data(struct file_system_type *type, void *orig, void
> *copy);
> +int security_sb_copy_data(char *orig, char *copy);
>  int security_sb_kern_mount(struct super_block *sb, void *data);
>  int security_sb_statfs(struct dentry *dentry);
>  int security_sb_mount(char *dev_name, struct nameidata *nd,
> @@ -1520,12 +1539,12 @@ void security_sb_post_remount(struct vfsmount *mnt,
> unsigned long flags, void *d
>  void security_sb_post_addmount(struct vfsmount *mnt, struct nameidata
> *mountpoint_nd);
>  int security_sb_pivotroot(struct nameidata *old_nd, struct nameidata
> *new_nd);
>  void security_sb_post_pivotroot(struct nameidata *old_nd, struct nameidata
> *new_nd);
> -int security_sb_get_mnt_opts(const struct super_block *sb, char
> ***mount_options,
> -			     int **flags, int *num_opts);
> -int security_sb_set_mnt_opts(struct super_block *sb, char **mount_options,
> -			     int *flags, int num_opts);
> +int security_sb_get_mnt_opts(const struct super_block *sb,
> +				struct security_mnt_opts *opts);
> +int security_sb_set_mnt_opts(struct super_block *sb, struct
> security_mnt_opts *opts);
>  void security_sb_clone_mnt_opts(const struct super_block *oldsb,
>  				struct super_block *newsb);
> +int security_sb_parse_opts_str(char *options, struct security_mnt_opts
> *opts);
>  
>  int security_inode_alloc(struct inode *inode);
>  void security_inode_free(struct inode *inode);
> @@ -1635,6 +1654,16 @@ int security_secctx_to_secid(char *secdata, u32
> seclen, u32 *secid);
>  void security_release_secctx(char *secdata, u32 seclen);
>  
>  #else /* CONFIG_SECURITY */
> +struct security_mnt_opts {
> +};
> +
> +static inline void security_init_mnt_opts(struct security_mnt_opts *opts)
> +{
> +}
> +
> +static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
> +{
> +}
>  
>  /*
>   * This is the default capabilities functionality.  Most of these functions
> @@ -1762,8 +1791,7 @@ static inline int security_sb_alloc (struct super_block
> *sb)
>  static inline void security_sb_free (struct super_block *sb)
>  { }
>  
> -static inline int security_sb_copy_data (struct file_system_type *type,
> -					 void *orig, void *copy)
> +static inline int security_sb_copy_data (char *orig, char *copy)
>  {
>  	return 0;
>  }
> @@ -1819,6 +1847,27 @@ static inline int security_sb_pivotroot (struct
> nameidata *old_nd,
>  static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
>  					       struct nameidata *new_nd)
>  { }
> +static inline int security_sb_get_mnt_opts(const struct super_block *sb,
> +					   struct security_mnt_opts *opts)
> +{
> +	security_init_mnt_opts(opts);
> +	return 0;
> +}
> +
> +static inline int security_sb_set_mnt_opts(struct super_block *sb,
> +					   struct security_mnt_opts *opts)
> +{
> +	return 0;
> +}
> +
> +static inline void security_sb_clone_mnt_opts(const struct super_block
> *oldsb,
> +					      struct super_block *newsb)
> +{ }
> +
> +static inline int security_sb_parse_opts_str(char *options, struct
> security_mnt_opts *opts)
> +{ 
> +	return 0;
> +}
>  
>  static inline int security_inode_alloc (struct inode *inode)
>  {
> diff --git a/security/dummy.c b/security/dummy.c
> index 649326b..78d8f92 100644
> --- a/security/dummy.c
> +++ b/security/dummy.c
> @@ -181,8 +181,7 @@ static void dummy_sb_free_security (struct super_block
> *sb)
>  	return;
>  }
>  
> -static int dummy_sb_copy_data (struct file_system_type *type,
> -			       void *orig, void *copy)
> +static int dummy_sb_copy_data (char *orig, char *copy)
>  {
>  	return 0;
>  }
> @@ -245,19 +244,17 @@ static void dummy_sb_post_pivotroot (struct nameidata
> *old_nd, struct nameidata
>  	return;
>  }
>  
> -static int dummy_sb_get_mnt_opts(const struct super_block *sb, char
> ***mount_options,
> -				 int **flags, int *num_opts)
> +static int dummy_sb_get_mnt_opts(const struct super_block *sb,
> +				 struct security_mnt_opts *opts)
>  {
> -	*mount_options = NULL;
> -	*flags = NULL;
> -	*num_opts = 0;
> +	security_init_mnt_opts(opts);
>  	return 0;
>  }
>  
> -static int dummy_sb_set_mnt_opts(struct super_block *sb, char
> **mount_options,
> -				 int *flags, int num_opts)
> +static int dummy_sb_set_mnt_opts(struct super_block *sb,
> +				 struct security_mnt_opts *opts)
>  {
> -	if (unlikely(num_opts))
> +	if (unlikely(opts->num_mnt_opts))
>  		return -EOPNOTSUPP;
>  	return 0;
>  }
> @@ -268,6 +265,11 @@ static void dummy_sb_clone_mnt_opts(const struct
> super_block *oldsb,
>  	return;
>  }
>  
> +static int dummy_sb_parse_opts_str(char *options, struct security_mnt_opts
> *opts)
> +{
> +	return 0;
> +}
> +
>  static int dummy_inode_alloc_security (struct inode *inode)
>  {
>  	return 0;
> @@ -1028,6 +1030,7 @@ void security_fixup_ops (struct security_operations
> *ops)
>  	set_to_dummy_if_null(ops, sb_get_mnt_opts);
>  	set_to_dummy_if_null(ops, sb_set_mnt_opts);
>  	set_to_dummy_if_null(ops, sb_clone_mnt_opts);
> +	set_to_dummy_if_null(ops, sb_parse_opts_str);
>  	set_to_dummy_if_null(ops, inode_alloc_security);
>  	set_to_dummy_if_null(ops, inode_free_security);
>  	set_to_dummy_if_null(ops, inode_init_security);
> diff --git a/security/security.c b/security/security.c
> index d15e56c..b1387a6 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -244,10 +244,11 @@ void security_sb_free(struct super_block *sb)
>  	security_ops->sb_free_security(sb);
>  }
>  
> -int security_sb_copy_data(struct file_system_type *type, void *orig, void
> *copy)
> +int security_sb_copy_data(char *orig, char *copy)
>  {
> -	return security_ops->sb_copy_data(type, orig, copy);
> +	return security_ops->sb_copy_data(orig, copy);
>  }
> +EXPORT_SYMBOL(security_sb_copy_data);
>  
>  int security_sb_kern_mount(struct super_block *sb, void *data)
>  {
> @@ -306,24 +307,30 @@ void security_sb_post_pivotroot(struct nameidata
> *old_nd, struct nameidata *new_
>  }
>  
>  int security_sb_get_mnt_opts(const struct super_block *sb,
> -			      char ***mount_options,
> -			      int **flags, int *num_opts)
> +				struct security_mnt_opts *opts)
>  {
> -	return security_ops->sb_get_mnt_opts(sb, mount_options, flags, num_opts);
> +	return security_ops->sb_get_mnt_opts(sb, opts);
>  }
>  
>  int security_sb_set_mnt_opts(struct super_block *sb,
> -			      char **mount_options,
> -			      int *flags, int num_opts)
> +				struct security_mnt_opts *opts)
>  {
> -	return security_ops->sb_set_mnt_opts(sb, mount_options, flags, num_opts);
> +	return security_ops->sb_set_mnt_opts(sb, opts);
>  }
> +EXPORT_SYMBOL(security_sb_set_mnt_opts);
>  
>  void security_sb_clone_mnt_opts(const struct super_block *oldsb,
>  				struct super_block *newsb)
>  {
>  	security_ops->sb_clone_mnt_opts(oldsb, newsb);
>  }
> +EXPORT_SYMBOL(security_sb_clone_mnt_opts);
> +
> +int security_sb_parse_opts_str(char *options, struct security_mnt_opts
> *opts)
> +{
> +	return security_ops->sb_parse_opts_str(options, opts);
> +}
> +EXPORT_SYMBOL(security_sb_parse_opts_str);
>  
>  int security_inode_alloc(struct inode *inode)
>  {
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 75c2e99..dea6d21 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -443,8 +443,7 @@ out:
>   * mount options, or whatever.
>   */
>  static int selinux_get_mnt_opts(const struct super_block *sb,
> -				char ***mount_options, int **mnt_opts_flags,
> -				int *num_opts)
> +				struct security_mnt_opts *opts)
>  {
>  	int rc = 0, i;
>  	struct superblock_security_struct *sbsec = sb->s_security;
> @@ -452,9 +451,7 @@ static int selinux_get_mnt_opts(const struct super_block
> *sb,
>  	u32 len;
>  	char tmp;
>  
> -	*num_opts = 0;
> -	*mount_options = NULL;
> -	*mnt_opts_flags = NULL;
> +	security_init_mnt_opts(opts);
>  
>  	if (!sbsec->initialized)
>  		return -EINVAL;
> @@ -470,18 +467,18 @@ static int selinux_get_mnt_opts(const struct
> super_block *sb,
>  	/* count the number of mount options for this sb */
>  	for (i = 0; i < 8; i++) {
>  		if (tmp & 0x01)
> -			(*num_opts)++;
> +			opts->num_mnt_opts++;
>  		tmp >>= 1;
>  	}
>  
> -	*mount_options = kcalloc(*num_opts, sizeof(char *), GFP_ATOMIC);
> -	if (!*mount_options) {
> +	opts->mnt_opts = kcalloc(opts->num_mnt_opts, sizeof(char *), GFP_ATOMIC);
> +	if (!opts->mnt_opts) {
>  		rc = -ENOMEM;
>  		goto out_free;
>  	}
>  
> -	*mnt_opts_flags = kcalloc(*num_opts, sizeof(int), GFP_ATOMIC);
> -	if (!*mnt_opts_flags) {
> +	opts->mnt_opts_flags = kcalloc(opts->num_mnt_opts, sizeof(int),
> GFP_ATOMIC);
> +	if (!opts->mnt_opts_flags) {
>  		rc = -ENOMEM;
>  		goto out_free;
>  	}
> @@ -491,22 +488,22 @@ static int selinux_get_mnt_opts(const struct
> super_block *sb,
>  		rc = security_sid_to_context(sbsec->sid, &context, &len);
>  		if (rc)
>  			goto out_free;
> -		(*mount_options)[i] = context;
> -		(*mnt_opts_flags)[i++] = FSCONTEXT_MNT;
> +		opts->mnt_opts[i] = context;
> +		opts->mnt_opts_flags[i++] = FSCONTEXT_MNT;
>  	}
>  	if (sbsec->flags & CONTEXT_MNT) {
>  		rc = security_sid_to_context(sbsec->mntpoint_sid, &context, &len);
>  		if (rc)
>  			goto out_free;
> -		(*mount_options)[i] = context;
> -		(*mnt_opts_flags)[i++] = CONTEXT_MNT;
> +		opts->mnt_opts[i] = context;
> +		opts->mnt_opts_flags[i++] = CONTEXT_MNT;
>  	}
>  	if (sbsec->flags & DEFCONTEXT_MNT) {
>  		rc = security_sid_to_context(sbsec->def_sid, &context, &len);
>  		if (rc)
>  			goto out_free;
> -		(*mount_options)[i] = context;
> -		(*mnt_opts_flags)[i++] = DEFCONTEXT_MNT;
> +		opts->mnt_opts[i] = context;
> +		opts->mnt_opts_flags[i++] = DEFCONTEXT_MNT;
>  	}
>  	if (sbsec->flags & ROOTCONTEXT_MNT) {
>  		struct inode *root = sbsec->sb->s_root->d_inode;
> @@ -515,24 +512,16 @@ static int selinux_get_mnt_opts(const struct
> super_block *sb,
>  		rc = security_sid_to_context(isec->sid, &context, &len);
>  		if (rc)
>  			goto out_free;
> -		(*mount_options)[i] = context;
> -		(*mnt_opts_flags)[i++] = ROOTCONTEXT_MNT;
> +		opts->mnt_opts[i] = context;
> +		opts->mnt_opts_flags[i++] = ROOTCONTEXT_MNT;
>  	}
>  
> -	BUG_ON(i != *num_opts);
> +	BUG_ON(i != opts->num_mnt_opts);
>  
>  	return 0;
>  
>  out_free:
> -	/* don't leak context string if security_sid_to_context had an error */
> -	if (*mount_options && i)
> -		for (; i > 0; i--)
> -			kfree((*mount_options)[i-1]);
> -	kfree(*mount_options);
> -	*mount_options = NULL;
> -	kfree(*mnt_opts_flags);
> -	*mnt_opts_flags = NULL;
> -	*num_opts = 0;
> +	security_free_mnt_opts(opts);
>  	return rc;
>  }
>  
> @@ -553,12 +542,13 @@ static int bad_option(struct superblock_security_struct
> *sbsec, char flag,
>  			return 1;
>  	return 0;
>  }
> +
>  /*
>   * Allow filesystems with binary mount data to explicitly set mount point
>   * labeling information.
>   */
> -static int selinux_set_mnt_opts(struct super_block *sb, char
> **mount_options,
> -				int *flags, int num_opts)
> +static int selinux_set_mnt_opts(struct super_block *sb,
> +				struct security_mnt_opts *opts)
>  {
>  	int rc = 0, i;
>  	struct task_security_struct *tsec = current->security;
> @@ -568,6 +558,9 @@ static int selinux_set_mnt_opts(struct super_block *sb,
> char **mount_options,
>  	struct inode_security_struct *root_isec = inode->i_security;
>  	u32 fscontext_sid = 0, context_sid = 0, rootcontext_sid = 0;
>  	u32 defcontext_sid = 0;
> +	char **mount_options = opts->mnt_opts;
> +	int *flags = opts->mnt_opts_flags;
> +	int num_opts = opts->num_mnt_opts;
>  
>  	mutex_lock(&sbsec->lock);
>  
> @@ -589,6 +582,21 @@ static int selinux_set_mnt_opts(struct super_block *sb,
> char **mount_options,
>  	}
>  
>  	/*
> +	 * Binary mount data FS will come through this function twice.  Once
> +	 * from an explicit call and once from the generic calls from the vfs.
> +	 * Since the generic VFS calls will not contain any security mount data
> +	 * we need to skip the double mount verification.
> +	 *
> +	 * This does open a hole in which we will not notice if the first
> +	 * mount using this sb set explict options and a second mount using
> +	 * this sb does not set any security options.  (The first options
> +	 * will be used for both mounts)
> +	 */
> +	if (sbsec->initialized && (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
> +	    && (num_opts == 0))
> +	        goto out;
> +
> +	/*
>  	 * parse the mount options, check if they are valid sids.
>  	 * also check if someone is trying to mount the same sb more
>  	 * than once with different security options.
> @@ -792,43 +800,14 @@ static void selinux_sb_clone_mnt_opts(const struct
> super_block *oldsb,
>  	mutex_unlock(&newsbsec->lock);
>  }
>  
> -/*
> - * string mount options parsing and call set the sbsec
> - */
> -static int superblock_doinit(struct super_block *sb, void *data)
> +int selinux_parse_opts_str(char *options, struct security_mnt_opts *opts)
>  {
> +	char *p;
>  	char *context = NULL, *defcontext = NULL;
>  	char *fscontext = NULL, *rootcontext = NULL;
> -	int rc = 0;
> -	char *p, *options = data;
> -	/* selinux only know about a fixed number of mount options */
> -	char *mnt_opts[NUM_SEL_MNT_OPTS];
> -	int mnt_opts_flags[NUM_SEL_MNT_OPTS], num_mnt_opts = 0;
> -
> -	if (!data)
> -		goto out;
> +	int rc, num_mnt_opts = 0;
>  
> -	/* with the nfs patch this will become a goto out; */
> -	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
> -		const char *name = sb->s_type->name;
> -		/* NFS we understand. */
> -		if (!strcmp(name, "nfs")) {
> -			struct nfs_mount_data *d = data;
> -
> -			if (d->version !=  NFS_MOUNT_VERSION)
> -				goto out;
> -
> -			if (d->context[0]) {
> -				context = kstrdup(d->context, GFP_KERNEL);
> -				if (!context) {
> -					rc = -ENOMEM;
> -					goto out;
> -				}
> -			}
> -			goto build_flags;
> -		} else
> -			goto out;
> -	}
> +	opts->num_mnt_opts = 0;
>  
>  	/* Standard string-based options. */
>  	while ((p = strsep(&options, "|")) != NULL) {
> @@ -901,26 +880,37 @@ static int superblock_doinit(struct super_block *sb,
> void *data)
>  		}
>  	}
>  
> -build_flags:
> +	rc = -ENOMEM;
> +	opts->mnt_opts = kcalloc(NUM_SEL_MNT_OPTS, sizeof(char *), GFP_ATOMIC);
> +	if (!opts->mnt_opts)
> +		goto out_err;
> +
> +	opts->mnt_opts_flags = kcalloc(NUM_SEL_MNT_OPTS, sizeof(int), GFP_ATOMIC);
> +	if (!opts->mnt_opts_flags) {
> +		kfree(opts->mnt_opts);
> +		goto out_err;
> +	}
> +
>  	if (fscontext) {
> -		mnt_opts[num_mnt_opts] = fscontext;
> -		mnt_opts_flags[num_mnt_opts++] = FSCONTEXT_MNT;
> +		opts->mnt_opts[num_mnt_opts] = fscontext;
> +		opts->mnt_opts_flags[num_mnt_opts++] = FSCONTEXT_MNT;
>  	}
>  	if (context) {
> -		mnt_opts[num_mnt_opts] = context;
> -		mnt_opts_flags[num_mnt_opts++] = CONTEXT_MNT;
> +		opts->mnt_opts[num_mnt_opts] = context;
> +		opts->mnt_opts_flags[num_mnt_opts++] = CONTEXT_MNT;
>  	}
>  	if (rootcontext) {
> -		mnt_opts[num_mnt_opts] = rootcontext;
> -		mnt_opts_flags[num_mnt_opts++] = ROOTCONTEXT_MNT;
> +		opts->mnt_opts[num_mnt_opts] = rootcontext;
> +		opts->mnt_opts_flags[num_mnt_opts++] = ROOTCONTEXT_MNT;
>  	}
>  	if (defcontext) {
> -		mnt_opts[num_mnt_opts] = defcontext;
> -		mnt_opts_flags[num_mnt_opts++] = DEFCONTEXT_MNT;
> +		opts->mnt_opts[num_mnt_opts] = defcontext;
> +		opts->mnt_opts_flags[num_mnt_opts++] = DEFCONTEXT_MNT;
>  	}
>  
> -out:
> -	rc = selinux_set_mnt_opts(sb, mnt_opts, mnt_opts_flags, num_mnt_opts);
> +	opts->num_mnt_opts = num_mnt_opts;
> +	return 0;
> +
>  out_err:
>  	kfree(context);
>  	kfree(defcontext);
> @@ -928,6 +918,33 @@ out_err:
>  	kfree(rootcontext);
>  	return rc;
>  }
> +/*
> + * string mount options parsing and call set the sbsec
> + */
> +static int superblock_doinit(struct super_block *sb, void *data)
> +{
> +	int rc = 0;
> +	char *options = data;
> +	struct security_mnt_opts opts;
> +
> +	security_init_mnt_opts(&opts);
> +
> +	if (!data)
> +		goto out;
> +
> +	BUG_ON(sb->s_type->fs_flags & FS_BINARY_MOUNTDATA);
> +
> +	rc = selinux_parse_opts_str(options, &opts);
> +	if (rc)
> +		goto out_err;
> +
> +out:
> +	rc = selinux_set_mnt_opts(sb, &opts);
> +
> +out_err:
> +	security_free_mnt_opts(&opts);
> +	return rc;
> +}
>  
>  static inline u16 inode_mode_to_security_class(umode_t mode)
>  {
> @@ -2253,7 +2270,7 @@ static inline void take_selinux_option(char **to, char
> *from, int *first,
>  	}
>  }
>  
> -static int selinux_sb_copy_data(struct file_system_type *type, void *orig,
> void *copy)
> +static int selinux_sb_copy_data(char *orig, char *copy)
>  {
>  	int fnosec, fsec, rc = 0;
>  	char *in_save, *in_curr, *in_end;
> @@ -2263,12 +2280,6 @@ static int selinux_sb_copy_data(struct
> file_system_type *type, void *orig, void
>  	in_curr = orig;
>  	sec_curr = copy;
>  
> -	/* Binary mount data: just copy */
> -	if (type->fs_flags & FS_BINARY_MOUNTDATA) {
> -		copy_page(sec_curr, in_curr);
> -		goto out;
> -	}
> -
>  	nosec = (char *)get_zeroed_page(GFP_KERNEL);
>  	if (!nosec) {
>  		rc = -ENOMEM;
> @@ -5251,6 +5262,8 @@ static struct security_operations selinux_ops = {
>  	.sb_get_mnt_opts =		selinux_get_mnt_opts,
>  	.sb_set_mnt_opts =		selinux_set_mnt_opts,
>  	.sb_clone_mnt_opts = 		selinux_sb_clone_mnt_opts,
> +	.sb_parse_opts_str = 		selinux_parse_opts_str,
> +	
>  
>  	.inode_alloc_security =		selinux_inode_alloc_security,
>  	.inode_free_security =		selinux_inode_free_security,
> diff --git a/security/selinux/include/security.h
> b/security/selinux/include/security.h
> index 837ce42..f7d2f03 100644
> --- a/security/selinux/include/security.h
> +++ b/security/selinux/include/security.h
> @@ -35,6 +35,11 @@
>  #define POLICYDB_VERSION_MAX	POLICYDB_VERSION_POLCAP
>  #endif
>  
> +#define CONTEXT_MNT	0x01
> +#define FSCONTEXT_MNT	0x02
> +#define ROOTCONTEXT_MNT	0x04
> +#define DEFCONTEXT_MNT	0x08
> +
>  struct netlbl_lsm_secattr;
>  
>  extern int selinux_enabled;
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 770eb06..0241fd3 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -189,17 +189,10 @@ static void smack_sb_free_security(struct super_block
> *sb)
>   * Copy the Smack specific mount options out of the mount
>   * options list.
>   */
> -static int smack_sb_copy_data(struct file_system_type *type, void *orig,
> -			      void *smackopts)
> +static int smack_sb_copy_data(char *orig, char *smackopts)
>  {
>  	char *cp, *commap, *otheropts, *dp;
>  
> -	/* Binary mount data: just copy */
> -	if (type->fs_flags & FS_BINARY_MOUNTDATA) {
> -		copy_page(smackopts, orig);
> -		return 0;
> -	}
> -
>  	otheropts = (char *)get_zeroed_page(GFP_KERNEL);
>  	if (otheropts == NULL)
>  		return -ENOMEM;
> 
> 
> 
> 


Casey Schaufler
casey@schaufler-ca.com
