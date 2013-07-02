Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab3GBMPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 08:15:07 -0400
Message-ID: <1372767293.2620.26.camel@tlielax.poochiereds.net>
Subject: Re: [PATCH v1] vfs: allow umount to handle mountpoints without
 revalidating them
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christopher T Vogan <cvogan@us.ibm.com>
Date: Tue, 02 Jul 2013 08:14:53 -0400
In-Reply-To: <1372761278.2620.13.camel@tlielax.poochiereds.net>
References: <1372684830-13272-1-git-send-email-jlayton@redhat.com>
	 <20130702114234.41cc66dc@notabene.brown>
	 <1372761278.2620.13.camel@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-07-02 at 06:34 -0400, Jeffrey Layton wrote:
> On Tue, 2013-07-02 at 11:42 +1000, NeilBrown wrote:
> > On Mon,  1 Jul 2013 09:20:30 -0400 Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > Christopher reported a regression where he was unable to unmount a NFS
> > > filesystem where the root had gone stale. The problem is that
> > > d_revalidate handles the root of the filesystem differently from other
> > > dentries, but d_weak_revalidate does not. We could simply fix this by
> > > making d_weak_revalidate return success on IS_ROOT dentries, but there
> > > are cases where we do want to revalidate the root of the fs.
> > > 
> > > A umount is really a special case. We generally aren't interested in
> > > anything but the dentry and vfsmount that's attached at that point. If
> > > the inode turns out to be stale we just don't care since the intent is
> > > to stop using it anyway.
> > > 
> > > Try to handle this situation better by treating umount as a special
> > > case in the lookup code. Have it resolve the parent using normal
> > > means, and then do a lookup of the final dentry without revalidating
> > > it. In most cases, the final lookup will come out of the dcache, but
> > > the case where there's a trailing symlink or !LAST_NORM entry on the
> > > end complicates things a bit.
> > > 
> > > Reported-by: Christopher T Vogan <cvogan@us.ibm.com>
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > Thanks for this Jeff.  It certainly looks credible to me.
> > 
> > There is a lot of code copied from the "user_path_at" path which is a shame,
> > but probably better that putting in lots of "is this an unmount" tests which
> > would slow done the common case.
> > 
> > On balance, I like it.
> > 
> > Thanks,
> > NeilBrown
> > 
> 
> (cc'ing Christopher as I mistakenly left him off the original mail. I'll
> make sure to cc him on any respins...)
> 
> Thanks for looking. Yeah it is a lot of code to handle one case. So,
> while this does seem to work, I'm still not 100% sold on this
> approach...
> 
> I had assumed that we would sometimes want to revalidate IS_ROOT
> dentries in other codepaths. Now that I think about it though, I'm
> having a hard time coming up with any situations where that's
> necessary. We'll never want to invalidate such a dentry, so does that
> ever make sense?
> 
> If it doesn't, we could just replace this patch with a test for
> IS_ROOT(dentry) in nfs_weak_revalidate, and call it a day. I tested a
> patch like that earlier and it also worked around the problem.
> 
> Also, it bothers me a little that this patch stops revalidating anything
> once it hits the last component, even if it's a symlink and we know
> we'll have to chase it down. It may make sense to check for d_mountpoint
> in some cases and revalidate the dentry if it's true.

Erm...

    "and revalidate the dentry if it's _false_"

...I should have had my coffee before replying.

-- 
Jeff Layton <jlayton@redhat.com>

