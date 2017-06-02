Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64919 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdFBNJU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Jun 2017 09:09:20 -0400
Date: Fri, 2 Jun 2017 09:09:18 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2] security/selinux: allow security_sb_clone_mnt_opts to
 enable/disable native labeling behavior
Message-ID: <20170602130918.gu22wnbd35idaurf@tonberry.usersys.redhat.com>
References: <1496341807.27759.15.camel@tycho.nsa.gov>
 <20170601205947.4917-1-smayhew@redhat.com>
 <1496408108.19674.1.camel@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1496408108.19674.1.camel@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 02 Jun 2017, Stephen Smalley wrote:

> On Thu, 2017-06-01 at 16:59 -0400, Scott Mayhew wrote:
> > When an NFSv4 client performs a mount operation, it first mounts the
> > NFSv4 root and then does path walk to the exported path and performs
> > a
> > submount on that, cloning the security mount options from the root's
> > superblock to the submount's superblock in the process.
> > 
> > Unless the NFS server has an explicit fsid=0 export with the
> > "security_label" option, the NFSv4 root superblock will not have
> > SBLABEL_MNT set, and neither will the submount superblock after
> > cloning
> > the security mount options.  As a result, setxattr's of security
> > labels
> > over NFSv4.2 will fail.  In a similar fashion, NFSv4.2 mounts mounted
> > with the context= mount option will not show the correct labels
> > because
> > the nfs_server->caps flags of the cloned superblock will still have
> > NFS_CAP_SECURITY_LABEL set.
> > 
> > Allowing the NFSv4 client to enable or disable
> > SECURITY_LSM_NATIVE_LABELS
> > behavior will ensure that the SBLABEL_MNT flag has the correct value
> > when the client traverses from an exported path without the
> > "security_label" option to one with the "security_label" option and
> > vice versa.  Similarly, checking to see if SECURITY_LSM_NATIVE_LABELS
> > is
> > set upon return from security_sb_clone_mnt_opts() and clearing
> > NFS_CAP_SECURITY_LABEL if necessary will allow the correct labels to
> > be displayed for NFSv4.2 mounts mounted with the context= mount
> > option.
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfs/super.c            | 18 +++++++++++++++++-
> >  include/linux/lsm_hooks.h |  4 +++-
> >  include/linux/security.h  |  8 ++++++--
> >  security/security.c       |  7 +++++--
> >  security/selinux/hooks.c  | 35 +++++++++++++++++++++++++++++++++--
> >  5 files changed, 64 insertions(+), 8 deletions(-)
> 
> What tree is this against? Doesn't apply cleanly on selinux #next.

It's against Linus' mainline tree.
> 
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 2f3822a..ffded39 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -2544,10 +2544,26 @@ EXPORT_SYMBOL_GPL(nfs_set_sb_security);
> >  int nfs_clone_sb_security(struct super_block *s, struct dentry
> > *mntroot,
> >  			  struct nfs_mount_info *mount_info)
> >  {
> > +	int error;
> > +	unsigned long kflags = 0, kflags_out = 0;
> > +
> >  	/* clone any lsm security options from the parent to the new
> > sb */
> >  	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client-
> > >rpc_ops->dir_inode_ops)
> >  		return -ESTALE;
> > -	return security_sb_clone_mnt_opts(mount_info->cloned->sb,
> > s);
> > +
> > +	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
> > +		kflags |= SECURITY_LSM_NATIVE_LABELS;
> > +
> > +	error = security_sb_clone_mnt_opts(mount_info->cloned->sb,
> > s, kflags,
> > +			&kflags_out);
> > +	if (error)
> > +		return error;
> > +
> > +	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
> > +		!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
> > +		NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
> > +	return error;
> 
> This can just be return 0, right?

