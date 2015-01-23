Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55897 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbbAWEHy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 23:07:54 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so6021319pdj.9
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 20:07:53 -0800 (PST)
Date: Thu, 22 Jan 2015 20:07:51 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH RESEND] nfs: prevent truncate on active swapfile
Message-ID: <20150123040751.GA24282@mew>
References: <fdc56e2887c3ed93f4e6a6e784ee0748c2d13295.1420708562.git.osandov@osandov.com>
 <CAHQdGtT=sXmDk=samGCD92mC-Rjr57NAOURudD9TRyFy3=YaBA@mail.gmail.com>
 <20150112194302.GA27355@mew.dhcp4.washington.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150112194302.GA27355@mew.dhcp4.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 11:43:02AM -0800, Omar Sandoval wrote:
> On Sat, Jan 10, 2015 at 05:08:03PM -0500, Trond Myklebust wrote:
> > Hi Omar,
> > 
> > On Thu, Jan 8, 2015 at 4:18 AM, Omar Sandoval <osandov@osandov.com> wrote:
> > > Most filesystems prevent truncation of an active swapfile by way of
> > > inode_newsize_ok, called from inode_change_ok. NFS doesn't call either
> > > from nfs_setattr, presumably because most of these checks are expected
> > > to be done server-side. However, the IS_SWAPFILE check can only be done
> > > client-side, and truncating a swapfile can't possibly be good.
> > >
> > > Signed-off-by: Omar Sandoval <osandov@osandov.com>
> > > ---
> > > Hi, Trond,
> > >
> > > Now that the holidays are over, could you take a look at this? It was
> > > generated against v3.19-rc3.
> > >
> > > Thanks!
> > >
> > >  fs/nfs/inode.c | 7 ++++++-
> > >  1 file changed, 6 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > > index 4bffe63..9205513 100644
> > > --- a/fs/nfs/inode.c
> > > +++ b/fs/nfs/inode.c
> > > @@ -506,10 +506,15 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
> > >                 attr->ia_valid &= ~ATTR_MODE;
> > >
> > >         if (attr->ia_valid & ATTR_SIZE) {
> > > +               loff_t i_size;
> > > +
> > >                 BUG_ON(!S_ISREG(inode->i_mode));
> > >
> > > -               if (attr->ia_size == i_size_read(inode))
> > > +               i_size = i_size_read(inode);
> > > +               if (attr->ia_size == i_size)
> > >                         attr->ia_valid &= ~ATTR_SIZE;
> > > +               else if (attr->ia_size < i_size && IS_SWAPFILE(inode))
> > > +                       return -ETXTBSY;
> > >         }
> > >
> > >         /* Optimization: if the end result is no change, don't RPC */
> > > --
> > > 2.2.1
> > >
> > 
> > I agree that truncating a swap file is bad, however as you point out,
> > this really only addresses the case on the client that knows about
> > this being a swap file.
> > I'll take the patch,
> 
> Thanks, I appreciate it.
> 
> > but I'm wondering if we couldn't do better in the
> > case where we're using NFSv4 by using share deny modes (which are
> > enforced by the server). The problem is that there appears to be
> > nothing in swapon() that tells the filesystem this is an open of a
> > swap file...
> 
> Yeah, it would be nice for completeness to prevent one client from
> truncating another client's swapfile. However, I'd hope that anyone
> using swap-over-NFS on a shared NFS mount would take the necessary
> precautions in terms of permissions, etc. to prevent someone from doing
> that. Also, since the failure mode of truncating an NFS swapfile is a
> corrupt swapfile rather than a corrupt filesystem (like on a local
> filesystem), it's probably okay to just deal with the low-hanging fruit
> for now.
> 
> Thanks!
> 
> > 
> > Cheers
> >   Trond
> > -- 
> > Trond Myklebust
> > Linux NFS client maintainer, PrimaryData
> > trond.myklebust@primarydata.com
> 
> -- 
> Omar

Hi, Trond,

Are you still planning on taking this patch? I didn't see it in your
last pull request to Linus.

Thanks,
-- 
Omar
