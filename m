Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528Ab3GCMVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jul 2013 08:21:14 -0400
Message-ID: <1372854068.3070.16.camel@tlielax.poochiereds.net>
Subject: Re: [PATCH v1] vfs: allow umount to handle mountpoints without
 revalidating them
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christopher T Vogan <cvogan@us.ibm.com>
Date: Wed, 03 Jul 2013 08:21:08 -0400
In-Reply-To: <20130703104733.0dd1937d@notabene.brown>
References: <1372684830-13272-1-git-send-email-jlayton@redhat.com>
	 <20130702114234.41cc66dc@notabene.brown>
	 <1372761278.2620.13.camel@tlielax.poochiereds.net>
	 <20130703104733.0dd1937d@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-07-03 at 10:47 +1000, NeilBrown wrote:
> On Tue, 02 Jul 2013 06:34:38 -0400 Jeffrey Layton <jlayton@redhat.com> wrote:
> 
> > On Tue, 2013-07-02 at 11:42 +1000, NeilBrown wrote:
> > > On Mon,  1 Jul 2013 09:20:30 -0400 Jeff Layton <jlayton@redhat.com> wrote:
> > > 
> > > > Christopher reported a regression where he was unable to unmount a NFS
> > > > filesystem where the root had gone stale. The problem is that
> > > > d_revalidate handles the root of the filesystem differently from other
> > > > dentries, but d_weak_revalidate does not. We could simply fix this by
> > > > making d_weak_revalidate return success on IS_ROOT dentries, but there
> > > > are cases where we do want to revalidate the root of the fs.
> > > > 
> > > > A umount is really a special case. We generally aren't interested in
> > > > anything but the dentry and vfsmount that's attached at that point. If
> > > > the inode turns out to be stale we just don't care since the intent is
> > > > to stop using it anyway.
> > > > 
> > > > Try to handle this situation better by treating umount as a special
> > > > case in the lookup code. Have it resolve the parent using normal
> > > > means, and then do a lookup of the final dentry without revalidating
> > > > it. In most cases, the final lookup will come out of the dcache, but
> > > > the case where there's a trailing symlink or !LAST_NORM entry on the
> > > > end complicates things a bit.
> > > > 
> > > > Reported-by: Christopher T Vogan <cvogan@us.ibm.com>
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > 
> > > Thanks for this Jeff.  It certainly looks credible to me.
> > > 
> > > There is a lot of code copied from the "user_path_at" path which is a shame,
> > > but probably better that putting in lots of "is this an unmount" tests which
> > > would slow done the common case.
> > > 
> > > On balance, I like it.
> > > 
> > > Thanks,
> > > NeilBrown
> > > 
> > 
> > (cc'ing Christopher as I mistakenly left him off the original mail. I'll
> > make sure to cc him on any respins...)
> > 
> > Thanks for looking. Yeah it is a lot of code to handle one case. So,
> > while this does seem to work, I'm still not 100% sold on this
> > approach...
> > 
> > I had assumed that we would sometimes want to revalidate IS_ROOT
> > dentries in other codepaths. Now that I think about it though, I'm
> > having a hard time coming up with any situations where that's
> > necessary. We'll never want to invalidate such a dentry, so does that
> > ever make sense?
> 
> What does "revalidate" mean exactly here?  I think this is d_revalidate, so
> it is validating the entry in the dcache, so it is "validating that the name
> still leads to the inode".  Is that correct?
> 
> In that case as IS_ROOT has no name it is hard to imagine that it needs to be
> revalidated.

> However I don't think a mount point is always IS_ROOT.
> With NFSv4 (an possibly the other NFS versions as well), if I
>    mount server:/some/path /mnt
> then the NFS client will internally "mount" server:/, walk down to find
> "/some/path", and then bind that to /mnt.
> 
> In that case I would argue that it is really the inode found at "/some/path",
> rather than the textual name "/some/path" which is being bound.
> So when stepping from one filesystem, to the next over a mount point, it is
> pointless to try to revalidate the dentry because it is really the inode that
> we want.
>
> However it could be that "revalidate" means "check that this inode still
> exists, and is still the same sort of object (directory or file)".   If that
> is what we mean by "revalidate", then "umount" really is a special case as
> everything else would want to know that the object is still then, but umount
> wouldn't.
> 
> Thinking a bit more: I see "umount" as a bit like "lstat".  With "lstat", if
> the last component is a symlink we don't follow it, we just return it.
> With "umount" if the last component is a mountpoint we really don't want to
> follow it but rather return the underlying dentry.
> 
> Once "umount" does the lookup and gets the dentry that something was mounted
> on to, it can carefully attach whatever is mounted there without ever
> "touching" it.  (of couse if there are a stack of things mounted it need to
> only detach the last).
> 
> 
> 
> Do those thoughts help at all?  Or just add confusion?
> 
> NeilBrown
> 
> 

Thanks for helping me sort this out in my head. It's a very confusing
topic... ;)

This is somewhat related to the discussion when we added the
d_weak_revalidate op. When LOOKUP_JUMPED is set, then we know that we
arrived at this dentry via some other means than a lookup in the parent
dir. Thus, the dentry name isn't relevant, but the inode is and we only
want to revalidate the inode, not the dentry.

The commit message on the patch that originally added FS_REVAL_DOT says:
    
   For most filesystems this is OK, but it the case of the stateless
   NFS, this means that it circumvents path staleness detection, and the
   attribute+data cache revalidation code on such common commands as
   opendir(".").

So I think the real question is: Should we treat the root of a vfsmount
differently when revalidating its inode via d_weak_revalidate.

Since it's possible for such an inode to go stale, I think that we do
want to indicate that when someone does opendir() on it, even if it's
the root of the fs. So, umount really does need to be a special case,
and we ought not rely on d_weak_revalidate ops to try and get that
right.

So yeah, I guess this patch (or something like it) is what's needed. 

> > 
> > If it doesn't, we could just replace this patch with a test for
> > IS_ROOT(dentry) in nfs_weak_revalidate, and call it a day. I tested a
> > patch like that earlier and it also worked around the problem.
> > 
> > Also, it bothers me a little that this patch stops revalidating anything
> > once it hits the last component, even if it's a symlink and we know
> > we'll have to chase it down. It may make sense to check for d_mountpoint
> > in some cases and revalidate the dentry if it's true.
> >

On the above question, I think I'm inclined to not worry about it too
much until/unless someone complains. Symlink chasing on the last
component of a umount doesn't seem like it's common practice,
particularly since util-linux's /bin/umount does a realpath() on the
argument before calling umount() anyway.

-- 
Jeff Layton <jlayton@redhat.com>

