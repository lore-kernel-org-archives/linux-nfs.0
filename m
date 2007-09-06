From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] 1/2 SELinux: Add get, set,
	and cloning of superblock	security information
Date: Thu, 06 Sep 2007 14:33:29 -0400
Message-ID: <1189103609.3617.169.camel@moss-spartans.epoch.ncsc.mil>
References: <1189030563.3460.41.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov, steved@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITMDN-0005r0-Cn
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 11:36:31 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITMDR-0006uI-GL
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 11:36:34 -0700
In-Reply-To: <1189030563.3460.41.camel@dhcp231-215.rdu.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-09-05 at 18:16 -0400, Eric Paris wrote:
> Adds security_get_sb_mnt_opts, security_set_sb_mnt_opts, and
> security_clont_sb_mnt_opts to the LSM and to SELinux.  This is in
> preparation for NFS to be able to own its own mount options and remove
> the NFS specific code from SELinux.
> 
> >From the point of view of SELinux NFS does not use text based mount
> options so this patch is not something that is going away.  NFS merely
> takes the text options from userspace and puts them into the same binary
> format as always and passes that binary mount data around.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> ---
> 
>  include/linux/security.h          |   70 +++++
>  security/dummy.c                  |   26 ++
>  security/selinux/hooks.c          |  618 ++++++++++++++++++++++++-------------
>  security/selinux/include/objsec.h |    1 +
>  4 files changed, 505 insertions(+), 210 deletions(-)

Not a very nice diff to read.

> diff --git a/include/linux/security.h b/include/linux/security.h
> index 1a15526..65f2d91 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -2334,6 +2383,27 @@ static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
>  					       struct nameidata *new_nd)
>  { }
>  
> +static inline int security_sb_get_mnt_opts (const struct super_block *sb,
> +					    char ***mount_options,
> +					    int **flags, int *num_opts)
> +{
> +	*mount_options = NULL;
> +	*flags = NULL;
> +	*num_opts = 0;
> +	return 0;
> +}
> +
> +static inline int security_sb_set_mnt_opts (struct super_block *sb,
> +					    char **mount_options,
> +					    int *flags, int num_opts)
> +{
> +	return 0;
> +}

For consistency, this should likely do the same thing as the dummy
function, i.e. return -EOPNOTSUPP if num_opts > 0.  Actually, is this
going to get called at all unless num_opts is > 0?

> diff --git a/security/dummy.c b/security/dummy.c
> index 853ec22..c3ac361 100644
> --- a/security/dummy.c
> +++ b/security/dummy.c
> @@ -248,6 +248,29 @@ static void dummy_sb_post_pivotroot (struct nameidata *old_nd, struct nameidata
>  	return;
>  }
>  
> +static int dummy_sb_get_mnt_opts(const struct super_block *sb, char ***mount_options,
> +				 int **flags, int *num_opts)
> +{
> +	*mount_options = NULL;
> +	*flags = NULL;
> +	*num_opts = 0;
> +	return 0;
> +}
> +
> +static int dummy_sb_set_mnt_opts(struct super_block *sb, char **mount_options,
> +				 int *flags, int num_opts)
> +{
> +	if (unlikely(num_opts))
> +		return -EOPNOTSUPP;
> +	return 0;
> +}

Possibly just unconditionally return -EOPNOTSUPP, as the hook wouldn't
normally get called with no options.

> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 3694662..5ebe30b 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -362,135 +362,228 @@ static int may_context_mount_inode_relabel(u32 sid,
>  	return rc;
>  }
>  
> -static int try_context_mount(struct super_block *sb, void *data)
> +static int sb_finish_set_opts(struct super_block *sb)
>  {
> -	char *context = NULL, *defcontext = NULL;
> -	char *fscontext = NULL, *rootcontext = NULL;
> -	const char *name;
> -	u32 sid;
> -	int alloc = 0, rc = 0, seen = 0;
> -	struct task_security_struct *tsec = current->security;
>  	struct superblock_security_struct *sbsec = sb->s_security;
> +	struct dentry *root = sb->s_root;
> +	struct inode *root_inode = root->d_inode;
> +	int rc = 0;
>  
> -	if (!data)
> -		goto out;
> +	BUG_ON(!ss_initialized);

Why BUG_ON vs. return error?  context mount before initial policy load
is technically possible, even more so if booting permissive and policy
is corrupted.

>  
> -	name = sb->s_type->name;
> +	if (sbsec->initialized)
> +		return 0;

Under what conditions would we reach this point if sbsec was already
initialized?  Should it be an error?  A bug?

> +/*
> + * This function should allow an FS (like NFS) to ask what it's mount security
> + * options were so it can use those later for submounts and the like
> + */
> +static int selinux_get_mnt_opts(const struct super_block *sb,
> +				char ***mount_options, int **mnt_opts_flags,
> +				int *num_opts)
> +{
> +	int rc = 0, i;
> +	struct superblock_security_struct *sbsec = sb->s_security;
> +	char *context = NULL;
> +	u32 len;
> +	/* 
> +	 * if we ever use sbsec flags for anything other than tracking mount
> +	 * settings this is going to need a mask
> +	 */
> +	char tmp = sbsec->flags; 
> +	*num_opts = 0;
> +	*mount_options = NULL;
> +	*mnt_opts_flags = NULL;
> +
> +	for(i = 0; i < 8; i++) {
> +		if (tmp & 0x01)
> +			(*num_opts)++;
> +		tmp >>= 1;
> +	}
>  
> -		while ((p = strsep(&options, "|")) != NULL) {
> -			int token;
> -			substring_t args[MAX_OPT_ARGS];
> +	i = 0;
> +	*mount_options = kcalloc(*num_opts, sizeof(char *), GFP_ATOMIC);
> +	if (!*mount_options) {
> +		rc = -ENOMEM;
> +		goto out_free;
> +	}
>  
> -			if (!*p)
> -				continue;
> +	*mnt_opts_flags = kcalloc(*num_opts, sizeof(int), GFP_ATOMIC);
> +	if (!*mnt_opts_flags) {
> +		rc = -ENOMEM;
> +		goto out_free;
> +	}
>  
> -			token = match_token(p, tokens, args);
> +	if (sbsec->flags & FSCONTEXT_MNT) {
> +		rc = security_sid_to_context(sbsec->sid, &context, &len);
> +		if (rc)
> +			goto out_free;
> +		(*mount_options)[i] = context;
> +		(*mnt_opts_flags)[i++] = FSCONTEXT_MNT;
> +	}
> +	if (sbsec->flags & CONTEXT_MNT) {
> +		rc = security_sid_to_context(sbsec->mntpoint_sid, &context, &len);
> +		if (rc)
> +			goto out_free;
> +		(*mount_options)[i] = context;
> +		(*mnt_opts_flags)[i++] = CONTEXT_MNT;
> +	}
> +	if (sbsec->flags & DEFCONTEXT_MNT) {
> +		rc = security_sid_to_context(sbsec->def_sid, &context, &len);
> +		if (rc)
> +			goto out_free;
> +		(*mount_options)[i] = context;
> +		(*mnt_opts_flags)[i++] = DEFCONTEXT_MNT;
> +	}
> +	if (sbsec->flags & ROOTCONTEXT_MNT) {
> +		rc = security_sid_to_context(sbsec->def_sid, &context, &len);

Isn't that the wrong SID to use?

> +		if (rc)
> +			goto out_free;
> +		(*mount_options)[i] = context;
> +		(*mnt_opts_flags)[i++] = ROOTCONTEXT_MNT;
> +	}
<snip>
> +/*
> + * Allow filesystems with binary mount data to explicitly set mount point labeling.
> + */
> +int selinux_set_mnt_opts(struct super_block *sb, char **mount_options,
> +				 int *flags, int num_opts)
> +{
> +	int rc = 0, i;
> +	u32 sid;
> +	struct task_security_struct *tsec = current->security;
> +	struct superblock_security_struct *sbsec = sb->s_security;
> +	char *fscontext = NULL, *context = NULL, *rootcontext= NULL;
> +	char *defcontext = NULL;
> +	const char *name = sb->s_type->name;
>  
> -			default:
> -				rc = -EINVAL;
> -				printk(KERN_WARNING "SELinux:  unknown mount "
> -				       "option\n");
> -				goto out_free;
> +	mutex_lock(&sbsec->lock);
>  
> -			}
> -		}
> +	if (sbsec->initialized) {
> +		printk(KERN_WARNING "%s: we are here with sbsec->initialized == 1\n",
> +			__FUNCTION__);
> +		goto out;
>  	}

BUG_ON?  rc = -EINVAL?  Something other than printk and return 0.

> +static void selinux_sb_clone_mnt_opts (const struct super_block *oldsb,
> +					struct super_block *newsb)
> +{
> +	const struct superblock_security_struct *oldsbsec = oldsb->s_security;
> +	struct superblock_security_struct *newsbsec = newsb->s_security;
> +
> +	int set_fscontext =	(oldsbsec->flags & FSCONTEXT_MNT);
> +	int set_context =	(oldsbsec->flags & CONTEXT_MNT);
> +	int set_rootcontext =	(oldsbsec->flags & ROOTCONTEXT_MNT);
> +
> +	mutex_lock(&newsbsec->lock);
> +
> +	newsbsec->flags = oldsbsec->flags;
> +
> +	newsbsec->sid = oldsbsec->sid;
> +	newsbsec->def_sid = oldsbsec->def_sid;
> +	newsbsec->behavior = oldsbsec->behavior;
> +
> +	if (set_context) {
> +		u32 sid = oldsbsec->mntpoint_sid;
> +
> +		if (!set_fscontext)
> +			newsbsec->sid = sid;
> +		if (!set_rootcontext) {
> +			struct inode *newinode = newsb->s_root->d_inode;
> +			struct inode_security_struct *newisec = newinode->i_security;
> +			newisec->sid = sid;
> +		}
> +		newsbsec->mntpoint_sid = sid;
> +	}
> +	if (set_rootcontext) {
> +		const struct inode *oldinode = oldsb->s_root->d_inode;
> +		const struct inode_security_struct *oldisec = oldinode->i_security;
> +		struct inode *newinode = newsb->s_root->d_inode;
> +		struct inode_security_struct *newisec = newinode->i_security;
> +
> +		newisec->sid = oldisec->sid;
>  	}
> +
> +	sb_finish_set_opts(newsb);
> +	mutex_unlock(&newsbsec->lock);
> +}
> +
> +/*
> + * string mount options parsing and call to function to set the sbsec
> + */
> +static int try_context_mount(struct super_block *sb, void *data)
> +{
> +	char *context = NULL, *defcontext = NULL;
> +	char *fscontext = NULL, *rootcontext = NULL;
> +	int rc = 0;
> +	char *p, *options = data;
> +	/* selinux only know about 4 mount options */
> +	char *mnt_opts[4];
> +	int mnt_opts_flags[4], num_mnt_opts = 0;

Can we #define that once and use it?

> +	int con_from_nfs = 0;
> +
> +	if (!data)
> +		goto out;
> +
> +	/* with the nfs patch this will become a goto out; */

Hmm...not sure this is worth separating out for the second patch,
although it would mean that a kernel with only the first patch applied
won't have nfs context mount support at all.

> +	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
> +		const char *name = sb->s_type->name;
> +		/* NFS we understand. */
> +		if (!strcmp(name, "nfs")) {
> +			struct nfs_mount_data *d = data;
> +
> +			if (d->version !=  NFS_MOUNT_VERSION)
> +				goto out;
> +
> +			if (d->context[0])
> +				context = d->context;
> +			con_from_nfs = 1;
> +		} else
> +			goto out;
> +	} else {
> +
> +	/* Standard string-based options. */
> +	while ((p = strsep(&options, "|")) != NULL) {
> +		int token;
> +		substring_t args[MAX_OPT_ARGS];
> +
> +		if (!*p)
> +			continue;
> +
> +		token = match_token(p, tokens, args);
> +
> +		switch (token) {
> +		case Opt_context:
> +			if (context || defcontext) {
> +				rc = -EINVAL;
> +				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
> +				goto out_err;
> +			}
> +			context = match_strdup(&args[0]);
> +			if (!context) {
> +				rc = -ENOMEM;
> +				goto out_err;
> +			}
> +			break;
> +
> +		case Opt_fscontext:
> +			if (fscontext) {
> +				rc = -EINVAL;
> +				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
> +				goto out_err;
> +			}
> +			fscontext = match_strdup(&args[0]);
> +			if (!fscontext) {
> +				rc = -ENOMEM;
> +				goto out_err;
> +			}
> +			break;
> +
> +		case Opt_rootcontext:
> +			if (rootcontext) {
> +				rc = -EINVAL;
> +				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
> +				goto out_err;
> +			}
> +			rootcontext = match_strdup(&args[0]);
> +			if (!rootcontext) {
> +				rc = -ENOMEM;
> +				goto out_err;
> +			}
> +			break;
> +
> +		case Opt_defcontext:
> +			if (context || defcontext) {
> +				rc = -EINVAL;
> +				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
> +				goto out_err;
> +			}
> +			defcontext = match_strdup(&args[0]);
> +			if (!defcontext) {
> +				rc = -ENOMEM;
> +				goto out_err;
> +			}
> +			break;
> +
> +		default:
> +			rc = -EINVAL;
> +			printk(KERN_WARNING "SELinux:  unknown mount option\n");
> +			goto out_err;
> +
> +		}
> +	}
> +	} // else for binary mount data.  delete with nfs patch

Especially given this kind of ugliness.

> +
> +	if(fscontext){

Coding style nit throughout - if (x) { not if(x){

> +		mnt_opts[num_mnt_opts] = fscontext;
> +		mnt_opts_flags[num_mnt_opts++] = FSCONTEXT_MNT;
> +	}
> +	if(context){
> +		mnt_opts[num_mnt_opts] = context;
> +		mnt_opts_flags[num_mnt_opts++] = CONTEXT_MNT;
> +	}
> +	if(rootcontext){
> +		mnt_opts[num_mnt_opts] = rootcontext;
> +		mnt_opts_flags[num_mnt_opts++] = ROOTCONTEXT_MNT;
> +	}
> +	if(defcontext){
> +		mnt_opts[num_mnt_opts] = defcontext;
> +		mnt_opts_flags[num_mnt_opts++] = DEFCONTEXT_MNT;
> +	}
> +
>  out:
> +	rc = selinux_set_mnt_opts(sb, mnt_opts, mnt_opts_flags, num_mnt_opts);
> +out_err:
> +	/* remove conditional when we remove nfs */
> +	if (!con_from_nfs)
> +		kfree(context);

I'd just kill it now in this patch.

> +	kfree(defcontext);
> +	kfree(fscontext);
> +	kfree(rootcontext);
>  	return rc;
>  }
>  
> +/* 
> + * no locking done here, but it shouldn't matter, sbsec->proc would just get
> + * set the same way in another thread and fs_use, hmmmmmm 
> + */

Not sure I follow; you do take the lock still in set_mnts_opts before
doing the above AFAICS.  sbsec->list though is another matter.

>  static int superblock_doinit(struct super_block *sb, void *data)
>  {
>  	struct superblock_security_struct *sbsec = sb->s_security;
> -	struct dentry *root = sb->s_root;
> -	struct inode *inode = root->d_inode;
>  	int rc = 0;
>  
> -	mutex_lock(&sbsec->lock);
>  	if (sbsec->initialized)
>  		goto out;

One of the things that needs to be fixed is handling of a context mount
option when the superblock has previously been setup.  At present (and
still true of your patch), if one mounts /home/eparis with one context
mount and then tries to mount /home/sds with a different context mount,
the latter proceeds with no indication that the context mount option was
ignored (because we immediately return with success if already
initialized, and they'll end up with the same superblock if they are
from the same filesystem).  So we need to at least check to see if data
is set and return an error if sbsec is already initialized so that
userspace gets an indication of the fact.

-- 
Stephen Smalley
National Security Agency


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
