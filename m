Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:55996 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab3CKS52 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2013 14:57:28 -0400
MIME-Version: 1.0
In-Reply-To: <20130311144609.2ba86964@corrin.poochiereds.net>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-3-git-send-email-piastry@etersoft.ru>
	<20130311144609.2ba86964@corrin.poochiereds.net>
Date: Mon, 11 Mar 2013 22:57:27 +0400
Message-ID: <CAKywueTEXOH3s0z2X7e=QugJaQAZ6JPoaYmYPnFLHMOTC7_y4w@mail.gmail.com>
Subject: Re: [PATCH v3 2/7] vfs: Add O_DENYREAD/WRITE flags support for open syscall
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/3/11 Jeff Layton <jlayton@redhat.com>:
> On Thu, 28 Feb 2013 19:25:28 +0400
> Pavel Shilovsky <piastry@etersoft.ru> wrote:
>
>> If O_DENYMAND flag is specified, O_DENYREAD/WRITE/MAND flags are
>> translated to flock's flags:
>>
>> !O_DENYREAD  -> LOCK_READ
>> !O_DENYWRITE -> LOCK_WRITE
>> O_DENYMAND   -> LOCK_MAND
>>
>> and set through flock_lock_file on a file.
>>
>> This change affects opens that use O_DENYMAND flag - all other
>> native Linux opens don't care about these flags. It allow us to
>> enable this feature for applications that need it (e.g. NFS and
>> Samba servers that export the same directory for Windows clients,
>> or Wine applications that access the same files simultaneously).
>>
>> Create codepath is slightly changed to prevent data races on
>> newely created files: when open with O_CREAT can return with -ETXTBSY
>> error for successfully created files due to a deny lock set by
>> another task.
>>
>> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
>> ---
>>  fs/locks.c         | 116 +++++++++++++++++++++++++++++++++++++++++++++++------
>>  fs/namei.c         |  44 ++++++++++++++++++--
>>  include/linux/fs.h |   6 +++
>>  3 files changed, 151 insertions(+), 15 deletions(-)
>>
>> diff --git a/fs/locks.c b/fs/locks.c
>> index a94e331..0cc7d1b 100644
>> --- a/fs/locks.c
>> +++ b/fs/locks.c
>> @@ -605,20 +605,81 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
>>       return (locks_conflict(caller_fl, sys_fl));
>>  }
>>
>> -/* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
>> - * checking before calling the locks_conflict().
>> +static unsigned int
>> +deny_flags_to_cmd(unsigned int flags)
>> +{
>> +     unsigned int cmd = LOCK_MAND;
>> +
>> +     if (!(flags & O_DENYREAD))
>> +             cmd |= LOCK_READ;
>> +     if (!(flags & O_DENYWRITE))
>> +             cmd |= LOCK_WRITE;
>> +
>> +     return cmd;
>> +}
>> +
>> +/*
>> + * locks_mand_conflict - Determine if there's a share reservation conflict
>> + * @caller_fl: lock we're attempting to acquire
>> + * @sys_fl: lock already present on system that we're checking against
>> + *
>> + * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
>> + * tell us whether the reservation allows other readers and writers.
>> + *
>> + * We only check against other LOCK_MAND locks, so applications that want to
>> + * use share mode locking will only conflict against one another. "normal"
>> + * applications that open files won't be affected by and won't themselves
>> + * affect the share reservations.
>>   */
>> -static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
>> +static int
>> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
>>  {
>> -     /* FLOCK locks referring to the same filp do not conflict with
>> +     unsigned char caller_type = caller_fl->fl_type;
>> +     unsigned char sys_type = sys_fl->fl_type;
>> +     fmode_t caller_fmode = caller_fl->fl_file->f_mode;
>> +     fmode_t sys_fmode = sys_fl->fl_file->f_mode;
>> +
>> +     /* they can only conflict if they're both LOCK_MAND */
>> +     if (!(caller_type & LOCK_MAND) || !(sys_type & LOCK_MAND))
>> +             return 0;
>> +
>> +     if (!(caller_type & LOCK_READ) && (sys_fmode & FMODE_READ))
>> +             return 1;
>> +     if (!(caller_type & LOCK_WRITE) && (sys_fmode & FMODE_WRITE))
>> +             return 1;
>> +     if (!(sys_type & LOCK_READ) && (caller_fmode & FMODE_READ))
>> +             return 1;
>> +     if (!(sys_type & LOCK_WRITE) && (caller_fmode & FMODE_WRITE))
>> +             return 1;
>> +
>> +     return 0;
>> +}
>> +
>> +/*
>> + * Determine if lock sys_fl blocks lock caller_fl. FLOCK specific checking
>> + * before calling the locks_conflict(). Boolean is_mand indicates whether
>> + * we should use a share reservation scheme or not.
>> + */
>> +static int
>> +flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl,
>> +                  bool is_mand)
>
> I'm not sure you really need to add this new is_mand bool. Won't that
> be equivalent to (caller_fl->fl_type & LOCK_MAND)?

