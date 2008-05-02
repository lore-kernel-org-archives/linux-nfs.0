From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Fri, 2 May 2008 18:12:16 -0400
Message-ID: <20080502221216.GP21918@fieldses.org>
References: <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de> <18454.45086.254692.412079@notabene.brown> <20080429163554.GE20420@fieldses.org> <20080429174004.GA28719@janus> <20080430174736.GB20377@fieldses.org> <20080502151646.GA5515@janus> <20080502153439.GC7376@infradead.org> <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59866 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbYEBWM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 18:12:28 -0400
In-Reply-To: <1209744293.8294.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 12:04:53PM -0400, Trond Myklebust wrote:
> 
> On Fri, 2008-05-02 at 11:56 -0400, J. Bruce Fields wrote:
> > On Fri, May 02, 2008 at 11:34:39AM -0400, Christoph Hellwig wrote:
> > > On Fri, May 02, 2008 at 05:16:46PM +0200, Frank van Maarseveen wrote:
> > > > A privileged process on an NFS client which drops privileges after using
> > > > them to change the current working directory, will experience incorrect
> > > > EACCES after an NFS server reboot. This problem can also occur after
> > > > memory pressure on the server, particularly when the client side is
> > > > quiet for some time.
> > > > 
> > > > This patch removes the x-bit check during dentry tree reconstruction at
> > > > the server by exportfs on behalf of nfsd.
> > > 
> > > I'm still against adding this crap,
> > 
> > The only statements I've seen against the change so far have been of the
> > form "you should not do that", without explaining why not.
> > 
> > It's entirely possible that you're right, but I need some argument.
> 
> 
> AFAICS, the real problem here is that nfsd is dropping its privileged
> mode too early. Why can't you call reconnect_path() using nfsd's root
> permissions instead of dropping permissions checks altogether?

That's an interesting idea.

As I understand it, nfsd sets the current task's credentials only once,
in nfsd_setuser, called from fh_verify().  The change lingers around
until next time we do fh_verify().  So in addition to moving the
nfsd_setuser() call to after the lookup of the dentry (so after
exportfs_decode_fh(), we'd also need to add an explicit acquisition of
whatever permissions we need before we do that lookup.

--b.

> 
> > > and even when I get overruled that
> > > doesn't make the comments on lookup_one_noperm any less true,
> > 
> > We do need to at least update it to reflect the addition of a new
> > caller.
> > 
> > > not does it give you a permit to break the kerneldoc generation.
> > 
> > Oops; here's a version that should make kerneldoc happy.  It also adds a
> > little more explanation, and leaves alone the editorializing on sysfs
> > (on which I have no opinion).
> > 
> > --b.
> > 
> > commit ccdfe77dc49a07c298bb9e2107290267492f16b3
> > Author: Frank van Maarseveen <frankvm@frankvm.com>
> > Date:   Fri May 2 17:16:46 2008 +0200
> > 
> >     exportfs: fix incorrect EACCES in reconnect_path()
> >     
> >     A privileged process on an NFS client which drops privileges after using
> >     them to change the current working directory, will experience incorrect
> >     EACCES after an NFS server reboot. This problem can also occur after
> >     memory pressure on the server, particularly when the client side is
> >     quiet for some time.
> >     
> >     This patch removes the x-bit check during dentry tree reconstruction at
> >     the server by exportfs on behalf of nfsd.
> >     
> >     Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
> >     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> > index 109ab5e..89dc7ae 100644
> > --- a/fs/exportfs/expfs.c
> > +++ b/fs/exportfs/expfs.c
> > @@ -170,7 +170,7 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir)
> >  			}
> >  			dprintk("%s: found name: %s\n", __FUNCTION__, nbuf);
> >  			mutex_lock(&ppd->d_inode->i_mutex);
> > -			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
> > +			npd = lookup_one_noperm(nbuf, ppd);
> >  			mutex_unlock(&ppd->d_inode->i_mutex);
> >  			if (IS_ERR(npd)) {
> >  				err = PTR_ERR(npd);
> > @@ -447,8 +447,7 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
> >  		err = exportfs_get_name(mnt, target_dir, nbuf, result);
> >  		if (!err) {
> >  			mutex_lock(&target_dir->d_inode->i_mutex);
> > -			nresult = lookup_one_len(nbuf, target_dir,
> > -						 strlen(nbuf));
> > +			nresult = lookup_one_noperm(nbuf, target_dir);
> >  			mutex_unlock(&target_dir->d_inode->i_mutex);
> >  			if (!IS_ERR(nresult)) {
> >  				if (nresult->d_inode) {
> > diff --git a/fs/namei.c b/fs/namei.c
> > index e179f71..c00150c 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -1391,7 +1391,7 @@ struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
> >  }
> >  
> >  /**
> > - * lookup_one_noperm - bad hack for sysfs
> > + * lookup_one_noperm - bad hack for sysfs and nfsd
> >   * @name:	pathname component to lookup
> >   * @base:	base directory to lookup from
> >   *
> > @@ -1399,7 +1399,12 @@ struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
> >   * checks.   It's a horrible hack to work around the braindead sysfs
> >   * architecture and should not be used anywhere else.
> >   *
> > - * DON'T USE THIS FUNCTION EVER, thanks.
> > + * It is also used by nfsd via exports to reconstruct the dentry tree
> > + * for directory handles (e.g. when a client requests a directory by
> > + * filehandle after a server reboot has cleared the dentry cache of that
> > + * directory's parents).
> > + *
> > + * DON'T USE THIS FUNCTION ANYWHERE ELSE, thanks.
> >   */
> >  struct dentry *lookup_one_noperm(const char *name, struct dentry *base)
> >  {
> 
> How about if exportfs is compiled as a module?
> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
