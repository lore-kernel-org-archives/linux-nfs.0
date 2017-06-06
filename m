Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33756 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdFFAqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Jun 2017 20:46:38 -0400
Date: Mon, 5 Jun 2017 20:46:37 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Paul Moore <paul@paul-moore.com>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@primarydata.com>,
        selinux@tycho.nsa.gov, Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@parisplace.org>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: [PATCH v3] security/selinux: allow security_sb_clone_mnt_opts to
 enable/disable native labeling behavior
Message-ID: <20170606004637.GC5789@fieldses.org>
References: <20170602130918.gu22wnbd35idaurf@tonberry.usersys.redhat.com>
 <20170605154504.3659-1-smayhew@redhat.com>
 <CAHC9VhTpcZXB=9SRLHu+8Ot=ydyszc0+Qe044uVzPz8ndx4ukA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHC9VhTpcZXB=9SRLHu+8Ot=ydyszc0+Qe044uVzPz8ndx4ukA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 05, 2017 at 05:21:55PM -0400, Paul Moore wrote:
> On Mon, Jun 5, 2017 at 11:45 AM, Scott Mayhew <smayhew@redhat.com> wrote:
> > When an NFSv4 client performs a mount operation, it first mounts the
> > NFSv4 root and then does path walk to the exported path and performs a
> > submount on that, cloning the security mount options from the root's
> > superblock to the submount's superblock in the process.
> >
> > Unless the NFS server has an explicit fsid=0 export with the
> > "security_label" option, the NFSv4 root superblock will not have
> > SBLABEL_MNT set, and neither will the submount superblock after cloning
> > the security mount options.  As a result, setxattr's of security labels
> > over NFSv4.2 will fail.  In a similar fashion, NFSv4.2 mounts mounted
> > with the context= mount option will not show the correct labels because
> > the nfs_server->caps flags of the cloned superblock will still have
> > NFS_CAP_SECURITY_LABEL set.
> >
> > Allowing the NFSv4 client to enable or disable SECURITY_LSM_NATIVE_LABELS
> > behavior will ensure that the SBLABEL_MNT flag has the correct value
> > when the client traverses from an exported path without the
> > "security_label" option to one with the "security_label" option and
> > vice versa.  Similarly, checking to see if SECURITY_LSM_NATIVE_LABELS is
> > set upon return from security_sb_clone_mnt_opts() and clearing
> > NFS_CAP_SECURITY_LABEL if necessary will allow the correct labels to
> > be displayed for NFSv4.2 mounts mounted with the context= mount option.
> >
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfs/super.c            | 17 ++++++++++++++++-
> >  include/linux/lsm_hooks.h |  4 +++-
> >  include/linux/security.h  |  8 ++++++--
> >  security/security.c       |  7 +++++--
> >  security/selinux/hooks.c  | 35 +++++++++++++++++++++++++++++++++--
> >  5 files changed, 63 insertions(+), 8 deletions(-)
> 
> Thanks for sorting this out Scott and Stephen.
> 
> NFS folks, any objections to this patch?  If not, I'd like to pull
> this into the SELinux tree but I'd like to have an ACK from you before
> I do.

Looks OK to me, but I think it's Trond or Anna (added to cc) that you
want the ACK from.

--b.