This function is already used by flock system call that can pass
LOCK_MAND flag to caller_fl->fl_type. I don't want to affect existing
flock behavior by introduing new denylocking strategy - so, we need to
let flock_locks_conflict function know if we are in flock or open
codepath - in open codepath it will call locks_mand_conflict to check
if there is any other open that prevents us.

>
>> +{
>> +     /*
>> +      * FLOCK locks referring to the same filp do not conflict with
>>        * each other.
>>        */
>> -     if (!IS_FLOCK(sys_fl) || (caller_fl->fl_file == sys_fl->fl_file))
>> -             return (0);
>> -     if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
>> +     if (!IS_FLOCK(sys_fl))
>> +             return 0;
>> +     if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND)) {
>> +             if (is_mand)
>> +                     return locks_mand_conflict(caller_fl, sys_fl);
>> +             else
>> +                     return 0;
>> +     }
>> +     if (caller_fl->fl_file == sys_fl->fl_file)
>>               return 0;
>>
>> -     return (locks_conflict(caller_fl, sys_fl));
>> +     return locks_conflict(caller_fl, sys_fl);
>>  }
>>
>>  void
>> @@ -697,14 +758,19 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
>>       return 0;
>>  }
>>
>> -/* Try to create a FLOCK lock on filp. We always insert new FLOCK locks
>> +/*
>> + * Try to create a FLOCK lock on filp. We always insert new FLOCK locks
>>   * after any leases, but before any posix locks.
>>   *
>>   * Note that if called with an FL_EXISTS argument, the caller may determine
>>   * whether or not a lock was successfully freed by testing the return
>>   * value for -ENOENT.
>> + *
>> + * Take @is_conflict callback that determines how to check if locks have
>> + * conflicts or not.
>>   */
>> -static int flock_lock_file(struct file *filp, struct file_lock *request)
>> +static int
>> +flock_lock_file(struct file *filp, struct file_lock *request, bool is_mand)
>
> Ditto here on the is_mand bool. I think you can determine that from
> request->fl_type. Right?

The same suggestions are applied to this place too.

