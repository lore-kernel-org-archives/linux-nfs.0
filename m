Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <20151014155521.28475a2d@synchrony.poochiereds.net>
References: <cover.1444846590.git.bcodding@redhat.com>
	<1ad951a190be5b737d285ae91c3d8acbfb84ff18.1444846590.git.bcodding@redhat.com>
	<20151014155521.28475a2d@synchrony.poochiereds.net>
Date: Wed, 21 Oct 2015 14:48:45 -0700
Message-ID: <CAHQdGtTYxUdJvvALn0o=KVAwyNxCO03JXhexFysbjq6p9wrjUQ@mail.gmail.com>
Subject: Re: [PATCH 08/10] NFS: Move do_vfs_lock to shared inline
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 12:55 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
>
> On Wed, 14 Oct 2015 14:23:35 -0400
> Benjamin Coddington <bcodding@redhat.com> wrote:
>
> > Send the inode instead of the file_lock to do_vfs_lock() in
> > fs/lockd/clintproc.c (because there may not be a fl_file the unlock path).
> > Now that we have posix_lock_inode_wait() the three copies of do_vfs_lock()
> > can be collapsed.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/lockd/clntproc.c |   25 +++++--------------------
> >  fs/nfs/file.c       |   20 ++------------------
> >  fs/nfs/nfs4proc.c   |   16 ----------------
> >  include/linux/fs.h  |   16 ++++++++++++++++
> >  4 files changed, 23 insertions(+), 54 deletions(-)
> >
> > diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> > index 4a35e7c..bd484f0 100644
> > --- a/fs/lockd/clntproc.c
> > +++ b/fs/lockd/clntproc.c
> > @@ -475,22 +475,6 @@ static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *ho
> >       fl->fl_ops = &nlmclnt_lock_ops;
> >  }
> >
> > -static int do_vfs_lock(struct file_lock *fl)
> > -{
> > -     int res = 0;
> > -     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > -             case FL_POSIX:
> > -                     res = posix_lock_file_wait(fl->fl_file, fl);
> > -                     break;
> > -             case FL_FLOCK:
> > -                     res = flock_lock_file_wait(fl->fl_file, fl);
> > -                     break;
> > -             default:
> > -                     BUG();
> > -     }
> > -     return res;
> > -}
> > -
> >  /*
> >   * LOCK: Try to create a lock
> >   *
> > @@ -518,6 +502,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
> >       struct nlm_host *host = req->a_host;
> >       struct nlm_res  *resp = &req->a_res;
> >       struct nlm_wait *block = NULL;
> > +     struct inode *inode = file_inode(fl->fl_file);
> >       unsigned char fl_flags = fl->fl_flags;
> >       unsigned char fl_type;
> >       int status = -ENOLCK;
> > @@ -527,7 +512,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
> >       req->a_args.state = nsm_local_state;
> >
> >       fl->fl_flags |= FL_ACCESS;
> > -     status = do_vfs_lock(fl);
> > +     status = do_vfs_lock(inode, fl);
> >       fl->fl_flags = fl_flags;
> >       if (status < 0)
> >               goto out;
> > @@ -577,7 +562,7 @@ again:
> >               }
> >               /* Ensure the resulting lock will get added to granted list */
> >               fl->fl_flags |= FL_SLEEP;
> > -             if (do_vfs_lock(fl) < 0)
> > +             if (do_vfs_lock(inode, fl) < 0)
> >                       printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
> >               up_read(&host->h_rwsem);
> >               fl->fl_flags = fl_flags;
> > @@ -607,7 +592,7 @@ out_unlock:
> >       fl_type = fl->fl_type;
> >       fl->fl_type = F_UNLCK;
> >       down_read(&host->h_rwsem);
> > -     do_vfs_lock(fl);
> > +     do_vfs_lock(inode, fl);
> >       up_read(&host->h_rwsem);
> >       fl->fl_type = fl_type;
> >       fl->fl_flags = fl_flags;
> > @@ -674,7 +659,7 @@ nlmclnt_unlock(struct nfs_open_context *ctx, struct nlm_rqst *req, struct file_l
> >        */
> >       fl->fl_flags |= FL_EXISTS;
> >       down_read(&host->h_rwsem);
> > -     status = do_vfs_lock(fl);
> > +     status = do_vfs_lock(d_inode(ctx->dentry), fl);
> >       up_read(&host->h_rwsem);
> >       fl->fl_flags = fl_flags;
> >       if (status == -ENOENT) {
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 319847c..d16c50f 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -737,22 +737,6 @@ out_noconflict:
> >       goto out;
> >  }
> >
> > -static int do_vfs_lock(struct file *file, struct file_lock *fl)
> > -{
> > -     int res = 0;
> > -     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > -             case FL_POSIX:
> > -                     res = posix_lock_file_wait(file, fl);
> > -                     break;
> > -             case FL_FLOCK:
> > -                     res = flock_lock_file_wait(file, fl);
> > -                     break;
> > -             default:
> > -                     BUG();
> > -     }
> > -     return res;
> > -}
> > -
> >  static int
> >  do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> >  {
> > @@ -786,7 +770,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> >       if (!is_local)
> >               status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
> >       else
> > -             status = do_vfs_lock(filp, fl);
> > +             status = do_vfs_lock(inode, fl);
> >       return status;
> >  }
> >
> > @@ -817,7 +801,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> >       if (!is_local)
> >               status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
> >       else
> > -             status = do_vfs_lock(filp, fl);
> > +             status = do_vfs_lock(inode, fl);
> >       if (status < 0)
> >               goto out;
> >
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index c08f8ac..6b19307 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -5511,22 +5511,6 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
> >       return err;
> >  }
> >
> > -static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
> > -{
> > -     int res = 0;
> > -     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > -             case FL_POSIX:
> > -                     res = posix_lock_inode_wait(inode, fl);
> > -                     break;
> > -             case FL_FLOCK:
> > -                     res = flock_lock_inode_wait(inode, fl);
> > -                     break;
> > -             default:
> > -                     BUG();
> > -     }
> > -     return res;
> > -}
> > -
> >  struct nfs4_unlockdata {
> >       struct nfs_locku_args arg;
> >       struct nfs_locku_res res;
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 72d8a84..165577a 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1225,6 +1225,22 @@ static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
> >       return flock_lock_inode_wait(file_inode(filp), fl);
> >  }
> >
> > +static inline int do_vfs_lock(struct inode *inode, struct file_lock *fl)
> > +{
> > +     int res = 0;
> > +     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > +             case FL_POSIX:
> > +                     res = posix_lock_inode_wait(inode, fl);
> > +                     break;
> > +             case FL_FLOCK:
> > +                     res = flock_lock_inode_wait(inode, fl);
> > +                     break;
> > +             default:
> > +                     BUG();
> > +     }
> > +     return res;
> > +}
> > +
> >  struct fasync_struct {
> >       spinlock_t              fa_lock;
> >       int                     magic;
>
> Meh ok...a little large for an inline though. Maybe you should move
> that into fs/nfs_common and have it as an exported symbol? I'm not too
> religious about it though since we don't have many call sites.

Is this ready to merge, or should we hold off pending an update?
