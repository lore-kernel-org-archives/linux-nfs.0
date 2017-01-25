Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34714 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdAYQ2O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2017 11:28:14 -0500
Received: by mail-io0-f177.google.com with SMTP id l66so17625893ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2017 08:28:13 -0800 (PST)
Date: Wed, 25 Jan 2017 10:28:11 -0600
From: Seth Forshee <seth.forshee@canonical.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "ebiederm@xmission.com" <ebiederm@xmission.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        Steve French <sfrench@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc
 credentials
Message-ID: <20170125162811.GC51023@ubuntu-hedt>
References: <20170110145504.GH52661@ubuntu-hedt>
 <87ziiyfntm.fsf@xmission.com>
 <20170124151745.GA114560@ubuntu-hedt>
 <87efzsdq5b.fsf@xmission.com>
 <87inp4rqaj.fsf@xmission.com>
 <1485301593.36478.2.camel@primarydata.com>
 <87y3y0ko5s.fsf@xmission.com>
 <1485303265.36478.7.camel@primarydata.com>
 <20170125145251.GB51023@ubuntu-hedt>
 <1485359474.113155.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1485359474.113155.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2017 at 03:51:30PM +0000, Trond Myklebust wrote:
> On Wed, 2017-01-25 at 08:52 -0600, Seth Forshee wrote:
> > On Wed, Jan 25, 2017 at 12:14:26AM +0000, Trond Myklebust wrote:
> > > Adding David Howells and Steve French as I believe both AFS and
> > > CIFS
> > > have the exact same requirements and NFS here.
> > > 
> > > On Wed, 2017-01-25 at 12:56 +1300, Eric W. Biederman wrote:
> > > > Trond Myklebust <trondmy@primarydata.com> writes:
> > > > 
> > > > > On Wed, 2017-01-25 at 12:28 +1300, Eric W. Biederman wrote:
> > > > > > With respect to nfs and automounts.
> > > > > > 
> > > > > > Does NFS have different automount behavior based on the user
> > > > > > performing the automount?
> > > > > > 
> > > > > > If NFS does not have different automount behavior depending
> > > > > > on
> > > > > > the
> > > > > > user
> > > > > > we just use the creds of the original mounter of NFS?
> > > > > > 
> > > > > > If NFS does have different automount behavior depending on
> > > > > > the
> > > > > > user
> > > > > > (ouch!) we need to go through the call path and see where it
> > > > > > makes
> > > > > > sense to over ride things and where it does not.
> > > > > 
> > > > > The reason why the NFS client creates a mountpoint is because
> > > > > on
> > > > > entering a directory, it detects that there is either a similar
> > > > > mountpoint on the server, or there is a referral (which acts
> > > > > sort
> > > > > of
> > > > > like a symlink, except it points to a path on one or more
> > > > > different
> > > > > NFS
> > > > > servers).
> > > > > Without that mountpoint, most things would work, but the user
> > > > > would
> > > > > end
> > > > > up seeing nasty non-posix features like duplicate inode
> > > > > numbers.
> > > > > 
> > > > > We do not want to use any creds other than user creds here,
> > > > > because
> > > > > as
> > > > > far as the security model is concerned, the process is just
> > > > > crossing
> > > > > into an existing directory.
> > > > 
> > > > But sget needs different creds.
> > > > 
> > > > Because the user who authorizes the mounting of the filesystem is
> > > > different than the user who is crossing into the new filesystem.
> > > > 
> > > > The local system now cares about that distinction even if the nfs
> > > > server
> > > > does not.
> > > 
> > > Why? The filesystem is already mounted. We're creating a new
> > > mountpoint, but we could equally well just say 'sod that' and
> > > create an
> > > ordinary directory. The penalty would be aforementioned non-posix
> > > weirdness.
> > > 
> > > > 
> > > > > > Seth the fundamental problem with your patch was that you
> > > > > > were
> > > > > > patching
> > > > > > a location that is used for more just mounts.
> > > > > > 
> > > > > > I am strongly wishing that we could just change
> > > > > > follow_automount
> > > > > > from:
> > > > > > 
> > > > > > 
> > > > > > 	old_cred = override_creds(&init_cred);
> > > > > > 	mnt = path->dentry->d_op->d_automount(path);
> > > > > > 	revert_creds(old_cred);
> > > > > > 
> > > > > > to:
> > > > > > 
> > > > > > 	old_cred = override_creds(path->mnt->mnt_sb->s_cred);
> > > > > > 	mnt = path->dentry->d_op->d_automount(path);
> > > > > > 	revert_creds(old_cred);
> > > > > > 
> > > > > > And all will be well with nfs.  That does remain possible.
> > > > > 
> > > > > No. That would break permissions checking. See above.
> > > > 
> > > > Then we need to look much harder at the permission checking
> > > > model of d_automount because we need to permission check against
> > > > both sets of creds.
> > 
> > How about something like this? Essentially, stash the creds used at
> > mount time in the super block, then create a vfs_kern_automount()
> > function which overrides the currend creds then calls
> > vfs_kern_mount().
> > 
> > Only compile tested so far, and probably it should be split up into
> > several patches.
> 
> > diff --git a/fs/namespace.c b/fs/namespace.c
> > index 487ba30bb5c6..da7e6dfa56cb 100644
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -989,6 +989,21 @@ vfs_kern_mount(struct file_system_type *type,
> > int flags, const char *name, void
> >  }
> >  EXPORT_SYMBOL_GPL(vfs_kern_mount);
> >  
> > +struct vfsmount *
> > +vfs_kern_automount(struct dentry *dentry, struct file_system_type
> > *type,
> > +		   int flags, const char *name, void *data)
> > +{
> > +	const struct cred *old_cred;
> > +	struct vfsmount *mnt;
> > +
> > +	old_cred = override_creds(dentry->d_sb->s_cred);
> > +	mnt = vfs_kern_mount(type, flags, name, data);
> > +	revert_creds(old_cred);
> > +
> > +	return mnt;
> > +}
> > +EXPORT_SYMBOL_GPL(vfs_kern_automount);
> > +
> 
> Nope. As I said, the call into the filesystem needs the _user_ creds.

Okay. I thought that perhaps the user's creds were only needed when
looking up the mountpoint, and that after that it might be okay to
switch the creds. I guess not.

Thanks,
Seth
