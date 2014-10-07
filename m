Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f51.google.com ([74.125.82.51]:64261 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbaJGRLo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 13:11:44 -0400
MIME-Version: 1.0
In-Reply-To: <1409834323-7171-3-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-3-git-send-email-jlayton@primarydata.com>
Date: Tue, 7 Oct 2014 20:11:42 +0300
Message-ID: <CACE9dm-gEfVnHvESfewAPx1vDSdpUW+za=H_zpA8hJd55AR=tA@mail.gmail.com>
Subject: Re: [PATCH v2 02/17] security: make security_file_set_fowner,
 f_setown and __f_setown void return
From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4 September 2014 15:38, Jeff Layton <jlayton@primarydata.com> wrote:
> security_file_set_fowner always returns 0, so make it f_setown and
> __f_setown void return functions and fix up the error handling in the
> callers.
>
> Cc: linux-security-module@vger.kernel.org
> Cc: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  drivers/net/tun.c           |  4 +---
>  drivers/tty/tty_io.c        |  3 ++-
>  fs/fcntl.c                  | 21 +++++++--------------
>  fs/locks.c                  |  2 +-
>  fs/notify/dnotify/dnotify.c |  8 +-------
>  include/linux/fs.h          |  4 ++--
>  include/linux/security.h    |  8 ++++----
>  net/socket.c                |  3 ++-
>  security/capability.c       |  4 ++--
>  security/security.c         |  2 +-
>  security/selinux/hooks.c    |  4 +---
>  security/smack/smack_lsm.c  |  3 +--
>  12 files changed, 25 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index acaaf6784179..186ce541c657 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -2152,9 +2152,7 @@ static int tun_chr_fasync(int fd, struct file *file, int on)
>                 goto out;
>
>         if (on) {
> -               ret = __f_setown(file, task_pid(current), PIDTYPE_PID, 0);
> -               if (ret)
> -                       goto out;
> +               __f_setown(file, task_pid(current), PIDTYPE_PID, 0);
>                 tfile->flags |= TUN_FASYNC;
>         } else
>                 tfile->flags &= ~TUN_FASYNC;
> diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
> index 8fbad3410c75..aea3b66f7bf2 100644
> --- a/drivers/tty/tty_io.c
> +++ b/drivers/tty/tty_io.c
> @@ -2163,8 +2163,9 @@ static int __tty_fasync(int fd, struct file *filp, int on)
>                 }
>                 get_pid(pid);
>                 spin_unlock_irqrestore(&tty->ctrl_lock, flags);
> -               retval = __f_setown(filp, pid, type, 0);
> +               __f_setown(filp, pid, type, 0);
>                 put_pid(pid);
> +               retval = 0;
>         }
>  out:
>         return retval;
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 22d1c3df61ac..99d440a4a6ba 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -98,26 +98,19 @@ static void f_modown(struct file *filp, struct pid *pid, enum pid_type type,
>         write_unlock_irq(&filp->f_owner.lock);
>  }
>
> -int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
> +void __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
>                 int force)
>  {
> -       int err;
> -
> -       err = security_file_set_fowner(filp);
> -       if (err)
> -               return err;
> -
> +       security_file_set_fowner(filp);
>         f_modown(filp, pid, type, force);
> -       return 0;
>  }
>  EXPORT_SYMBOL(__f_setown);
>
> -int f_setown(struct file *filp, unsigned long arg, int force)
> +void f_setown(struct file *filp, unsigned long arg, int force)
>  {
>         enum pid_type type;
>         struct pid *pid;
>         int who = arg;
> -       int result;
>         type = PIDTYPE_PID;
>         if (who < 0) {
>                 type = PIDTYPE_PGID;
> @@ -125,9 +118,8 @@ int f_setown(struct file *filp, unsigned long arg, int force)
>         }
>         rcu_read_lock();
>         pid = find_vpid(who);
> -       result = __f_setown(filp, pid, type, force);
> +       __f_setown(filp, pid, type, force);
>         rcu_read_unlock();
> -       return result;
>  }
>  EXPORT_SYMBOL(f_setown);
>
> @@ -181,7 +173,7 @@ static int f_setown_ex(struct file *filp, unsigned long arg)
>         if (owner.pid && !pid)
>                 ret = -ESRCH;
>         else
> -               ret = __f_setown(filp, pid, type, 1);
> +                __f_setown(filp, pid, type, 1);
>         rcu_read_unlock();
>
>         return ret;
> @@ -302,7 +294,8 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
>                 force_successful_syscall_return();
>                 break;
>         case F_SETOWN:
> -               err = f_setown(filp, arg, 1);
> +               f_setown(filp, arg, 1);
> +               err = 0;
>                 break;
>         case F_GETOWN_EX:
>                 err = f_getown_ex(filp, arg);
> diff --git a/fs/locks.c b/fs/locks.c
> index d7e15a256f8f..18e87f11a25f 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1776,7 +1776,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
>         if (!fasync_insert_entry(fd, filp, &ret->fl_fasync, new))
>                 new = NULL;
>
> -       error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
> +       __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
>  out_unlock:
>         spin_unlock(&inode->i_lock);
>         if (fl)
> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
> index abc8cbcfe90e..caaaf9dfe353 100644
> --- a/fs/notify/dnotify/dnotify.c
> +++ b/fs/notify/dnotify/dnotify.c
> @@ -346,13 +346,7 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
>                 goto out;
>         }
>
> -       error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
> -       if (error) {
> -               /* if we added, we must shoot */
> -               if (dn_mark == new_dn_mark)
> -                       destroy = 1;
> -               goto out;
> -       }
> +       __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
>
>         error = attach_dn(dn, dn_mark, id, fd, filp, mask);
>         /* !error means that we attached the dn to the dn_mark, so don't free it */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 435e3d9ec5cf..96528f73dda4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1139,8 +1139,8 @@ extern void fasync_free(struct fasync_struct *);
>  /* can be called from interrupts */
>  extern void kill_fasync(struct fasync_struct **, int, int);
>
> -extern int __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
> -extern int f_setown(struct file *filp, unsigned long arg, int force);
> +extern void __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
> +extern void f_setown(struct file *filp, unsigned long arg, int force);
>  extern void f_delown(struct file *filp);
>  extern pid_t f_getown(struct file *filp);
>  extern int send_sigurg(struct fown_struct *fown);
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 623f90e5f38d..b10e7af95d3b 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -1559,7 +1559,7 @@ struct security_operations {
>         int (*file_lock) (struct file *file, unsigned int cmd);
>         int (*file_fcntl) (struct file *file, unsigned int cmd,
>                            unsigned long arg);
> -       int (*file_set_fowner) (struct file *file);
> +       void (*file_set_fowner) (struct file *file);
>         int (*file_send_sigiotask) (struct task_struct *tsk,
>                                     struct fown_struct *fown, int sig);
>         int (*file_receive) (struct file *file);
> @@ -1834,7 +1834,7 @@ int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>                            unsigned long prot);
>  int security_file_lock(struct file *file, unsigned int cmd);
>  int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
> -int security_file_set_fowner(struct file *file);
> +void security_file_set_fowner(struct file *file);
>  int security_file_send_sigiotask(struct task_struct *tsk,
>                                  struct fown_struct *fown, int sig);
>  int security_file_receive(struct file *file);
> @@ -2312,9 +2312,9 @@ static inline int security_file_fcntl(struct file *file, unsigned int cmd,
>         return 0;
>  }
>
> -static inline int security_file_set_fowner(struct file *file)
> +static inline void security_file_set_fowner(struct file *file)
>  {
> -       return 0;
> +       return;
>  }
>
>  static inline int security_file_send_sigiotask(struct task_struct *tsk,
> diff --git a/net/socket.c b/net/socket.c
> index 95ee7d8682e7..769c9671847e 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1069,7 +1069,8 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
>                         err = -EFAULT;
>                         if (get_user(pid, (int __user *)argp))
>                                 break;
> -                       err = f_setown(sock->file, pid, 1);
> +                       f_setown(sock->file, pid, 1);
> +                       err = 0;
>                         break;
>                 case FIOGETOWN:
>                 case SIOCGPGRP:
> diff --git a/security/capability.c b/security/capability.c
> index a74fde6a7468..d68c57a62bcf 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -343,9 +343,9 @@ static int cap_file_fcntl(struct file *file, unsigned int cmd,
>         return 0;
>  }
>
> -static int cap_file_set_fowner(struct file *file)
> +static void cap_file_set_fowner(struct file *file)
>  {
> -       return 0;
> +       return;
>  }
>
>  static int cap_file_send_sigiotask(struct task_struct *tsk,
> diff --git a/security/security.c b/security/security.c
> index e41b1a8d7644..fd301c177d04 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -775,7 +775,7 @@ int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>         return security_ops->file_fcntl(file, cmd, arg);
>  }
>
> -int security_file_set_fowner(struct file *file)
> +void security_file_set_fowner(struct file *file)
>  {
>         return security_ops->file_set_fowner(file);

If file_set_fowner op is now type of "void", how you can actually
return the value?
I think compiler must give error. How could you compile it?

- Dmitry


>  }
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index b0e940497e23..ada0d0bf3463 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3346,14 +3346,12 @@ static int selinux_file_fcntl(struct file *file, unsigned int cmd,
>         return err;
>  }
>
> -static int selinux_file_set_fowner(struct file *file)
> +static void selinux_file_set_fowner(struct file *file)
>  {
>         struct file_security_struct *fsec;
>
>         fsec = file->f_security;
>         fsec->fown_sid = current_sid();
> -
> -       return 0;
>  }
>
>  static int selinux_file_send_sigiotask(struct task_struct *tsk,
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index e6ab307ce86e..69e5635d89e5 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -1390,12 +1390,11 @@ static int smack_mmap_file(struct file *file,
>   * Returns 0
>   * Further research may be required on this one.
>   */
> -static int smack_file_set_fowner(struct file *file)
> +static void smack_file_set_fowner(struct file *file)
>  {
>         struct smack_known *skp = smk_of_current();
>
>         file->f_security = skp->smk_known;
> -       return 0;
>  }
>
>  /**
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,
Dmitry
