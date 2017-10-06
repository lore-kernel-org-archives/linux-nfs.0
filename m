Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:58087 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdJFUhp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Oct 2017 16:37:45 -0400
Subject: Re: [PATCH 02/14] VFS: Add LSM hooks for filesystem context [ver #6]
To: David Howells <dhowells@redhat.com>, viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com, linux-security-module@vger.kernel.org
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496198.6182.922475266367301404.stgit@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <34d21987-4939-5fd0-32f0-f4e7886987fc@infradead.org>
Date: Fri, 6 Oct 2017 13:37:43 -0700
MIME-Version: 1.0
In-Reply-To: <150730496198.6182.922475266367301404.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

add cc: linux-security-module@vger.kernel.org

On 10/06/17 08:49, David Howells wrote:
> Add LSM hooks for use by the filesystem context code.  This includes:
> 
>  (1) Hooks to handle allocation, duplication and freeing of the security
>      record attached to a filesystem context.
> 
>  (2) A hook to snoop a mount options in key[=val] form.  If the LSM decides
>      it wants to handle it, it can suppress the option being passed to the
>      filesystem.  Note that 'val' may include commas and binary data with
>      the fsopen patch.
> 
>  (3) A hook to transfer the security from the context to a newly created
>      superblock.
> 
>  (4) A hook to rule on whether a path point can be used as a mountpoint.
> 
> These are intended to replace:
> 
> 	security_sb_copy_data
> 	security_sb_kern_mount
> 	security_sb_mount
> 	security_sb_set_mnt_opts
> 	security_sb_clone_mnt_opts
> 	security_sb_parse_opts_str
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: linux-security-module@vger.kernel.org
> ---
> 
>  include/linux/lsm_hooks.h |   45 ++++++++++++
>  include/linux/security.h  |   33 +++++++++
>  security/security.c       |   30 ++++++++
>  security/selinux/hooks.c  |  174 +++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 282 insertions(+)
> 
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index c9258124e417..85398ba0b533 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -76,6 +76,38 @@
>   *	changes on the process such as clearing out non-inheritable signal
>   *	state.  This is called immediately after commit_creds().
>   *
> + * Security hooks for mount using fd context.
> + *
> + * @fs_context_alloc:
> + *	Allocate and attach a security structure to sc->security.  This pointer
> + *	is initialised to NULL by the caller.
> + *	@fc indicates the new filesystem context.
> + *	@src_sb indicates the source superblock of a submount.
> + * @fs_context_dup:
> + *	Allocate and attach a security structure to sc->security.  This pointer
> + *	is initialised to NULL by the caller.
> + *	@fc indicates the new filesystem context.
> + *	@src_fc indicates the original filesystem context.
> + * @fs_context_free:
> + *	Clean up a filesystem context.
> + *	@fc indicates the filesystem context.
> + * @fs_context_parse_one:
> + *	Userspace provided an option to configure a superblock.  The LSM may
> + *	reject it with an error and may use it for itself, in which case it
> + *	should return 1; otherwise it should return 0 to pass it on to the
> + *	filesystem.
> + *	@fc indicates the filesystem context.
> + *	@p indicates the option in "key[=val]" form.
> + * @sb_get_tree:
> + *	Assign the security to a newly created superblock.
> + *	@fc indicates the filesystem context.
> + *	@fc->root indicates the root that will be mounted.
> + *	@fc->root->d_sb points to the superblock.
> + * @sb_mountpoint:
> + *	Equivalent of sb_mount, but with an fs_context.
> + *	@fc indicates the filesystem context.
> + *	@mountpoint indicates the path on which the mount will take place.
> + *
>   * Security hooks for filesystem operations.
>   *
>   * @sb_alloc_security:
> @@ -1384,6 +1416,13 @@ union security_list_options {
>  	void (*bprm_committing_creds)(struct linux_binprm *bprm);
>  	void (*bprm_committed_creds)(struct linux_binprm *bprm);
>  
> +	int (*fs_context_alloc)(struct fs_context *fc, struct super_block *src_sb);
> +	int (*fs_context_dup)(struct fs_context *fc, struct fs_context *src_sc);
> +	void (*fs_context_free)(struct fs_context *fc);
> +	int (*fs_context_parse_one)(struct fs_context *fc, char *opt);
> +	int (*sb_get_tree)(struct fs_context *fc);
> +	int (*sb_mountpoint)(struct fs_context *fc, struct path *mountpoint);
> +
>  	int (*sb_alloc_security)(struct super_block *sb);
>  	void (*sb_free_security)(struct super_block *sb);
>  	int (*sb_copy_data)(char *orig, char *copy);
> @@ -1703,6 +1742,12 @@ struct security_hook_heads {
>  	struct list_head bprm_check_security;
>  	struct list_head bprm_committing_creds;
>  	struct list_head bprm_committed_creds;
> +	struct list_head fs_context_alloc;
> +	struct list_head fs_context_dup;
> +	struct list_head fs_context_free;
> +	struct list_head fs_context_parse_one;
> +	struct list_head sb_get_tree;
> +	struct list_head sb_mountpoint;
>  	struct list_head sb_alloc_security;
>  	struct list_head sb_free_security;
>  	struct list_head sb_copy_data;
> diff --git a/include/linux/security.h b/include/linux/security.h
> index ce6265960d6c..4a47c732d7b8 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -56,6 +56,7 @@ struct msg_queue;
>  struct xattr;
>  struct xfrm_sec_ctx;
>  struct mm_struct;
> +struct fs_context;
>  
>  /* If capable should audit the security request */
>  #define SECURITY_CAP_NOAUDIT 0
> @@ -233,6 +234,12 @@ int security_bprm_set_creds(struct linux_binprm *bprm);
>  int security_bprm_check(struct linux_binprm *bprm);
>  void security_bprm_committing_creds(struct linux_binprm *bprm);
>  void security_bprm_committed_creds(struct linux_binprm *bprm);
> +int security_fs_context_alloc(struct fs_context *fc, struct super_block *sb);
> +int security_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc);
> +void security_fs_context_free(struct fs_context *fc);
> +int security_fs_context_parse_option(struct fs_context *fc, char *opt);
> +int security_sb_get_tree(struct fs_context *fc);
> +int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint);
>  int security_sb_alloc(struct super_block *sb);
>  void security_sb_free(struct super_block *sb);
>  int security_sb_copy_data(char *orig, char *copy);
> @@ -540,6 +547,32 @@ static inline void security_bprm_committed_creds(struct linux_binprm *bprm)
>  {
>  }
>  
> +static inline int security_fs_context_alloc(struct fs_context *fc,
> +					    struct super_block *src_sb)
> +{
> +	return 0;
> +}
> +static inline int security_fs_context_dup(struct fs_context *fc,
> +					  struct fs_context *src_fc)
> +{
> +	return 0;
> +}
> +static inline void security_fs_context_free(struct fs_context *fc)
> +{
> +}
> +static inline int security_fs_context_parse_option(struct fs_context *fc, char *opt)
> +{
> +	return 0;
> +}
> +static inline int security_sb_get_tree(struct fs_context *fc)
> +{
> +	return 0;
> +}
> +static inline int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
> +{
> +	return 0;
> +}
> +
>  static inline int security_sb_alloc(struct super_block *sb)
>  {
>  	return 0;
> diff --git a/security/security.c b/security/security.c
> index 4bf0f571b4ef..55383a0e764d 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -351,6 +351,36 @@ void security_bprm_committed_creds(struct linux_binprm *bprm)
>  	call_void_hook(bprm_committed_creds, bprm);
>  }
>  
> +int security_fs_context_alloc(struct fs_context *fc, struct super_block *src_sb)
> +{
> +	return call_int_hook(fs_context_alloc, 0, fc, src_sb);
> +}
> +
> +int security_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc)
> +{
> +	return call_int_hook(fs_context_dup, 0, fc, src_fc);
> +}
> +
> +void security_fs_context_free(struct fs_context *fc)
> +{
> +	call_void_hook(fs_context_free, fc);
> +}
> +
> +int security_fs_context_parse_one(struct fs_context *fc, char *opt)
> +{
> +	return call_int_hook(fs_context_parse_one, 0, fc, opt);
> +}
> +
> +int security_sb_get_tree(struct fs_context *fc)
> +{
> +	return call_int_hook(sb_get_tree, 0, fc);
> +}
> +
> +int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
> +{
> +	return call_int_hook(sb_mountpoint, 0, fc, mountpoint);
> +}
> +
>  int security_sb_alloc(struct super_block *sb)
>  {
>  	return call_int_hook(sb_alloc_security, 0, sb);
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 6f37f7e5b9a8..0dda7350b5af 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -48,6 +48,7 @@
>  #include <linux/fdtable.h>
>  #include <linux/namei.h>
>  #include <linux/mount.h>
> +#include <linux/fs_context.h>
>  #include <linux/netfilter_ipv4.h>
>  #include <linux/netfilter_ipv6.h>
>  #include <linux/tty.h>
> @@ -2862,6 +2863,172 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
>  				   FILESYSTEM__UNMOUNT, NULL);
>  }
>  
> +/* fsopen mount context operations */
> +
> +static int selinux_fs_context_alloc(struct fs_context *fc,
> +				    struct super_block *src_sb)
> +{
> +	struct security_mnt_opts *opts;
> +
> +	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
> +	if (!opts)
> +		return -ENOMEM;
> +
> +	fc->security = opts;
> +	return 0;
> +}
> +
> +static int selinux_fs_context_dup(struct fs_context *fc,
> +				  struct fs_context *src_fc)
> +{
> +	const struct security_mnt_opts *src = src_fc->security;
> +	struct security_mnt_opts *opts;
> +	int i, n;
> +
> +	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
> +	if (!opts)
> +		return -ENOMEM;
> +	fc->security = opts;
> +
> +	if (!src || !src->num_mnt_opts)
> +		return 0;
> +	n = opts->num_mnt_opts = src->num_mnt_opts;
> +
> +	if (src->mnt_opts) {
> +		opts->mnt_opts = kcalloc(n, sizeof(char *), GFP_KERNEL);
> +		if (!opts->mnt_opts)
> +			return -ENOMEM;
> +
> +		for (i = 0; i < n; i++) {
> +			if (src->mnt_opts[i]) {
> +				opts->mnt_opts[i] = kstrdup(src->mnt_opts[i],
> +							    GFP_KERNEL);
> +				if (!opts->mnt_opts[i])
> +					return -ENOMEM;
> +			}
> +		}
> +	}
> +
> +	if (src->mnt_opts_flags) {
> +		opts->mnt_opts_flags = kmemdup(src->mnt_opts_flags,
> +					       n * sizeof(int), GFP_KERNEL);
> +		if (!opts->mnt_opts_flags)
> +			return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +
> +static void selinux_fs_context_free(struct fs_context *fc)
> +{
> +	struct security_mnt_opts *opts = fc->security;
> +
> +	security_free_mnt_opts(opts);
> +	fc->security = NULL;
> +}
> +
> +static int selinux_fs_context_parse_one(struct fs_context *fc, char *opt)
> +{
> +	struct security_mnt_opts *opts = fc->security;
> +	substring_t args[MAX_OPT_ARGS];
> +	unsigned int have;
> +	char *c, **oo;
> +	int token, ctx, i, *of;
> +
> +	token = match_token(opt, tokens, args);
> +	if (token == Opt_error)
> +		return 0; /* Doesn't belong to us. */
> +
> +	have = 0;
> +	for (i = 0; i < opts->num_mnt_opts; i++)
> +		have |= 1 << opts->mnt_opts_flags[i];
> +	if (have & (1 << token))
> +		return -EINVAL;
> +
> +	switch (token) {
> +	case Opt_context:
> +		if (have & (1 << Opt_defcontext))
> +			goto incompatible;
> +		ctx = CONTEXT_MNT;
> +		goto copy_context_string;
> +
> +	case Opt_fscontext:
> +		ctx = FSCONTEXT_MNT;
> +		goto copy_context_string;
> +
> +	case Opt_rootcontext:
> +		ctx = ROOTCONTEXT_MNT;
> +		goto copy_context_string;
> +
> +	case Opt_defcontext:
> +		if (have & (1 << Opt_context))
> +			goto incompatible;
> +		ctx = DEFCONTEXT_MNT;
> +		goto copy_context_string;
> +
> +	case Opt_labelsupport:
> +		return 1;
> +
> +	default:
> +		return -EINVAL;
> +	}
> +
> +copy_context_string:
> +	if (opts->num_mnt_opts > 3)
> +		return -EINVAL;
> +
> +	of = krealloc(opts->mnt_opts_flags,
> +		      (opts->num_mnt_opts + 1) * sizeof(int), GFP_KERNEL);
> +	if (!of)
> +		return -ENOMEM;
> +	of[opts->num_mnt_opts] = 0;
> +	opts->mnt_opts_flags = of;
> +
> +	oo = krealloc(opts->mnt_opts,
> +		      (opts->num_mnt_opts + 1) * sizeof(char *), GFP_KERNEL);
> +	if (!oo)
> +		return -ENOMEM;
> +	oo[opts->num_mnt_opts] = NULL;
> +	opts->mnt_opts = oo;
> +
> +	c = match_strdup(&args[0]);
> +	if (!c)
> +		return -ENOMEM;
> +	opts->mnt_opts[opts->num_mnt_opts] = c;
> +	opts->mnt_opts_flags[opts->num_mnt_opts] = ctx;
> +	opts->num_mnt_opts++;
> +	return 1;
> +
> +incompatible:
> +	return -EINVAL;
> +}
> +
> +static int selinux_sb_get_tree(struct fs_context *fc)
> +{
> +	const struct cred *cred = current_cred();
> +	struct common_audit_data ad;
> +	int rc;
> +
> +	rc = selinux_set_mnt_opts(fc->root->d_sb, fc->security, 0, NULL);
> +	if (rc)
> +		return rc;
> +
> +	/* Allow all mounts performed by the kernel */
> +	if (fc->sb_flags & MS_KERNMOUNT)
> +		return 0;
> +
> +	ad.type = LSM_AUDIT_DATA_DENTRY;
> +	ad.u.dentry = fc->root;
> +	return superblock_has_perm(cred, fc->root->d_sb, FILESYSTEM__MOUNT, &ad);
> +}
> +
> +static int selinux_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
> +{
> +	const struct cred *cred = current_cred();
> +
> +	return path_has_perm(cred, mountpoint, FILE__MOUNTON);
> +}
> +
>  /* inode security operations */
>  
>  static int selinux_inode_alloc_security(struct inode *inode)
> @@ -6275,6 +6442,13 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
>  	LSM_HOOK_INIT(bprm_committing_creds, selinux_bprm_committing_creds),
>  	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
>  
> +	LSM_HOOK_INIT(fs_context_alloc, selinux_fs_context_alloc),
> +	LSM_HOOK_INIT(fs_context_dup, selinux_fs_context_dup),
> +	LSM_HOOK_INIT(fs_context_free, selinux_fs_context_free),
> +	LSM_HOOK_INIT(fs_context_parse_one, selinux_fs_context_parse_one),
> +	LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
> +	LSM_HOOK_INIT(sb_mountpoint, selinux_sb_mountpoint),
> +
>  	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
>  	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
>  	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),
> 


-- 
~Randy