>
>>  {
>>       struct file_lock *new_fl = NULL;
>>       struct file_lock **before;
>> @@ -760,7 +826,7 @@ find_conflict:
>>                       break;
>>               if (IS_LEASE(fl))
>>                       continue;
>> -             if (!flock_locks_conflict(request, fl))
>> +             if (!flock_locks_conflict(request, fl, is_mand))
>>                       continue;
>>               error = -EAGAIN;
>>               if (!(request->fl_flags & FL_SLEEP))
>> @@ -783,6 +849,32 @@ out:
>>       return error;
>>  }
>>
>> +/*
>> + * Determine if a file is allowed to be opened with specified access and deny
>> + * modes. Lock the file and return 0 if checks passed, otherwise return a error
>> + * code.
>> + */
>> +int
>> +deny_lock_file(struct file *filp)
>> +{
>> +     struct file_lock *lock;
>> +     int error = 0;
>> +
>> +     if (!(filp->f_flags & O_DENYMAND))
>> +             return error;
>> +
>> +     error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
>> +     if (error)
>> +             return error;
>> +
>> +     error = flock_lock_file(filp, lock, true);
>> +     if (error == -EAGAIN)
>> +             error = -ETXTBSY;
>> +
>
> I think EBUSY would be a better return code here. ETXTBSY is returned
> in more specific circumstances -- mostly when you're opening a file for
> write that is being executed.

Yes, I agree. This work was done before the discussion in linux-cifs@
about a error code for STATUS_SHARING_VIOLATION.

>
>> +     locks_free_lock(lock);
>> +     return error;
>> +}
>> +
>>  static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
>>  {
>>       struct file_lock *fl;
>> @@ -1589,7 +1681,7 @@ int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
>>       int error;
>>       might_sleep();
>>       for (;;) {
>> -             error = flock_lock_file(filp, fl);
>> +             error = flock_lock_file(filp, fl, false);
>>               if (error != FILE_LOCK_DEFERRED)
>>                       break;
>>               error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
>> diff --git a/fs/namei.c b/fs/namei.c
>> index 43a97ee..c1f7e08 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -2559,9 +2559,14 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
>>        * here.
>>        */
>>       error = may_open(&file->f_path, acc_mode, open_flag);
>> -     if (error)
>> +     if (error) {
>>               fput(file);
>> +             goto out;
>> +     }
>>
>> +     error = deny_lock_file(file);
>> +     if (error)
>> +             fput(file);
>>  out:
>>       dput(dentry);
>>       return error;
>> @@ -2771,9 +2776,9 @@ retry_lookup:
>>       }
>>       mutex_lock(&dir->d_inode->i_mutex);
>>       error = lookup_open(nd, path, file, op, got_write, opened);
>> -     mutex_unlock(&dir->d_inode->i_mutex);
>>
>>       if (error <= 0) {
>> +             mutex_unlock(&dir->d_inode->i_mutex);
>>               if (error)
>>                       goto out;
>>
>> @@ -2791,8 +2796,32 @@ retry_lookup:
>>               will_truncate = false;
>>               acc_mode = MAY_OPEN;
>>               path_to_nameidata(path, nd);
>> -             goto finish_open_created;
>> +
>> +             /*
>> +              * Unlock parent i_mutex later when the open finishes - prevent
>> +              * races when a file can be locked with a deny lock by another
>> +              * task that opens the file.
>> +              */
>> +             error = may_open(&nd->path, acc_mode, open_flag);
>> +             if (error) {
>> +                     mutex_unlock(&dir->d_inode->i_mutex);
>> +                     goto out;
>> +             }
>> +             file->f_path.mnt = nd->path.mnt;
>> +             error = finish_open(file, nd->path.dentry, NULL, opened);
>> +             if (error) {
>> +                     mutex_unlock(&dir->d_inode->i_mutex);
>> +                     if (error == -EOPENSTALE)
>> +                             goto stale_open;
>> +                     goto out;
>> +             }
>> +             error = deny_lock_file(file);
>> +             mutex_unlock(&dir->d_inode->i_mutex);
>> +             if (error)
>> +                     goto exit_fput;
>> +             goto opened;
>>       }
>> +     mutex_unlock(&dir->d_inode->i_mutex);
>>
>>       /*
>>        * create/update audit record if it already exists.
>> @@ -2885,6 +2914,15 @@ finish_open_created:
>>                       goto stale_open;
>>               goto out;
>>       }
>> +     /*
>> +      * Lock parent i_mutex to prevent races with deny locks on newely
>> +      * created files.
>> +      */
>> +     mutex_lock(&dir->d_inode->i_mutex);
>> +     error = deny_lock_file(file);
>> +     mutex_unlock(&dir->d_inode->i_mutex);
>> +     if (error)
>> +             goto exit_fput;
>>  opened:
>>       error = open_check_o_direct(file);
>>       if (error)
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 7617ee0..347e1de 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1005,6 +1005,7 @@ extern int lease_modify(struct file_lock **, int);
>>  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
>>  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
>>  extern void locks_delete_block(struct file_lock *waiter);
>> +extern int deny_lock_file(struct file *);
>>  extern void lock_flocks(void);
>>  extern void unlock_flocks(void);
>>  #else /* !CONFIG_FILE_LOCKING */
>> @@ -1153,6 +1154,11 @@ static inline void locks_delete_block(struct file_lock *waiter)
>>  {
>>  }
>>
>> +static inline int deny_lock_file(struct file *filp)
>> +{
>> +     return 0;
>> +}
>> +
>>  static inline void lock_flocks(void)
>>  {
>>  }
>
>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
Pavel Shilovsky.
