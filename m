Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34435 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab2IFNdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 09:33:04 -0400
Date: Thu, 6 Sep 2012 09:33:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [RFC PATCH 12/13] locks: break delegations on link
Message-ID: <20120906133300.GA13054@fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-13-git-send-email-bfields@redhat.com>
 <20120905210206.GB10724@fieldses.org>
 <20120906070122.58c21013@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120906070122.58c21013@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 06, 2012 at 07:01:22AM -0400, Jeff Layton wrote:
> On Wed, 5 Sep 2012 17:02:06 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Oops, I meant to cc this to Jeff:
> > 
> > On Wed, Sep 05, 2012 at 04:55:22PM -0400, J. Bruce Fields wrote:
> > > @@ -3556,6 +3560,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
> > >  	if (error)
> > >  		return error;
> > >  
> > > +retry_deleg:
> > >  	new_dentry = user_path_create(newdfd, newname, &new_path, 0);
> > >  	error = PTR_ERR(new_dentry);
> > >  	if (IS_ERR(new_dentry))
> > > @@ -3570,9 +3575,14 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
> > >  	error = security_path_link(old_path.dentry, &new_path, new_dentry);
> > >  	if (error)
> > >  		goto out_dput;
> > > -	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry);
> > > +	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
> > >  out_dput:
> > >  	done_path_create(&new_path, new_dentry);
> > > +	if (delegated_inode) {
> > > +		error = break_deleg_wait(&delegated_inode);
> > > +		if (!error)
> > > +			goto retry_deleg;
> > > +	}
> > >  out:
> > >  	path_put(&old_path);
> > >  
> > 
> > I think this will get me into trouble with the audit code, right?
> > 
> > (On a quick skim I think I'm retrying from a point after the getname()
> > in rename and unlink, so I think those are OK, but I may be missing
> > something....)
> > 
> > --b.
> > 
> 
> tl;dr: this patch is OK, but the unlink and rename patches will be
> problematic.
> 
> Longer explanation:
> 
> The big problem is multiple calls into audit_inode_child(), which will
> give you duplicate audit records when you retry the call. That function
> mostly gets called from the fsnotify_* calls, but is also called from
> may_delete().
> 
> In the create case (like this one), you're safe since we only call
> fsnotify_* after the create succeeds. In the may_delete() case, we have
> to call that function before the actual operation. A quick look at your
> patches looks like you'll end up with multiple calls into may_delete on
> a retry. That'll give you multiple audit records for each.
> 
> The good news is that if and when my audit_names overhaul patches go
> in, that problem should go away. At that point audit_inode_child() will
> know how to update existing records instead of creating new ones in
> this case. I'm hoping those will go in for 3.7, so you may just want to
> try to ensure that these patches go in after those.

OK, thanks for the explanation, I'll keep an eye on the audit_names
overhaul.

--b.

> 
> > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > index c8f5e74..2a77b28 100644
> > > --- a/fs/nfsd/vfs.c
> > > +++ b/fs/nfsd/vfs.c
> > > @@ -1717,7 +1717,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
> > >  		err = nfserrno(host_err);
> > >  		goto out_dput;
> > >  	}
> > > -	host_err = vfs_link(dold, dirp, dnew);
> > > +	host_err = vfs_link(dold, dirp, dnew, NULL);
> > >  	if (!host_err) {
> > >  		err = nfserrno(commit_metadata(ffhp));
> > >  		if (!err)
> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > index ad9df65e..52b8c67 100644
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -1721,7 +1721,7 @@ extern int vfs_create(struct inode *, struct dentry *, umode_t, bool);
> > >  extern int vfs_mkdir(struct inode *, struct dentry *, umode_t);
> > >  extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
> > >  extern int vfs_symlink(struct inode *, struct dentry *, const char *);
> > > -extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
> > > +extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
> > >  extern int vfs_rmdir(struct inode *, struct dentry *);
> > >  extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
> > >  extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
> > > -- 
> > > 1.7.9.5
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
