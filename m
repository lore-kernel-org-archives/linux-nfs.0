Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50815 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbbLGQFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:05:46 -0500
Date: Mon, 7 Dec 2015 11:05:44 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: Re: [PATCH 10/10] NFS: Deferred unlocks - always unlock on
 FL_CLOSE
In-Reply-To: <20151014163018.1d2de645@synchrony.poochiereds.net>
Message-ID: <alpine.OSX.2.19.9992.1512071102150.61227@planck.local>
References: <cover.1444846590.git.bcodding@redhat.com> <93c4aa68a777b232075b9b8252d671635bb1c320.1444846590.git.bcodding@redhat.com> <20151014163018.1d2de645@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Oct 2015, Jeff Layton wrote:

> On Wed, 14 Oct 2015 14:23:37 -0400
> Benjamin Coddington <bcodding@redhat.com> wrote:
>
> > NFS unlock procedures will wait for IO to complete before sending an unlock.
> > In the case that this wait is interrupted, an unlock may never be sent if
> > the unlock is part of cleaning up locks during a close.  This lost lock can
> > then prevent other clients from locking the file.
> >
> > Fix this by deferring an unlock that should wait for IO during FL_CLOSE by
> > copying it to a list on the nfs_lock_context, which can then be used to
> > release the lock when the IO has completed.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/file.c          |   36 +++++++++++++++++++++++++++++++++++-
> >  fs/nfs/inode.c         |    1 +
> >  fs/nfs/pagelist.c      |   23 ++++++++++++++++++++---
> >  include/linux/nfs_fs.h |    7 +++++++
> >  4 files changed, 63 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index d16c50f..460311a 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -738,6 +738,36 @@ out_noconflict:
> >  }
> >
> >  static int
> > +defer_unlk(struct nfs_lock_context *l_ctx, int cmd, struct file_lock *fl)
> > +{
> > +	struct inode *inode = d_inode(l_ctx->open_context->dentry);
> > +	struct nfs_io_counter *c = &l_ctx->io_count;
> > +	struct nfs_deferred_unlock *dunlk;
> > +	int status = 0;
> > +
> > +	if (atomic_read(&c->io_count) == 0)
> > +		return 0;
> > +
> > +	/* free in nfs_iocounter_dec */
> > +	dunlk = kmalloc(sizeof(*dunlk), GFP_NOFS);
> > +	if (dunlk == NULL)
> > +		return -ENOMEM;
> > +
>
> This is a little ugly...

> You're probably going to calling this from something like
> locks_remove_posix, and if this allocation fails then the unlock will
> just never happen.
>
> Is there any way to avoid this allocation?

Yes!  As you go on to suggest..

> The "cmd" field in nfs_deferred_unlock is more or less redundant. We're
> always calling this with that set to F_UNLCK. We also know that this
> will be called on the whole file range. Maybe we can simply add a flag
> to the lock context to indicate whether we should send a whole-file
> unlock on it when the io_count goes to zero.

That simplifies things quite a bit..  I'm going to resubmit this with that
approach.  Thanks!

> Also, on a somewhat related note...we aren't currently setting FL_CLOSE
> in locks_remove_flock and we probably should be.

I'll add that as well.

Ben
