Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbcAENtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2016 08:49:00 -0500
Date: Tue, 5 Jan 2016 08:48:54 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 09/10] NFS: Deferred unlocks - always unlock on
 FL_CLOSE
In-Reply-To: <CAHQdGtQdXO-P+NBKnKnbc+E-OLSJJHKVww8MMKk_CPAngSgn7w@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1601050603500.43575@planck.local>
References: <cover.1451480826.git.bcodding@redhat.com> <07314b592396fea8c037347933d9edb8c1e34b07.1451480826.git.bcodding@redhat.com> <CAHQdGtQdXO-P+NBKnKnbc+E-OLSJJHKVww8MMKk_CPAngSgn7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Jan 2016, Trond Myklebust wrote:

> On Wed, Dec 30, 2015 at 8:14 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > NFS unlock procedures will wait for IO to complete before sending an
> > unlock.  In the case that this wait is interrupted, an unlock may never be
> > sent if the unlock is in the close path.
> >
> > On NFSv3, this lost lock will then cause other clients to be blocked from
> > acquiring a conflicting lock indefinitely.  On NFSv4, the nfs4_lock_state
> > may never be released resulting in the use of invalid stateids for lock
> > operations after a subsequent open by the same process.
> >
> > Fix this by setting a flag on the lock context to send an unlock for the
> > entire file as soon as outstanding IO for that lock context has completed.
> > A call into NFS_PROTO(inode)->lock() for both posix and flock style locks
> > is made no matter which original lock type was held, since the FL_EXISTS
> > check will return the operation early for a non-existent lock.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/file.c          |   26 +++++++++++++++++++++-----
> >  fs/nfs/inode.c         |   22 ++++++++++++++++++++++
> >  fs/nfs/pagelist.c      |    8 ++++++--
> >  include/linux/nfs_fs.h |    3 +++
> >  4 files changed, 52 insertions(+), 7 deletions(-)
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 20a0541..3644fed 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -743,6 +743,22 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
> >  }
> >
> >  static int
> > +defer_close_unlk(struct inode *inode, struct nfs_lock_context *l_ctx)
> > +{
> > +       struct nfs_io_counter *c = &l_ctx->io_count;
> > +       int status = 0;
> > +
> > +       if (test_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags))
> > +               return -EINPROGRESS;
>
> Why is this needed? Normally, the process should set FL_CLOSE only
> once per fl_owner_t.

That is true; this is unnecessary.  I'll remove it.

> > +
> > +       if (atomic_read(&c->io_count) != 0) {
> > +               set_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags);
>
> What guarantees atomicity between io_count being non-zero and the
> setting of NFS_LOCK_CLOSE_UNLOCK?

Nothing, which is a mistake.  I'd removed the bits that ensured atomicity on
a previous version that would do the unlock on the release of the
nfs_lock_context, but ended up scrapping it.  I'll add them back.

Aside: an approach that does the unlock on the last placement of the lock
context seems like it might have less spinning and checking in the iocounter
functions.  I discarded that because the open context shares lock context
reference accounting and I thought that separating them would be more work,
however it is an unexpected optimization so maybe they should be separated
for clarity; I may look at it again.

