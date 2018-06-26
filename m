Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr60111.outbound.protection.outlook.com ([40.107.6.111]:9159
        "EHLO EUR04-DB3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750919AbeFZGNy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Jun 2018 02:13:54 -0400
Date: Mon, 25 Jun 2018 23:13:22 -0700
From: Andrei Vagin <avagin@virtuozzo.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: Re: [12/24] proc: Add fs_context support to procfs [ver #7]
Message-ID: <20180626061320.GA12548@outlook.office365.com>
References: <152414474815.23902.6952548431423168966.stgit@warthog.procyon.org.uk>
 <20180619033450.GA11639@outlook.office365.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
In-Reply-To: <20180619033450.GA11639@outlook.office365.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2018 at 08:34:50PM -0700, Andrei Vagin wrote:
> Hi David,
> 
> We run CRIU tests for vfs/for-next, and today a few of these test failed. I
> found that the problem appears after this patch..
> 
> >  int pid_ns_prepare_proc(struct pid_namespace *ns)
> >  {
> > +	struct proc_fs_context *ctx;
> > +	struct fs_context *fc;
> >  	struct vfsmount *mnt;
> > +	int ret;
> > +
> > +	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0,
> > +				FS_CONTEXT_FOR_KERNEL_MOUNT);
> > +	if (IS_ERR(fc))
> > +		return PTR_ERR(fc);
> > +
> > +	ctx = container_of(fc, struct proc_fs_context, fc);
> > +	if (ctx->pid_ns != ns) {
> > +		put_pid_ns(ctx->pid_ns);
> > +		get_pid_ns(ns);
> > +		ctx->pid_ns = ns;
> > +	}
> > +
> > +	ret = vfs_get_tree(fc);
> > +	if (ret < 0) {
> > +		put_fs_context(fc);
> > +		return ret;
> > +	}
> >  
> > -	mnt = kern_mount_data(&proc_fs_type, ns, 0);

Here ns->user_ns and get_current_cred()->user_ns are not always equal

> > +	mnt = vfs_create_mount(fc);
> > +	put_fs_context(fc);
> >  	if (IS_ERR(mnt))
> >  		return PTR_ERR(mnt);
> >  

> #define _GNU_SOURCE
> #include <sys/types.h>
> #include <sched.h>
> #include <unistd.h>
> #include <stdio.h>
> #include <sys/mount.h>
> #include <sys/wait.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <stdlib.h>
> #include <grp.h>
> #include <linux/limits.h>
> 
> 
> #define NS_STACK_SIZE	4096
> 
> #define __stack_aligned__	__attribute__((aligned(16)))
> 
> /* All arguments should be above stack, because it grows down */
> struct ns_exec_args {
> 	char stack[NS_STACK_SIZE] __stack_aligned__;
> 	char stack_ptr[0];
> 	int pfd[2];
> };
> 
> static int ns_exec(void *_arg)
> {
> 	struct ns_exec_args *args = (struct ns_exec_args *) _arg;
> 	int ret;
> 
> 	close(args->pfd[1]);
> 	if (read(args->pfd[0], &ret, sizeof(ret)) != sizeof(ret))
> 		return -1;
> 
> 	setsid();
> 
> 	if (setuid(0) || setgid(0) || setgroups(0, NULL)) {
> 		fprintf(stderr, "set*id failed: %m\n");
> 		return -1;
> 	}
> 
> 	if (mount("proc", "/mnt", "proc", MS_MGC_VAL | MS_NOSUID | MS_NOEXEC | MS_NODEV, NULL)) {
> 		fprintf(stderr, "mount(/proc) failed: %m\n");
> 		return -1;
> 	}
> 
> 	return 0;
> }
> 
> #define UID_MAP "0 100000 100000\n100000 200000 50000"
> #define GID_MAP "0 400000 50000\n50000 500000 100000"
> int main()
> {
> 	pid_t pid;
> 	int ret, status;
> 	struct ns_exec_args args;
> 	int flags;
> 	char pname[PATH_MAX];
> 	int fd, pfd[2];
> 
> 	if (pipe(pfd))
> 		return 1;
> 
> 	args.pfd[0] = pfd[0];
> 	args.pfd[1] = pfd[1];
> 
> 	flags = CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUTS |
> 		CLONE_NEWNET | CLONE_NEWIPC | CLONE_NEWUSER | SIGCHLD;
> 
> 	pid = clone(ns_exec, args.stack_ptr, flags, &args);
> 	if (pid < 0) {
> 		fprintf(stderr, "clone() failed: %m\n");
> 		exit(1);
> 	}
> 
> 
> 	snprintf(pname, sizeof(pname), "/proc/%d/uid_map", pid);
> 	fd = open(pname, O_WRONLY);
> 	if (fd < 0) {
> 		fprintf(stderr, "open(%s): %m\n", pname);
> 		exit(1);
> 	}
> 	if (write(fd, UID_MAP, sizeof(UID_MAP)) < 0) {
> 		fprintf(stderr, "write(" UID_MAP "): %m\n");
> 		exit(1);
> 	}
> 	close(fd);
> 
> 	snprintf(pname, sizeof(pname), "/proc/%d/gid_map", pid);
> 	fd = open(pname, O_WRONLY);
> 	if (fd < 0) {
> 		fprintf(stderr, "open(%s): %m\n", pname);
> 		exit(1);
> 	}
> 	if (write(fd, GID_MAP, sizeof(GID_MAP)) < 0) {
> 		fprintf(stderr, "write(" GID_MAP "): %m\n");
> 		exit(1);
> 	}
> 	close(fd);
> 
> 	if (write(pfd[1], &ret, sizeof(ret)) != sizeof(ret))
> 		return 1;
> 
> 	if (waitpid(pid, &status, 0) != pid)
> 		return 1;
> 	if (status)
> 		return 1;
> 
> 	return 0;
> }

