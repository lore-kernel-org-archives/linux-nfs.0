Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f53.google.com ([74.125.83.53]:53406 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab3ENGX6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 02:23:58 -0400
Received: by mail-ee0-f53.google.com with SMTP id d49so79591eek.26
        for <linux-nfs@vger.kernel.org>; Mon, 13 May 2013 23:23:56 -0700 (PDT)
Date: Tue, 14 May 2013 08:23:50 +0200
From: Jeff Layton <jlayton@samba.org>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Subject: Re: [PATCH v6 2/7] VFS: Add O_DENYDELETE support for VFS
Message-ID: <20130514082350.7399b3e4@corrin.poochiereds.net>
In-Reply-To: <CAKywueSZhYZo-Xc8s2Vv-k8a1LBNr_FGOH0qSMRFKJ1hJrYOUw@mail.gmail.com>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
	<1366977861-27678-3-git-send-email-piastry@etersoft.ru>
	<20130510070959.0af3e35a@tlielax.poochiereds.net>
	<CAKywueSZhYZo-Xc8s2Vv-k8a1LBNr_FGOH0qSMRFKJ1hJrYOUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 May 2013 21:50:23 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> 2013/5/10 Jeff Layton <jlayton@poochiereds.net>:
> > On Fri, 26 Apr 2013 16:04:16 +0400
> > Pavel Shilovsky <piastry@etersoft.ru> wrote:
> >
> >> Introduce new LOCK_DELETE flock flag that is suggested to be used
> >> internally only to map O_DENYDELETE open flag:
> >>
> >> !O_DENYDELETE -> LOCK_DELETE | LOCK_MAND.
> >>
> >> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> >> ---
> >>  fs/locks.c                       | 53 +++++++++++++++++++++++++++++++++-------
> >>  fs/namei.c                       |  3 +++
> >>  include/linux/fs.h               |  6 +++++
> >>  include/uapi/asm-generic/fcntl.h |  1 +
> >>  4 files changed, 54 insertions(+), 9 deletions(-)
> >>
> >> diff --git a/fs/locks.c b/fs/locks.c
> >> index dbc5557..1cc68a9 100644
> >> --- a/fs/locks.c
> >> +++ b/fs/locks.c
> >> @@ -269,7 +269,7 @@ EXPORT_SYMBOL(locks_copy_lock);
> >>
> >>  static inline int flock_translate_cmd(int cmd) {
> >>       if (cmd & LOCK_MAND)
> >> -             return cmd & (LOCK_MAND | LOCK_RW);
> >> +             return cmd & (LOCK_MAND | LOCK_RW | LOCK_DELETE);
> >>       switch (cmd) {
> >>       case LOCK_SH:
> >>               return F_RDLCK;
> >> @@ -614,6 +614,8 @@ deny_flags_to_cmd(unsigned int flags)
> >>               cmd |= LOCK_READ;
> >>       if (!(flags & O_DENYWRITE))
> >>               cmd |= LOCK_WRITE;
> >> +     if (!(flags & O_DENYDELETE))
> >> +             cmd |= LOCK_DELETE;
> >>
> >>       return cmd;
> >>  }
> >> @@ -836,6 +838,31 @@ out:
> >>       return error;
> >>  }
> >>
> >> +int
> >> +sharelock_may_delete(struct dentry *dentry)
> >> +{
> >> +     struct file_lock **before;
> >> +     int rc = 0;
> >> +
> >> +     if (!IS_SHARELOCK(dentry->d_inode))
> >> +             return rc;
> >> +
> >> +     lock_flocks();
> >> +     for_each_lock(dentry->d_inode, before) {
> >> +             struct file_lock *fl = *before;
> >> +             if (IS_POSIX(fl))
> >> +                     break;
> >> +             if (IS_LEASE(fl))
> >> +                     continue;
> >> +             if (fl->fl_type & LOCK_DELETE)
> >> +                     continue;
> >> +             rc = 1;
> >> +             break;
> >> +     }
> >> +     unlock_flocks();
> >> +     return rc;
> >> +}
> >> +
> >>  /*
> >>   * Determine if a file is allowed to be opened with specified access and share
> >>   * modes. Lock the file and return 0 if checks passed, otherwise return
> >> @@ -850,10 +877,6 @@ sharelock_lock_file(struct file *filp)
> >>       if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
> >>               return error;
> >>
> >> -     /* Disable O_DENYDELETE support for now */
> >> -     if (filp->f_flags & O_DENYDELETE)
> >> -             return -EINVAL;
> >> -
> >>       error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
> >>       if (error)
> >>               return error;
> >> @@ -1717,6 +1740,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
> >>       if (!f.file)
> >>               goto out;
> >>
> >> +     /* LOCK_DELETE is defined to be translated from O_DENYDELETE only */
> >> +     if (cmd & LOCK_DELETE) {
> >> +             error = -EINVAL;
> >> +             goto out;
> >> +     }
> >> +
> >>       can_sleep = !(cmd & LOCK_NB);
> >>       cmd &= ~LOCK_NB;
> >>       unlock = (cmd == LOCK_UN);
> >> @@ -2261,10 +2290,16 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
> >>               seq_printf(f, "UNKNOWN UNKNOWN  ");
> >>       }
> >>       if (fl->fl_type & LOCK_MAND) {
> >> -             seq_printf(f, "%s ",
> >> -                            (fl->fl_type & LOCK_READ)
> >> -                            ? (fl->fl_type & LOCK_WRITE) ? "RW   " : "READ "
> >> -                            : (fl->fl_type & LOCK_WRITE) ? "WRITE" : "NONE ");
> >> +             if (fl->fl_type & LOCK_DELETE)
> >> +                     seq_printf(f, "%s ",
> >> +                             (fl->fl_type & LOCK_READ) ?
> >> +                             (fl->fl_type & LOCK_WRITE) ? "RWDEL" : "RDDEL" :
> >> +                             (fl->fl_type & LOCK_WRITE) ? "WRDEL" : "DEL  ");
> >> +             else
> >> +                     seq_printf(f, "%s ",
> >> +                             (fl->fl_type & LOCK_READ) ?
> >> +                             (fl->fl_type & LOCK_WRITE) ? "RW   " : "READ " :
> >> +                             (fl->fl_type & LOCK_WRITE) ? "WRITE" : "NONE ");
> >>       } else {
> >>               seq_printf(f, "%s ",
> >>                              (lease_breaking(fl))
> >> diff --git a/fs/namei.c b/fs/namei.c
> >> index dd236fe..a404f7d 100644
> >> --- a/fs/namei.c
> >> +++ b/fs/namei.c
> >> @@ -2220,6 +2220,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
> >>   *  9. We can't remove a root or mountpoint.
> >>   * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
> >>   *     nfs_async_unlink().
> >> + * 11. We can't do it if victim is locked by O_DENYDELETE sharelock.
> >>   */
> >>  static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> >>  {
> >> @@ -2250,6 +2251,8 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> >>               return -ENOENT;
> >>       if (victim->d_flags & DCACHE_NFSFS_RENAMED)
> >>               return -EBUSY;
> >> +     if (sharelock_may_delete(victim))
> >> +             return -ESHAREDENIED;
> >
> >
> > Is there a potential race here?
> >
> > You're holding the parent's i_mutex when setting a lock on this file,
> > but you're not holding it when you test for it here. So it seems
> > possible you could end up granting a O_DENYDELETE open on a file that
> > is in the process of being deleted from the namespace.
> 
> may_delete function is called from vfs_unlnk, vfs_rename and vfs_rmdir
> and in all those places the caller is holding parent's i_mutex. It
> seems that the locking order is correct: we hold parent's i_mutex when
> we set and test sharelocks.
> 

You're correct -- I misread the code. They do hold the parent's i_mutex
in all of the critical spots, so that should prevent the above race.
-- 
Jeff Layton <jlayton@samba.org>