> 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 2f3822a..b8e0735 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -2544,10 +2544,25 @@ EXPORT_SYMBOL_GPL(nfs_set_sb_security);
> >  int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
> >                           struct nfs_mount_info *mount_info)
> >  {
> > +       int error;
> > +       unsigned long kflags = 0, kflags_out = 0;
> > +
> >         /* clone any lsm security options from the parent to the new sb */
> >         if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
> >                 return -ESTALE;
> > -       return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
> > +
> > +       if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
> > +               kflags |= SECURITY_LSM_NATIVE_LABELS;
> > +
> > +       error = security_sb_clone_mnt_opts(mount_info->cloned->sb, s, kflags,
> > +                       &kflags_out);
> > +       if (error)
> > +               return error;
> > +
> > +       if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
> > +               !(kflags_out & SECURITY_LSM_NATIVE_LABELS))
> > +               NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
> > +       return 0;
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
> >
> > diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> > index 68d91e4..3cc9d77 100644
> > --- a/include/linux/lsm_hooks.h
> > +++ b/include/linux/lsm_hooks.h
> > @@ -1409,7 +1409,9 @@ union security_list_options {
> >                                 unsigned long kern_flags,
> >                                 unsigned long *set_kern_flags);
> >         int (*sb_clone_mnt_opts)(const struct super_block *oldsb,
> > -                                       struct super_block *newsb);
> > +                                       struct super_block *newsb,
> > +                                       unsigned long kern_flags,
> > +                                       unsigned long *set_kern_flags);
> >         int (*sb_parse_opts_str)(char *options, struct security_mnt_opts *opts);
> >         int (*dentry_init_security)(struct dentry *dentry, int mode,
> >                                         const struct qstr *name, void **ctx,
> > diff --git a/include/linux/security.h b/include/linux/security.h
> > index 549cb82..b44e954 100644
> > --- a/include/linux/security.h
> > +++ b/include/linux/security.h
> > @@ -249,7 +249,9 @@ int security_sb_set_mnt_opts(struct super_block *sb,
> >                                 unsigned long kern_flags,
> >                                 unsigned long *set_kern_flags);
> >  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -                               struct super_block *newsb);
> > +                               struct super_block *newsb,
> > +                               unsigned long kern_flags,
> > +                               unsigned long *set_kern_flags);
> >  int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
> >  int security_dentry_init_security(struct dentry *dentry, int mode,
> >                                         const struct qstr *name, void **ctx,
> > @@ -605,7 +607,9 @@ static inline int security_sb_set_mnt_opts(struct super_block *sb,
> >  }
> >
> >  static inline int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -                                             struct super_block *newsb)
> > +                                             struct super_block *newsb,
> > +                                             unsigned long kern_flags,
> > +                                             unsigned long *set_kern_flags)
> >  {
> >         return 0;
> >  }
> > diff --git a/security/security.c b/security/security.c
> > index 714433e..3013237 100644
> > --- a/security/security.c
> > +++ b/security/security.c
> > @@ -420,9 +420,12 @@ int security_sb_set_mnt_opts(struct super_block *sb,
> >  EXPORT_SYMBOL(security_sb_set_mnt_opts);
> >
> >  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -                               struct super_block *newsb)
> > +                               struct super_block *newsb,
> > +                               unsigned long kern_flags,
> > +                               unsigned long *set_kern_flags)
> >  {
> > -       return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb);
> > +       return call_int_hook(sb_clone_mnt_opts, 0, oldsb, newsb,
> > +                               kern_flags, set_kern_flags);
> >  }
> >  EXPORT_SYMBOL(security_sb_clone_mnt_opts);
> >
> > diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> > index 9926adb..9cc042d 100644
> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -525,8 +525,16 @@ static int sb_finish_set_opts(struct super_block *sb)
> >         }
> >
> >         sbsec->flags |= SE_SBINITIALIZED;
> > +
> > +       /*
> > +        * Explicitly set or clear SBLABEL_MNT.  It's not sufficient to simply
> > +        * leave the flag untouched because sb_clone_mnt_opts might be handing
> > +        * us a superblock that needs the flag to be cleared.
> > +        */
> >         if (selinux_is_sblabel_mnt(sb))
> >                 sbsec->flags |= SBLABEL_MNT;
> > +       else
> > +               sbsec->flags &= ~SBLABEL_MNT;
> >
> >         /* Initialize the root inode. */
> >         rc = inode_doinit_with_dentry(root_inode, root);
> > @@ -959,8 +967,11 @@ static int selinux_cmp_sb_context(const struct super_block *oldsb,
> >  }
> >
> >  static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> > -                                       struct super_block *newsb)
> > +                                       struct super_block *newsb,
> > +                                       unsigned long kern_flags,
> > +                                       unsigned long *set_kern_flags)
> >  {
> > +       int rc = 0;
> >         const struct superblock_security_struct *oldsbsec = oldsb->s_security;
> >         struct superblock_security_struct *newsbsec = newsb->s_security;
> >
> > @@ -975,6 +986,13 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> >         if (!ss_initialized)
> >                 return 0;
> >
> > +       /*
> > +        * Specifying internal flags without providing a place to
> > +        * place the results is not allowed.
> > +        */
> > +       if (kern_flags && !set_kern_flags)
> > +               return -EINVAL;
> > +
> >         /* how can we clone if the old one wasn't set up?? */
> >         BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
> >
> > @@ -990,6 +1008,18 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> >         newsbsec->def_sid = oldsbsec->def_sid;
> >         newsbsec->behavior = oldsbsec->behavior;
> >
> > +       if (newsbsec->behavior == SECURITY_FS_USE_NATIVE &&
> > +               !(kern_flags & SECURITY_LSM_NATIVE_LABELS) && !set_context) {
> > +               rc = security_fs_use(newsb);
> > +               if (rc)
> > +                       goto out;
> > +       }
> > +
> > +       if (kern_flags & SECURITY_LSM_NATIVE_LABELS && !set_context) {
> > +               newsbsec->behavior = SECURITY_FS_USE_NATIVE;
> > +               *set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
> > +       }
> > +
> >         if (set_context) {
> >                 u32 sid = oldsbsec->mntpoint_sid;
> >
> > @@ -1009,8 +1039,9 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> >         }
> >
> >         sb_finish_set_opts(newsb);
> > +out:
> >         mutex_unlock(&newsbsec->lock);
> > -       return 0;
> > +       return rc;
> >  }
> >
> >  static int selinux_parse_opts_str(char *options,
> > --
> > 2.9.3
> >
> 
> 
> 
> -- 
> paul moore
> www.paul-moore.com