Yes.
> 
> > +
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
> >  
> > diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> > index 080f34e..2f54bfb 100644
> > --- a/include/linux/lsm_hooks.h
> > +++ b/include/linux/lsm_hooks.h
> > @@ -1388,7 +1388,9 @@ union security_list_options {
> >  				unsigned long kern_flags,
> >  				unsigned long *set_kern_flags);
> >  	int (*sb_clone_mnt_opts)(const struct super_block *oldsb,
> > -					struct super_block *newsb);
> > +					struct super_block *newsb,
> > +					unsigned long kern_flags,
> > +					unsigned long
> > *set_kern_flags);
> >  	int (*sb_parse_opts_str)(char *options, struct
> > security_mnt_opts *opts);
> >  	int (*dentry_init_security)(struct dentry *dentry, int mode,
> >  					const struct qstr *name,
> > void **ctx,
> > diff --git a/include/linux/security.h b/include/linux/security.h
> > index af675b5..a55ae9c 100644
> > --- a/include/linux/security.h
> > +++ b/include/linux/security.h
> > @@ -240,7 +240,9 @@ int security_sb_set_mnt_opts(struct super_block
> > *sb,
> >  				unsigned long kern_flags,
> >  				unsigned long *set_kern_flags);
> >  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -				struct super_block *newsb);
> > +				struct super_block *newsb,
> > +				unsigned long kern_flags,
> > +				unsigned long *set_kern_flags);
> >  int security_sb_parse_opts_str(char *options, struct
> > security_mnt_opts *opts);
> >  int security_dentry_init_security(struct dentry *dentry, int mode,
> >  					const struct qstr *name,
> > void **ctx,
> > @@ -581,7 +583,9 @@ static inline int security_sb_set_mnt_opts(struct
> > super_block *sb,
> >  }
> >  
> >  static inline int security_sb_clone_mnt_opts(const struct
> > super_block *oldsb,
> > -					      struct super_block
> > *newsb)
> > +					      struct super_block
> > *newsb,
> > +					      unsigned long
> > kern_flags,
> > +					      unsigned long
> > *set_kern_flags)
> >  {
> >  	return 0;
> >  }
> > diff --git a/security/security.c b/security/security.c
> > index b9fea39..7b70ea2 100644
> > --- a/security/security.c
> > +++ b/security/security.c
> > @@ -380,9 +380,12 @@ int security_sb_set_mnt_opts(struct super_block
> > *sb,
> >  EXPORT_SYMBOL(security_sb_set_mnt_opts);
> >  
> >  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -				struct super_block *newsb)
> > +				struct super_block *newsb,
> > +				unsigned long kern_flags,
> > +				unsigned long *set_kern_flags)
> >  {
> > -	return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb);
> > +	return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb,
> > +				kern_flags, set_kern_flags);
> >  }
> >  EXPORT_SYMBOL(security_sb_clone_mnt_opts);
> >  
> > diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> > index e67a526..d8d5d35 100644
> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -529,8 +529,16 @@ static int sb_finish_set_opts(struct super_block
> > *sb)
> >  		       sb->s_id, sb->s_type->name);
> >  
> >  	sbsec->flags |= SE_SBINITIALIZED;
> > +
> > +	/*
> > +	 * Explicitly set or clear SBLABEL_MNT.  It's not sufficient
> > to simply
> > +	 * leave the flag untouched because sb_clone_mnt_opts might
> > be handing
> > +	 * us a superblock that needs the flag to be cleared.
> > +	 */
> >  	if (selinux_is_sblabel_mnt(sb))
> >  		sbsec->flags |= SBLABEL_MNT;
> > +	else
> > +		sbsec->flags &= ~SBLABEL_MNT;
> >  
> >  	/* Initialize the root inode. */
> >  	rc = inode_doinit_with_dentry(root_inode, root);
> > @@ -963,8 +971,11 @@ static int selinux_cmp_sb_context(const struct
> > super_block *oldsb,
> >  }
> >  
> >  static int selinux_sb_clone_mnt_opts(const struct super_block
> > *oldsb,
> > -					struct super_block *newsb)
> > +					struct super_block *newsb,
> > +					unsigned long kern_flags,
> > +					unsigned long
> > *set_kern_flags)
> >  {
> > +	int rc = 0;
> >  	const struct superblock_security_struct *oldsbsec = oldsb-
> > >s_security;
> >  	struct superblock_security_struct *newsbsec = newsb-
> > >s_security;
> >  
> > @@ -979,6 +990,13 @@ static int selinux_sb_clone_mnt_opts(const
> > struct super_block *oldsb,
> >  	if (!ss_initialized)
> >  		return 0;
> >  
> > +	/*
> > +	 * Specifying internal flags without providing a place to
> > +	 * place the results is not allowed.
> > +	 */
> > +	if (kern_flags && !set_kern_flags)
> > +		return -EINVAL;
> > +
> >  	/* how can we clone if the old one wasn't set up?? */
> >  	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
> >  
> > @@ -994,6 +1012,18 @@ static int selinux_sb_clone_mnt_opts(const
> > struct super_block *oldsb,
> >  	newsbsec->def_sid = oldsbsec->def_sid;
> >  	newsbsec->behavior = oldsbsec->behavior;
> >  
> > +	if (newsbsec->behavior == SECURITY_FS_USE_NATIVE &&
> > +		!(kern_flags & SECURITY_LSM_NATIVE_LABELS) &&
> > !set_context) {
> > +		rc = security_fs_use(newsb);
> > +		if (rc)
> > +			goto out;
> > +	}
> > +
> > +	if (kern_flags & SECURITY_LSM_NATIVE_LABELS && !set_context)
> > {
> > +		newsbsec->behavior = SECURITY_FS_USE_NATIVE;
> > +		*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
> > +	}
> > +
> >  	if (set_context) {
> >  		u32 sid = oldsbsec->mntpoint_sid;
> >  
> > @@ -1013,8 +1043,9 @@ static int selinux_sb_clone_mnt_opts(const
> > struct super_block *oldsb,
> >  	}
> >  
> >  	sb_finish_set_opts(newsb);
> > +out:
> >  	mutex_unlock(&newsbsec->lock);
> > -	return 0;
> > +	return rc;
> >  }
> >  
> >  static int selinux_parse_opts_str(char *options,
