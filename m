Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554Ab3GaSrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 14:47:01 -0400
Date: Wed, 31 Jul 2013 14:46:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Quentin Barnes <qbarnes@gmail.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
Message-ID: <20130731144657.7b94482b@tlielax.poochiereds.net>
In-Reply-To: <CAKjHkpAi_-jucPnFXg=3vMZg+pWSha3xR7KhjMPqN56K12SbCQ@mail.gmail.com>
References: <1362013834-29600-1-git-send-email-jlayton@redhat.com>
	<CAKjHkpAi_-jucPnFXg=3vMZg+pWSha3xR7KhjMPqN56K12SbCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 31 Jul 2013 13:36:21 -0500
Quentin Barnes <qbarnes@gmail.com> wrote:

> I was reviewing patches I was integrating into my NFS source base
> and this one popped up (commit f6488c9b).  In reviewing it, it would
> fix the problem, however, I think it's not the best fix for it.
> Catching it in nfs_find_actor() is after the horse has left the
> barn so to speak.
> 
> I think the problem is in nfs_fhget() when constructing the new
> inode (inside the if (inode->i_state & I_NEW) {...}) and should be
> addressed there.
> 
> The nfs module already has checks to ensure that the expression
> "((S_IFMT & inode->i_mode) == (S_IFMT & fattr->mode))" is true
> in nfs_update_inode() and nfs_check_inode_attributes().  I think
> problem Benny hit was that the equivalent check is missing in
> nfs_fhget() when constructing a new inode.  The same check that's
> in those other two functions needs to be added to nfs_fhget()'s "if
> (inode->i_state & I_NEW) {...}" conditional block to prevent the
> problem of an inconsistent fattr/inode state from occurring in the
> first place.
> 
> I can come up with a patch if you'd like, but I wanted to make
> sure my assertions were valid first.  Is removing a check from
> nfs_find_actor() and adding the check to nfs_fhget() to prevent the
> inconsistency in the first place a better approach?
> 
> Quentin
> 
> On Wed, Feb 27, 2013 at 7:10 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > Benny Halevy reported the following oops when testing RHEL6:
> [...]
> > This should fix the oops reported here:
> >
> >     https://bugzilla.redhat.com/show_bug.cgi?id=913660
> >
> > Reported-by: Benny Halevy <bhalevy@tonian.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/inode.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 6acc73c..f52c99f 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -237,6 +237,8 @@ nfs_find_actor(struct inode *inode, void *opaque)
> >
> >         if (NFS_FILEID(inode) != fattr->fileid)
> >                 return 0;
> > +       if ((S_IFMT & inode->i_mode) != (S_IFMT & fattr->mode))
> > +               return 0;
> >         if (nfs_compare_fh(NFS_FH(inode), fh))
> >                 return 0;
> >         if (is_bad_inode(inode) || NFS_STALE(inode))
> > --
> > 1.7.11.7
> >
> > --


I don't think I agree. The whole problem was that we were allowing
iget5_locked to match an existing inode even though (S_IFMT & mode) was
different.

Why would it be preferable to use the same struct inode even though
it's clearly a different one on the server? inodes generally don't
change their type after they've been created.

That said, patches speak louder than words so if you have one to
propose I can certainly take a look. Maybe it'll make sense to me
then...

-- 
Jeff Layton <jlayton@redhat.com>
