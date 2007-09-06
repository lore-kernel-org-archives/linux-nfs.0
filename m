From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] 1/2 SELinux: Add get, set,
	and cloning of superblock	security information
Date: Thu, 06 Sep 2007 15:59:06 -0400
Message-ID: <1189108746.3617.200.camel@moss-spartans.epoch.ncsc.mil>
References: <1189030563.3460.41.camel@dhcp231-215.rdu.redhat.com>
	<1189103609.3617.169.camel@moss-spartans.epoch.ncsc.mil>
	<1189106507.3418.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov, steved@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITNXo-00070l-Rb
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 13:01:40 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITNXr-00089U-CL
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 13:01:43 -0700
In-Reply-To: <1189106507.3418.66.camel@localhost.localdomain>
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

On Thu, 2007-09-06 at 15:21 -0400, Eric Paris wrote:
> On Thu, 2007-09-06 at 14:33 -0400, Stephen Smalley wrote:
> > On Wed, 2007-09-05 at 18:16 -0400, Eric Paris wrote:
> > > Adds security_get_sb_mnt_opts, security_set_sb_mnt_opts, and
> > > security_clont_sb_mnt_opts to the LSM and to SELinux.  This is in
> > > preparation for NFS to be able to own its own mount options and remove
> > > the NFS specific code from SELinux.
> > > 
> > > >From the point of view of SELinux NFS does not use text based mount
> > > options so this patch is not something that is going away.  NFS merely
> > > takes the text options from userspace and puts them into the same binary
> > > format as always and passes that binary mount data around.
> > > 
> > > Signed-off-by: Eric Paris <eparis@redhat.com>
> > > 
> > > ---
> > > 
> > >  include/linux/security.h          |   70 +++++
> > >  security/dummy.c                  |   26 ++
> > >  security/selinux/hooks.c          |  618 ++++++++++++++++++++++++-------------
> > >  security/selinux/include/objsec.h |    1 +
> > >  4 files changed, 505 insertions(+), 210 deletions(-)
> > 
> > Not a very nice diff to read.
> 
> I couldn't think of a great way to make it smaller.  I certainly
> understand....
> 
> > 
> > > diff --git a/include/linux/security.h b/include/linux/security.h
> 
> > > +static inline int security_sb_set_mnt_opts (struct super_block *sb,
> > > +					    char **mount_options,
> > > +					    int *flags, int num_opts)
> > > +{
> > > +	return 0;
> > > +}
> > 
> > For consistency, this should likely do the same thing as the dummy
> > function, i.e. return -EOPNOTSUPP if num_opts > 0.  Actually, is this
> > going to get called at all unless num_opts is > 0?
> 
> EOPNOTSUPP seems like the right thing.  selinux=0 and mount nfs with
> context=
> 
> > 
> > > diff --git a/security/dummy.c b/security/dummy.c
> 
> > > +static int dummy_sb_set_mnt_opts(struct super_block *sb, char **mount_options,
> > > +				 int *flags, int num_opts)
> > > +{
> > > +	if (unlikely(num_opts))
> > > +		return -EOPNOTSUPP;
> > > +	return 0;
> > > +}
> > 
> > Possibly just unconditionally return -EOPNOTSUPP, as the hook wouldn't
> > normally get called with no options.
> 
> I'd rather not rely on the FS to have to follow this convention.  Its
> written so that num_opts=0 will work fine.
> > 
> > > diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> > > index 3694662..5ebe30b 100644
> > > --- a/security/selinux/hooks.c
> > > +++ b/security/selinux/hooks.c
> > > @@ -362,135 +362,228 @@ static int may_context_mount_inode_relabel(u32 sid,
> > >  	return rc;
> > >  }
> > >  
> > > -static int try_context_mount(struct super_block *sb, void *data)
> > > +static int sb_finish_set_opts(struct super_block *sb)
> > >  {
> > > -	char *context = NULL, *defcontext = NULL;
> > > -	char *fscontext = NULL, *rootcontext = NULL;
> > > -	const char *name;
> > > -	u32 sid;
> > > -	int alloc = 0, rc = 0, seen = 0;
> > > -	struct task_security_struct *tsec = current->security;
> > >  	struct superblock_security_struct *sbsec = sb->s_security;
> > > +	struct dentry *root = sb->s_root;
> > > +	struct inode *root_inode = root->d_inode;
> > > +	int rc = 0;
> > >  
> > > -	if (!data)
> > > -		goto out;
> > > +	BUG_ON(!ss_initialized);
> > 
> > Why BUG_ON vs. return error?  context mount before initial policy load
> > is technically possible, even more so if booting permissive and policy
> > is corrupted.
> 
> How should your example case be handled?  we can't store that context
> information for later.

Error code.

>   The only way we get here is through a direct
> caller to set or clone from the FS since normally we would come through
> superblock_doinit->try_context_mount->set_sb...->here and ss_initialized
> would already have been taken care of.  Should I just dump the
> superblock on the list to deal with later and not worry that I was given
> mount options (doesn't seem like we have a good solution to your problem
> now)?
> 
> I like an error code better, what fits?  It should be dealt with in
> selinux_set_mnt_opts/sb_doinit and not here.  But still the question
> remains.

-EOPNOTSUPP or -EINVAL.  Possibly with a printk.

> > 
> > >  
> > > -	name = sb->s_type->name;
> > > +	if (sbsec->initialized)
> > > +		return 0;
> > 
> > Under what conditions would we reach this point if sbsec was already
> > initialized?  Should it be an error?  A bug?
> 
> We can't.  it is caught in both superblock_doinit and
> selinux_set_sb_mnt_opts.

So BUG_ON?  Or drop it.

> > > +static int try_context_mount(struct super_block *sb, void *data)
> > > +{
> > > +	char *context = NULL, *defcontext = NULL;
> > > +	char *fscontext = NULL, *rootcontext = NULL;
> > > +	int rc = 0;
> > > +	char *p, *options = data;
> > > +	/* selinux only know about 4 mount options */
> > > +	char *mnt_opts[4];
> > > +	int mnt_opts_flags[4], num_mnt_opts = 0;
> > 
> > Can we #define that once and use it?
> 
> the variable declarations?  I guess I could.  They aren't used in many
> other places, but having [4] randomly in the code is probably not the
> best idea.

Yes, I just meant replacing 4 with a #define'd symbol.

> > >  
> > > +/* 
> > > + * no locking done here, but it shouldn't matter, sbsec->proc would just get
> > > + * set the same way in another thread and fs_use, hmmmmmm 
> > > + */
> > 
> > Not sure I follow; you do take the lock still in set_mnts_opts before
> > doing the above AFAICS.  sbsec->list though is another matter.
> 
> comment doesn't belong.  I wasn't taking it and was still setting ->proc
> here but realized it was a stupid idea.  Never removed the comment.

Ok, but sbsec->list might still be an issue technically even if not in
practice.  There is a global spinlock on the whole list, but you could
end up adding the superblock twice if you don't take the sbsec lock.

> > 
> > >  static int superblock_doinit(struct super_block *sb, void *data)
> > >  {
> > >  	struct superblock_security_struct *sbsec = sb->s_security;
> > > -	struct dentry *root = sb->s_root;
> > > -	struct inode *inode = root->d_inode;
> > >  	int rc = 0;
> > >  
> > > -	mutex_lock(&sbsec->lock);
> > >  	if (sbsec->initialized)
> > >  		goto out;
> > 
> > One of the things that needs to be fixed is handling of a context mount
> > option when the superblock has previously been setup.  At present (and
> > still true of your patch), if one mounts /home/eparis with one context
> > mount and then tries to mount /home/sds with a different context mount,
> > the latter proceeds with no indication that the context mount option was
> > ignored (because we immediately return with success if already
> > initialized, and they'll end up with the same superblock if they are
> > from the same filesystem).  So we need to at least check to see if data
> > is set and return an error if sbsec is already initialized so that
> > userspace gets an indication of the fact.
> 
> I pointed out where I think we need to do this, but what kind of error
> do we want to return?  Do we actually want the mount command to fail?

-EINVAL with a printk.  Yes, we want the mount to fail there, because
the user asked for a particular context mount and the kernel can't honor
the request.  The user is always free to then do a regular mount if he
is ok with that.

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
