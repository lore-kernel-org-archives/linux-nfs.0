Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:50594 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132Ab3HFX4S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 19:56:18 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd6so2359259obb.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 16:56:17 -0700 (PDT)
Date: Tue, 6 Aug 2013 18:56:07 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
Message-ID: <20130806235458.GA28091@gmail.com>
References: <20130731230051.GB31859@gmail.com>
 <20130731204615.03a6b37a@corrin.poochiereds.net>
 <CAKjHkpBN=k28M3wv_9Xnpeoy6buRn3V4AXu2emkMw+NsuFir1g@mail.gmail.com>
 <20130802142924.6b61f850@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130802142924.6b61f850@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 02, 2013 at 02:29:24PM -0400, Jeff Layton wrote:
> On Fri, 2 Aug 2013 12:58:51 -0500
> Quentin Barnes <qbarnes@gmail.com> wrote:
> > On Wed, Jul 31, 2013 at 7:46 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > > The patch above doesn't address that.
> > 
> > I disagree.
> > 
> > Let's take a look at it from the NFSv4 angle --
> > 
> > The NFSv4 atomic open call path is:
> >   nfs4_atomic_open()->nfs4_do_open()->_nfs4_do_open()
> > 
> > In _nfs4_do_open(), it calls nfs4_do_setattr() which fills in an
> > fattr structure then calls nfs_post_op_update_inode() with it to
> > update the inode.  Then we call nfs_post_op_update_inode()->
> > nfs_post_op_update_inode_locked()->nfs_refresh_inode_locked().
> > 
> > So, yes, I think even in Benny's case, fixing nfs_refresh_inode_locked()
> > to invalidate an inode when nfs_check_inode_attributes() catches that
> > an NFS server had pulled a switcheroo (dir to file with same fh), the
> > approach above would have caught it when it happened.
> 
> No, it wouldn't have.
> 
> First, nfs4_do_setattr only gets called on an O_EXCL open. That bug is
> still triggerable even without that flag set in the open() call.

I'll have to look at that path.  Thanks for the additional details
on the conditions triggering of the problem.

> Second, opening a directory is different from opening a file. They
> create different open contexts and tearing those down at close time
> requires a different set of operations.

Of course.

> If you use the *same* inode in
> this situation, then you end up with the wrong set of operations for
> tearing down the open context.

Yes, I see your point.  I'm not seeing that so far.  I see it only
looking at the inode's parent directory or the superblock, but I'm
still reading.

> That's what causes the panic. So, marking the inode as stale makes no
> difference whatsoever because we still have to tear down the context,
> and that gets done using the fops associated with the inode.

I know what you mean.  I'm thinking it won't get that far, but I
know I'm still trying to get familiar with the NFSv4 paths.

> > > It just adds an extra cache
> > > invalidation, which won't help this case. The ops are still set the
> > > same way and the teardown of the atomic_open will still end up hitting
> > > the panic.
> > 
> > It would help me if you could explain how flagging the inode as
> > invalid doesn't help here.  If that's the case, then other bugs
> > might be running around.
> 
> That just flags the inode as stale and marks its attributes as invalid.
> The inode still has the same operations. Aside from that, I'm not
> convinced that marking that inode as stale is correct at all.

Marking the inode as stale _may not_ actually be correct as you
assert.  However, that's exactly how this error is already being
handled when encountered by nfs_update_inode().  Do you consider
nfs_update_inode() inappropriate in this regards as well, or is
there a separate reason why how it handles the error is valid?

> A stale inode has a pretty well-defined meaning in NFS. It means that
> the server doesn't know what this filehandle refers to. That doesn't
> seem to be the case here. We (likely) have a filehandle that got
> recycled too quickly, or something along those lines. That's indicative
> of a broken server, but there's nothing to suggest that the server will
> return NFSERR_STALE on it in the future.

I would think of the NFS errors available with this situation,
ESTALE would fit about the best.  Even though the file handle was
reused by the server, the server no longer has the original file
that went with that filehandle, hence that reference is stale.

In nfs_check_inode_attributes(), for this error (reusing a FH),
it returns EIO (instead of ESTALE).  Given those two, I think
the latter fits this weird situation a little better.

> If you're serious about "fixing" this problem then I suggest:
> 
> 1) describing what the problem is. We have a broken server here so all
> bets are off in working with it. Why should we care whether it's more
> "correct" to do what you suggest? What breakage can we avoid by doing
> this differently?

I have been somewhat surprised by your comment.  I can certainly
understand, appreciate, and agree the skepticism of different
approaches, however, if a better approach is available and proven,
it should almost always be desired (unless, for some odd reason,
say, it triggers a massive rewrite).

(As to why I originally flagged this patch, I don't want to trigger
a tangent here, but if you're interested, I can send you an email.)

I do have a question for you about my example patch though.  If you
completely ignore the portion modifying nfs_find_actor() and only
focus on the modification to nfs_refresh_inode_locked(), do you
think that change fixes an existing problem of how the error return
state from nfs_check_inode_attributes() is currently unchecked
(calling from nfs_fhget())?

> 2) consider rolling up a pynfs testcase or something that simulates
> such a broken server, so you can verify that the original bug is still
> fixed with the patch you propose.

Oh, yes, before a patch such as mine is accepted, I should
definitely have to prove that it still fixes the original panic with
hard evidence.  No argument there.  I would expect nothing less.

To emulate the bug, I was considering writing a systemtap script
to monitor the NFSv4 protocols and then for a known file handle for
a directory on a later call forge up a return for a regular file.
Would you expect that this approach (with some tweaking as needed
to get the protocol sequence right) be able to trigger the original
panic on the kernel version it was reported on?

To write the code to trigger the sequence of NFSv4 protocols, I
would expect to do say a stat() on a directory to trigger a LOOKUP
to load the dentry and inode, then do an open(...,O_CREAT|O_DIRECT)
to trigger an OPEN intercepting its return information overwriting
and forging it to look like a regular file.  Is that the correct
sequence?  What variations should also be tested?

> -- 
> Jeff Layton <jlayton@redhat.com>

Quentin
