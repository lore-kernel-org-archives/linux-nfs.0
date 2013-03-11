Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140Ab3CKTKy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 15:10:54 -0400
Date: Mon, 11 Mar 2013 15:10:50 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v3 2/7] vfs: Add O_DENYREAD/WRITE flags support for open
 syscall
Message-ID: <20130311151050.0b685e4c@corrin.poochiereds.net>
In-Reply-To: <CAKywueTEXOH3s0z2X7e=QugJaQAZ6JPoaYmYPnFLHMOTC7_y4w@mail.gmail.com>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-3-git-send-email-piastry@etersoft.ru>
	<20130311144609.2ba86964@corrin.poochiereds.net>
	<CAKywueTEXOH3s0z2X7e=QugJaQAZ6JPoaYmYPnFLHMOTC7_y4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Mar 2013 22:57:27 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> 2013/3/11 Jeff Layton <jlayton@redhat.com>:
> > On Thu, 28 Feb 2013 19:25:28 +0400
> > Pavel Shilovsky <piastry@etersoft.ru> wrote:
> >
> >> If O_DENYMAND flag is specified, O_DENYREAD/WRITE/MAND flags are
> >> translated to flock's flags:
> >>
> >> !O_DENYREAD  -> LOCK_READ
> >> !O_DENYWRITE -> LOCK_WRITE
> >> O_DENYMAND   -> LOCK_MAND
> >>
> >> and set through flock_lock_file on a file.
> >>
> >> This change affects opens that use O_DENYMAND flag - all other
> >> native Linux opens don't care about these flags. It allow us to
> >> enable this feature for applications that need it (e.g. NFS and
> >> Samba servers that export the same directory for Windows clients,
> >> or Wine applications that access the same files simultaneously).
> >>
> >> Create codepath is slightly changed to prevent data races on
> >> newely created files: when open with O_CREAT can return with -ETXTBSY
> >> error for successfully created files due to a deny lock set by
> >> another task.
> >>
> >> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> >> ---
> >>  fs/locks.c         | 116 +++++++++++++++++++++++++++++++++++++++++++++++------
> >>  fs/namei.c         |  44 ++++++++++++++++++--
> >>  include/linux/fs.h |   6 +++
> >>  3 files changed, 151 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/fs/locks.c b/fs/locks.c
> >> index a94e331..0cc7d1b 100644
> >> --- a/fs/locks.c
> >> +++ b/fs/locks.c
> >> @@ -605,20 +605,81 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
> >>       return (locks_conflict(caller_fl, sys_fl));
> >>  }
> >>
> >> -/* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
> >> - * checking before calling the locks_conflict().
> >> +static unsigned int
> >> +deny_flags_to_cmd(unsigned int flags)
> >> +{
> >> +     unsigned int cmd = LOCK_MAND;
> >> +
> >> +     if (!(flags & O_DENYREAD))
> >> +             cmd |= LOCK_READ;
> >> +     if (!(flags & O_DENYWRITE))
> >> +             cmd |= LOCK_WRITE;
> >> +
> >> +     return cmd;
> >> +}
> >> +
> >> +/*
> >> + * locks_mand_conflict - Determine if there's a share reservation conflict
> >> + * @caller_fl: lock we're attempting to acquire
> >> + * @sys_fl: lock already present on system that we're checking against
> >> + *
> >> + * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
> >> + * tell us whether the reservation allows other readers and writers.
> >> + *
> >> + * We only check against other LOCK_MAND locks, so applications that want to
> >> + * use share mode locking will only conflict against one another. "normal"
> >> + * applications that open files won't be affected by and won't themselves
> >> + * affect the share reservations.
> >>   */
> >> -static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> >> +static int
> >> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> >>  {
> >> -     /* FLOCK locks referring to the same filp do not conflict with
> >> +     unsigned char caller_type = caller_fl->fl_type;
> >> +     unsigned char sys_type = sys_fl->fl_type;
> >> +     fmode_t caller_fmode = caller_fl->fl_file->f_mode;
> >> +     fmode_t sys_fmode = sys_fl->fl_file->f_mode;
> >> +
> >> +     /* they can only conflict if they're both LOCK_MAND */
> >> +     if (!(caller_type & LOCK_MAND) || !(sys_type & LOCK_MAND))
> >> +             return 0;
> >> +
> >> +     if (!(caller_type & LOCK_READ) && (sys_fmode & FMODE_READ))
> >> +             return 1;
> >> +     if (!(caller_type & LOCK_WRITE) && (sys_fmode & FMODE_WRITE))
> >> +             return 1;
> >> +     if (!(sys_type & LOCK_READ) && (caller_fmode & FMODE_READ))
> >> +             return 1;
> >> +     if (!(sys_type & LOCK_WRITE) && (caller_fmode & FMODE_WRITE))
> >> +             return 1;
> >> +
> >> +     return 0;
> >> +}
> >> +
> >> +/*
> >> + * Determine if lock sys_fl blocks lock caller_fl. FLOCK specific checking
> >> + * before calling the locks_conflict(). Boolean is_mand indicates whether
> >> + * we should use a share reservation scheme or not.
> >> + */
> >> +static int
> >> +flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl,
> >> +                  bool is_mand)
> >
> > I'm not sure you really need to add this new is_mand bool. Won't that
> > be equivalent to (caller_fl->fl_type & LOCK_MAND)?
> 
> This function is already used by flock system call that can pass
> LOCK_MAND flag to caller_fl->fl_type. I don't want to affect existing
> flock behavior by introduing new denylocking strategy - so, we need to
> let flock_locks_conflict function know if we are in flock or open
> codepath - in open codepath it will call locks_mand_conflict to check
> if there is any other open that prevents us.
> 

Right, but if you move to a mount option for this, then enforcing these
locks in the flock() codepath should be ok. It seems reasonable that
anyone who wants enforcement of O_DENY* would want to enforce LOCK_MAND
locks as well.

-- 
Jeff Layton <jlayton@redhat.com>
