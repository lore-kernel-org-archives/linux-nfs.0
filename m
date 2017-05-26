Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from emsm-gh1-uea11.nsa.gov ([8.44.101.9]:33694 "EHLO
        emsm-gh1-uea11.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754118AbdEZPiX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 May 2017 11:38:23 -0400
Message-ID: <1495813358.4586.1.camel@tycho.nsa.gov>
Subject: Re: [PATCH RFC 2/2] nfs: update labeling behavior on a superblock
 when submounting
From: Stephen Smalley <sds@tycho.nsa.gov>
To: Scott Mayhew <smayhew@redhat.com>
Cc: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Fri, 26 May 2017 11:42:38 -0400
In-Reply-To: <20170526152821.xgyidg7qebdwbm6f@tonberry.usersys.redhat.com>
References: <20170404232646.GB24146@parsley.fieldses.org>
         <20170525210754.24265-1-smayhew@redhat.com>
         <20170525210754.24265-3-smayhew@redhat.com>
         <1495808645.12091.10.camel@tycho.nsa.gov>
         <20170526152821.xgyidg7qebdwbm6f@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-26 at 11:28 -0400, Scott Mayhew wrote:
> On Fri, 26 May 2017, Stephen Smalley wrote:
> 
> > On Thu, 2017-05-25 at 17:07 -0400, Scott Mayhew wrote:
> > > When the client traverses from filesystem exported without the
> > > "security_label" option to one exported with the "security_label"
> > > option, it needs to pass SECURITY_LSM_NATIVE_LABELS to
> > > security_sb_set_mnt_opts() so that the new superblock has
> > > SBLABEL_MNT
> > > set in its security mount options.  Otherwise, attempts to set
> > > security
> > > labels via setxattr over NFSv4.2 will fail.
> > > 
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfs/super.c | 23 ++++++++++++++++++++++-
> > >  1 file changed, 22 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > > index 2f3822a..d7a3b89 100644
> > > --- a/fs/nfs/super.c
> > > +++ b/fs/nfs/super.c
> > > @@ -2544,10 +2544,31 @@ EXPORT_SYMBOL_GPL(nfs_set_sb_security);
> > >  int nfs_clone_sb_security(struct super_block *s, struct dentry
> > > *mntroot,
> > >  			  struct nfs_mount_info *mount_info)
> > >  {
> > > +	int error;
> > > +	unsigned long kflags = 0, kflags_out = 0;
> > > +	struct security_mnt_opts opts;
> > > +
> > >  	/* clone any lsm security options from the parent to the
> > > new
> > > sb */
> > >  	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client-
> > > > rpc_ops->dir_inode_ops)
> > > 
> > >  		return -ESTALE;
> > > -	return security_sb_clone_mnt_opts(mount_info->cloned-
> > > >sb,
> > > s);
> > > +	error = security_sb_clone_mnt_opts(mount_info->cloned-
> > > >sb,
> > > s);
> > > +	if (error)
> > > +		goto err;
> > > +
> > > +	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
> > > +		!(NFS_SB(mount_info->cloned->sb)->caps &
> > > NFS_CAP_SECURITY_LABEL)) {
> > > +		memset(&opts, 0, sizeof(opts));
> > > +		kflags |= SECURITY_LSM_NATIVE_LABELS;
> > > +
> > > +		error = security_sb_set_mnt_opts(s, &opts,
> > > kflags,
> > > &kflags_out);
> > > +		if (error)
> > > +			goto err;
> > > +
> > > +		if (!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
> > > +			NFS_SB(s)->caps &=
> > > ~NFS_CAP_SECURITY_LABEL;
> > > +	}
> > > +err:
> > > +	return error;
> > >  }
> > >  EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
> > 
> > Could this clobber a context set via context= mount option?
> 
> Argh, yes I suppose it could.  In my first attempt to fix this, I
> added
> a security_sb_get_mnt_opts() hook to get the original mount options
> and
> then passed that along with the SECURITY_LSM_NATIVE_LABELS flag to
> security_sb_set_mnt_opts().  When I saw that
> security_sb_set_mnt_opts()
> wouldn't allow me to change a superblock that had already been
> initialized, I got rid of the hook and added the check in patch 1...
> maybe a combination of the two is needed?

Could we instead extend the security_sb_clone_mnt_opts() hook interface
to pass flags, and just handle it inside of the
selinux_sb_clone_mnt_opts() hook?  Then we don't have to change
selinux_sb_set_mnt_opts() handling, which may be called for mount(2)
from userspace, not just from NFS client code.  You might need to
refactor it to share common code, but we shouldn't alter its logic when
called normally.


> Testing it again now, I'm not sure the context= mount option is
> working
> correctly with the latest kernel.

Hmm...if not, then that's another regression that will need to be
addressed.