> > +               status = -EINPROGRESS;
> > +       }
> > +       return status;
> > +}
> > +
> > +static int
> >  do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> >  {
> >         struct inode *inode = filp->f_mapping->host;
> > @@ -758,16 +774,16 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> >
> >         l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
> >         if (!IS_ERR(l_ctx)) {
> > -               status = nfs_iocounter_wait(&l_ctx->io_count);
> > +               if (fl->fl_flags & FL_CLOSE)
> > +                       status = defer_close_unlk(inode, l_ctx);
> > +               else
> > +                       status = nfs_iocounter_wait(&l_ctx->io_count);
> > +
> >                 nfs_put_lock_context(l_ctx);
> >                 if (status < 0)
> >                         return status;
>
> Question: instead of deferring unlock, why can't we simply ignore the
> return value of nfs_iocounter_wait(), just like we do for the return
> value of vfs_fsync() in this function?

Wouldn't that allow an interrupt in nfs_iocounter_wait() to send the unlock
before I/O completes, which could have the server ask us to resend the I/O
due to an invalid lock statid?

> >         }
> >
> > -       /* NOTE: special case
> > -        *      If we're signalled while cleaning up locks on process exit, we
> > -        *      still need to complete the unlock.
> > -        */
> >         /*
> >          * Use local locking if mounted with "-onolock" or with appropriate
> >          * "-olocal_lock="
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 31b0a52..065c8a9 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -699,6 +699,7 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
> >         l_ctx->lockowner.l_owner = current->files;
> >         l_ctx->lockowner.l_pid = current->tgid;
> >         INIT_LIST_HEAD(&l_ctx->list);
> > +       l_ctx->flags = 0;
> >         nfs_iocounter_init(&l_ctx->io_count);
> >  }
> >
> > @@ -759,6 +760,27 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_put_lock_context);
> >
> > +void nfs_unlock_lock_context(struct nfs_lock_context *l_ctx)
> > +{
> > +       struct inode *inode = d_inode(l_ctx->open_context->dentry);
> > +       struct file_lock fl = {
> > +               .fl_type = F_UNLCK,
> > +               .fl_start = 0,
> > +               .fl_end = OFFSET_MAX,
> > +               .fl_owner = l_ctx->lockowner.l_owner,
> > +               .fl_pid = l_ctx->lockowner.l_pid,
> > +       };
> > +
> > +       fl.fl_flags = FL_POSIX | FL_CLOSE;
> > +       NFS_PROTO(inode)->lock(l_ctx->open_context, F_SETLK, &fl);
> > +       if (fl.fl_ops)
> > +               fl.fl_ops->fl_release_private(&fl);
> > +       fl.fl_flags = FL_FLOCK | FL_CLOSE;
> > +       NFS_PROTO(inode)->lock(l_ctx->open_context, F_SETLK, &fl);
> > +       if (fl.fl_ops)
> > +               fl.fl_ops->fl_release_private(&fl);
>
> This is releasing both POSIX and flock() locks, but they all use
> different fl_owner_t values. Each lock context therefore corresponds
> to _either_ a POSIX _or_ a flock() lock, or an OFD lock.

This detail I had completely missed.  I can carry the lock type along on the
lock context and perform the correct unlock procedure from that.

> to _either_ a POSIX _or_ a flock() lock, or an OFD lock. Furthermore,
> you can end up with a double free here because you don't reset
> fl.fl_ops->fl_release_private to NULL before calling into the flock()
> case.

Yes, what an idiot am I.  :)

> Also, what about the case where this is a local lock (i.e. we mounted
> with -onolock or -olocal_lock=)?

Then there's no need at all to defer an unlock, so we should check for it
before setting the flag to defer.  That check will be added.

> > +}
> > +
> >  /**
> >   * nfs_close_context - Common close_context() routine NFSv2/v3
> >   * @ctx: pointer to context
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index fe3ddd2..f914fbe 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -108,9 +108,13 @@ nfs_iocounter_inc(struct nfs_io_counter *c)
> >  }
> >
> >  static void
> > -nfs_iocounter_dec(struct nfs_io_counter *c)
> > +nfs_iocounter_dec(struct nfs_lock_context *l_ctx)
> >  {
> > +       struct nfs_io_counter *c = &l_ctx->io_count;
> > +
> >         if (atomic_dec_and_test(&c->io_count)) {
> > +               if (test_and_clear_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags))
> > +                       nfs_unlock_lock_context(l_ctx);
>
> What guarantees that you are in a context where you are allowed to
> make synchronous RPC calls here? AFAICS you are almost always calling
> from an asynchronous I/O path callback.

Good point - the lock procedures could skip waiting for FL_CLOSE.

> >                 clear_bit(NFS_IO_INPROGRESS, &c->flags);
> >                 smp_mb__after_atomic();
> >                 wake_up_bit(&c->flags, NFS_IO_INPROGRESS);
>
> BTW: nfs_iocounter_dec() could use a cleanup. Now that we have
> wait_on_atomic_t(), there is no need for the NFS_IO_INPROGRESS bit.

I will attempt this, but please let me know if you consider the review of
my work to be much more work overall than if you were to fix it.. I really
appreciate the review and your time, and Happy New Year to you as well!

Ben

>
> > @@ -431,7 +435,7 @@ static void nfs_clear_request(struct nfs_page *req)
> >                 req->wb_page = NULL;
> >         }
> >         if (l_ctx != NULL) {
> > -               nfs_iocounter_dec(&l_ctx->io_count);
> > +               nfs_iocounter_dec(l_ctx);
> >                 nfs_put_lock_context(l_ctx);
> >                 req->wb_lock_context = NULL;
> >         }
> > diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> > index c0e9614..b105144 100644
> > --- a/include/linux/nfs_fs.h
> > +++ b/include/linux/nfs_fs.h
> > @@ -72,6 +72,8 @@ struct nfs_lock_context {
> >         struct nfs_open_context *open_context;
> >         struct nfs_lockowner lockowner;
> >         struct nfs_io_counter io_count;
> > +#define NFS_LOCK_CLOSE_UNLOCK 0
> > +       unsigned long flags;
> >  };
> >
> >  struct nfs4_state;
> > @@ -373,6 +375,7 @@ extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context
> >  extern void nfs_file_clear_open_context(struct file *flip);
> >  extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
> >  extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
> > +extern void nfs_unlock_lock_context(struct nfs_lock_context *l_ctx);
> >  extern u64 nfs_compat_user_ino64(u64 fileid);
> >  extern void nfs_fattr_init(struct nfs_fattr *fattr);
> >  extern void nfs_fattr_set_barrier(struct nfs_fattr *fattr);
> > --
> > 1.7.1
>
