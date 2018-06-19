Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr20125.outbound.protection.outlook.com ([40.107.2.125]:2560
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S937206AbeFSDfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Jun 2018 23:35:10 -0400
Date: Mon, 18 Jun 2018 20:34:51 -0700
From: Andrei Vagin <avagin@virtuozzo.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: Re: [12/24] proc: Add fs_context support to procfs [ver #7]
Message-ID: <20180619033450.GA11639@outlook.office365.com>
References: <152414474815.23902.6952548431423168966.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
In-Reply-To: <152414474815.23902.6952548431423168966.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

Hi David,

We run CRIU tests for vfs/for-next, and today a few of these test failed. I
found that the problem appears after this patch..

https://travis-ci.org/avagin/linux/jobs/393766778

The reproducer is attached. It creates a process in a new set of namespaces
(user, mount, etc) and then this process fails to mount procfs, the mount
syscall returns EBUSY.

666   pipe([3, 4])                      = 0
666   clone(child_stack=0x7ffc23a89400, flags=CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWNET|SIGCHLD) = 667
666   openat(AT_FDCWD, "/proc/667/uid_map", O_WRONLY <unfinished ...>
667   close(4 <unfinished ...>
666   <... openat resumed> )            = 5
666   write(5, "0 100000 100000\n100000 200000 50"..., 36 <unfinished ...>
667   <... close resumed> )             = 0
666   <... write resumed> )             = 36
666   close(5 <unfinished ...>
667   read(3,  <unfinished ...>
666   <... close resumed> )             = 0
666   openat(AT_FDCWD, "/proc/667/gid_map", O_WRONLY) = 5
666   write(5, "0 400000 50000\n50000 500000 1000"..., 35) = 35
666   close(5)                          = 0
666   write(4, " \225\250#", 4)         = 4
667   <... read resumed> " \225\250#", 4) = 4
666   wait4(667,  <unfinished ...>
667   setsid()                          = 1
667   setuid(0)                         = 0
667   setgid(0)                         = 0
667   setgroups(0, NULL)                = 0
667   mount("proc", "/mnt", "proc", MS_MGC_VAL|MS_NOSUID|MS_NODEV|MS_NOEXEC, NULL) = -1 EBUSY (Device or resource busy)

Thanks,
Andrei

On Thu, Apr 19, 2018 at 02:32:28PM +0100, David Howells wrote:
> Add fs_context support to procfs.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/proc/inode.c    |    2 -
>  fs/proc/internal.h |    2 -
>  fs/proc/root.c     |  169 ++++++++++++++++++++++++++++++++++------------------
>  3 files changed, 113 insertions(+), 60 deletions(-)
> 
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index 0b13cf6eb6d7..7aa86dd65ba8 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -128,7 +128,7 @@ const struct super_operations proc_sops = {
>  	.drop_inode	= generic_delete_inode,
>  	.evict_inode	= proc_evict_inode,
>  	.statfs		= simple_statfs,
> -	.remount_fs	= proc_remount,
> +	.reconfigure	= proc_reconfigure,
>  	.show_options	= proc_show_options,
>  };
>  
> diff --git a/fs/proc/internal.h b/fs/proc/internal.h
> index 3182e1b636d3..a5ab9504768a 100644
> --- a/fs/proc/internal.h
> +++ b/fs/proc/internal.h
> @@ -254,7 +254,7 @@ static inline void proc_tty_init(void) {}
>  extern struct proc_dir_entry proc_root;
>  
>  extern void proc_self_init(void);
> -extern int proc_remount(struct super_block *, int *, char *, size_t);
> +extern int proc_reconfigure(struct super_block *, struct fs_context *);
>  
>  /*
>   * task_[no]mmu.c
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 2fbc177f37a8..e6bd31fbc714 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -19,14 +19,24 @@
>  #include <linux/module.h>
>  #include <linux/bitops.h>
>  #include <linux/user_namespace.h>
> +#include <linux/fs_context.h>
>  #include <linux/mount.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/parser.h>
>  #include <linux/cred.h>
>  #include <linux/magic.h>
> +#include <linux/slab.h>
>  
>  #include "internal.h"
>  
> +struct proc_fs_context {
> +	struct fs_context	fc;
> +	struct pid_namespace	*pid_ns;
> +	unsigned long		mask;
> +	int			hidepid;
> +	int			gid;
> +};
> +
>  enum {
>  	Opt_gid, Opt_hidepid, Opt_err,
>  };
> @@ -37,56 +47,60 @@ static const match_table_t tokens = {
>  	{Opt_err, NULL},
>  };
>  
> -static int proc_parse_options(char *options, struct pid_namespace *pid)
> +static int proc_parse_option(struct fs_context *fc, char *opt, size_t len)
>  {
> -	char *p;
> +	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
>  	substring_t args[MAX_OPT_ARGS];
> -	int option;
> -
> -	if (!options)
> -		return 1;
> -
> -	while ((p = strsep(&options, ",")) != NULL) {
> -		int token;
> -		if (!*p)
> -			continue;
> -
> -		args[0].to = args[0].from = NULL;
> -		token = match_token(p, tokens, args);
> -		switch (token) {
> -		case Opt_gid:
> -			if (match_int(&args[0], &option))
> -				return 0;
> -			pid->pid_gid = make_kgid(current_user_ns(), option);
> -			break;
> -		case Opt_hidepid:
> -			if (match_int(&args[0], &option))
> -				return 0;
> -			if (option < HIDEPID_OFF ||
> -			    option > HIDEPID_INVISIBLE) {
> -				pr_err("proc: hidepid value must be between 0 and 2.\n");
> -				return 0;
> -			}
> -			pid->hide_pid = option;
> -			break;
> -		default:
> -			pr_err("proc: unrecognized mount option \"%s\" "
> -			       "or missing value\n", p);
> -			return 0;
> +	int token;
> +	
> +	args[0].to = args[0].from = NULL;
> +	token = match_token(opt, tokens, args);
> +	switch (token) {
> +	case Opt_gid:
> +		if (match_int(&args[0], &ctx->gid))
> +			return -EINVAL;
> +		break;
> +
> +	case Opt_hidepid:
> +		if (match_int(&args[0], &ctx->hidepid))
> +			return -EINVAL;
> +		if (ctx->hidepid < HIDEPID_OFF ||
> +		    ctx->hidepid > HIDEPID_INVISIBLE) {
> +			pr_err("proc: hidepid value must be between 0 and 2.\n");
> +			return -EINVAL;
>  		}
> +		break;
> +
> +	default:
> +		pr_err("proc: unrecognized mount option \"%s\" or missing value\n",
> +		       opt);
> +		return -EINVAL;
>  	}
>  
> -	return 1;
> +	ctx->mask |= 1 << token;
> +	return 0;
> +}
> +
> +static void proc_set_options(struct super_block *s,
> +			     struct fs_context *fc,
> +			     struct pid_namespace *pid_ns,
> +			     struct user_namespace *user_ns)
> +{
> +	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
> +
> +	if (ctx->mask & (1 << Opt_gid))
> +		pid_ns->pid_gid = make_kgid(user_ns, ctx->gid);
> +	if (ctx->mask & (1 << Opt_hidepid))
> +		pid_ns->hide_pid = ctx->hidepid;
>  }
>  
> -static int proc_fill_super(struct super_block *s, void *data, size_t data_size, int silent)
> +static int proc_fill_super(struct super_block *s, struct fs_context *fc)
>  {
> -	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
> +	struct pid_namespace *pid_ns = get_pid_ns(s->s_fs_info);
>  	struct inode *root_inode;
>  	int ret;
>  
> -	if (!proc_parse_options(data, ns))
> -		return -EINVAL;
> +	proc_set_options(s, fc, pid_ns, current_user_ns());
>  
>  	/* User space would break if executables or devices appear on proc */
>  	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
> @@ -103,7 +117,7 @@ static int proc_fill_super(struct super_block *s, void *data, size_t data_size,
>  	 * top of it
>  	 */
>  	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
> -	
> +
>  	pde_get(&proc_root);
>  	root_inode = proc_get_inode(s, &proc_root);
>  	if (!root_inode) {
> @@ -124,30 +138,46 @@ static int proc_fill_super(struct super_block *s, void *data, size_t data_size,
>  	return proc_setup_thread_self(s);
>  }
>  
> -int proc_remount(struct super_block *sb, int *flags,
> -		 char *data, size_t data_size)
> +int proc_reconfigure(struct super_block *sb, struct fs_context *fc)
>  {
>  	struct pid_namespace *pid = sb->s_fs_info;
>  
>  	sync_filesystem(sb);
> -	return !proc_parse_options(data, pid);
> +
> +	if (fc)
> +		proc_set_options(sb, fc, pid, current_user_ns());
> +	return 0;
>  }
>  
> -static struct dentry *proc_mount(struct file_system_type *fs_type,
> -				 int flags, const char *dev_name,
> -				 void *data, size_t data_size)
> +static int proc_get_tree(struct fs_context *fc)
>  {
> -	struct pid_namespace *ns;
> +	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
>  
> -	if (flags & SB_KERNMOUNT) {
> -		ns = data;
> -		data = NULL;
> -	} else {
> -		ns = task_active_pid_ns(current);
> -	}
> +	ctx->fc.s_fs_info = ctx->pid_ns;
> +	return vfs_get_super(fc, vfs_get_keyed_super, proc_fill_super);
> +}
>  
> -	return mount_ns(fs_type, flags, data, data_size, ns, ns->user_ns,
> -			proc_fill_super);
> +static void proc_fs_context_free(struct fs_context *fc)
> +{
> +	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
> +
> +	if (ctx->pid_ns)
> +		put_pid_ns(ctx->pid_ns);
> +}
> +
> +static const struct fs_context_operations proc_fs_context_ops = {
> +	.free		= proc_fs_context_free,
> +	.parse_option	= proc_parse_option,
> +	.get_tree	= proc_get_tree,
> +};
> +
> +static int proc_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
> +{
> +	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
> +
> +	ctx->pid_ns = get_pid_ns(task_active_pid_ns(current));
> +	ctx->fc.ops = &proc_fs_context_ops;
> +	return 0;
>  }
>  
>  static void proc_kill_sb(struct super_block *sb)
> @@ -165,7 +195,8 @@ static void proc_kill_sb(struct super_block *sb)
>  
>  static struct file_system_type proc_fs_type = {
>  	.name		= "proc",
> -	.mount		= proc_mount,
> +	.fs_context_size	= sizeof(struct proc_fs_context),
> +	.init_fs_context	= proc_init_fs_context,
>  	.kill_sb	= proc_kill_sb,
>  	.fs_flags	= FS_USERNS_MOUNT,
>  };
> @@ -205,7 +236,7 @@ static struct dentry *proc_root_lookup(struct inode * dir, struct dentry * dentr
>  {
>  	if (!proc_pid_lookup(dir, dentry, flags))
>  		return NULL;
> -	
> +
>  	return proc_lookup(dir, dentry, flags);
>  }
>  
> @@ -259,9 +290,31 @@ struct proc_dir_entry proc_root = {
>  
>  int pid_ns_prepare_proc(struct pid_namespace *ns)
>  {
> +	struct proc_fs_context *ctx;
> +	struct fs_context *fc;
>  	struct vfsmount *mnt;
> +	int ret;
> +
> +	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0,
> +				FS_CONTEXT_FOR_KERNEL_MOUNT);
> +	if (IS_ERR(fc))
> +		return PTR_ERR(fc);
> +
> +	ctx = container_of(fc, struct proc_fs_context, fc);
> +	if (ctx->pid_ns != ns) {
> +		put_pid_ns(ctx->pid_ns);
> +		get_pid_ns(ns);
> +		ctx->pid_ns = ns;
> +	}
> +
> +	ret = vfs_get_tree(fc);
> +	if (ret < 0) {
> +		put_fs_context(fc);
> +		return ret;
> +	}
>  
> -	mnt = kern_mount_data(&proc_fs_type, ns, 0);
> +	mnt = vfs_create_mount(fc);
> +	put_fs_context(fc);
>  	if (IS_ERR(mnt))
>  		return PTR_ERR(mnt);
>  

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="test.c"

#define _GNU_SOURCE
#include <sys/types.h>
#include <sched.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <grp.h>
#include <linux/limits.h>


#define NS_STACK_SIZE	4096

#define __stack_aligned__	__attribute__((aligned(16)))

/* All arguments should be above stack, because it grows down */
struct ns_exec_args {
	char stack[NS_STACK_SIZE] __stack_aligned__;
	char stack_ptr[0];
	int pfd[2];
};

static int ns_exec(void *_arg)
{
	struct ns_exec_args *args = (struct ns_exec_args *) _arg;
	int ret;

	close(args->pfd[1]);
	if (read(args->pfd[0], &ret, sizeof(ret)) != sizeof(ret))
		return -1;

	setsid();

	if (setuid(0) || setgid(0) || setgroups(0, NULL)) {
		fprintf(stderr, "set*id failed: %m\n");
		return -1;
	}

	if (mount("proc", "/mnt", "proc", MS_MGC_VAL | MS_NOSUID | MS_NOEXEC | MS_NODEV, NULL)) {
		fprintf(stderr, "mount(/proc) failed: %m\n");
		return -1;
	}

	return 0;
}

#define UID_MAP "0 100000 100000\n100000 200000 50000"
#define GID_MAP "0 400000 50000\n50000 500000 100000"
int main()
{
	pid_t pid;
	int ret, status;
	struct ns_exec_args args;
	int flags;
	char pname[PATH_MAX];
	int fd, pfd[2];

	if (pipe(pfd))
		return 1;

	args.pfd[0] = pfd[0];
	args.pfd[1] = pfd[1];

	flags = CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUTS |
		CLONE_NEWNET | CLONE_NEWIPC | CLONE_NEWUSER | SIGCHLD;

	pid = clone(ns_exec, args.stack_ptr, flags, &args);
	if (pid < 0) {
		fprintf(stderr, "clone() failed: %m\n");
		exit(1);
	}


	snprintf(pname, sizeof(pname), "/proc/%d/uid_map", pid);
	fd = open(pname, O_WRONLY);
	if (fd < 0) {
		fprintf(stderr, "open(%s): %m\n", pname);
		exit(1);
	}
	if (write(fd, UID_MAP, sizeof(UID_MAP)) < 0) {
		fprintf(stderr, "write(" UID_MAP "): %m\n");
		exit(1);
	}
	close(fd);

	snprintf(pname, sizeof(pname), "/proc/%d/gid_map", pid);
	fd = open(pname, O_WRONLY);
	if (fd < 0) {
		fprintf(stderr, "open(%s): %m\n", pname);
		exit(1);
	}
	if (write(fd, GID_MAP, sizeof(GID_MAP)) < 0) {
		fprintf(stderr, "write(" GID_MAP "): %m\n");
		exit(1);
	}
	close(fd);

	if (write(pfd[1], &ret, sizeof(ret)) != sizeof(ret))
		return 1;

	if (waitpid(pid, &status, 0) != pid)
		return 1;
	if (status)
		return 1;

	return 0;
}

--82I3+IH0IqGh5yIs--
