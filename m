Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89709C10F00
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 00:08:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D8ED21738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 00:08:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729625AbfBTAI1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 19:08:27 -0500
Received: from out01.mta.xmission.com ([166.70.13.231]:41197 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728652AbfBTAI1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 19:08:27 -0500
X-Greylist: delayed 26909 seconds by postgrey-1.27 at vger.kernel.org; Tue, 19 Feb 2019 19:08:24 EST
Received: from in02.mta.xmission.com ([166.70.13.52])
        by out01.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8R0-0001D7-Bs; Tue, 19 Feb 2019 09:39:54 -0700
Received: from ip68-227-174-240.om.om.cox.net ([68.227.174.240] helo=x220.xmission.com)
        by in02.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8Qy-0004b0-NL; Tue, 19 Feb 2019 09:39:54 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
        <155024686966.21651.5963892339360034863.stgit@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 10:39:41 -0600
In-Reply-To: <155024686966.21651.5963892339360034863.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Fri, 15 Feb 2019 16:07:49 +0000")
Message-ID: <87tvgzwx4i.fsf@xmission.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1gw8Qy-0004b0-NL;;;mid=<87tvgzwx4i.fsf@xmission.com>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.240;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX187cwXq7XKUx3zHO/ypJT7C9+MlGxzGd1w=
X-SA-Exim-Connect-IP: 68.227.174.240
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 04/27] containers: Allow a process to be forked into a container
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

David Howells <dhowells@redhat.com> writes:

> Allow a single process to be forked directly into a container using a new
> syscall, thereby 'booting' the container:
>
> 	pid_t pid = fork_into_container(int container_fd);
>
> This process will be the 'init' process of the container.
>
> Further attempts to fork into the container will be rejected.

So you are breaking nsenter, and it's like.

There are no technical reasons to disallow this, and may good practical
reasons to allow this.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 
>  arch/x86/entry/syscalls/syscall_64.tbl |    1 
>  arch/x86/ia32/sys_ia32.c               |    2 -
>  include/linux/cred.h                   |    3 +
>  include/linux/nsproxy.h                |    7 ++
>  include/linux/sched/task.h             |    3 +
>  include/linux/syscalls.h               |    1 
>  kernel/cred.c                          |   45 +++++++++++++
>  kernel/fork.c                          |  110 ++++++++++++++++++++++++++------
>  kernel/nsproxy.c                       |   11 +++
>  kernel/sys_ni.c                        |    1 
>  11 files changed, 157 insertions(+), 28 deletions(-)
>
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 3564814a5d21..8666693510f9 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -408,3 +408,4 @@
>  394	i386	mount_notify		sys_mount_notify		__ia32_sys_mount_notify
>  395	i386	sb_notify		sys_sb_notify			__ia32_sys_sb_notify
>  396	i386	container_create	sys_container_create		__ia32_sys_container_create
> +397	i386	fork_into_container	sys_fork_into_container		__ia32_sys_fork_into_container
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index aa6cccbe5271..d40d4790fcb2 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -353,6 +353,7 @@
>  342	common	mount_notify		__x64_sys_mount_notify
>  343	common	sb_notify		__x64_sys_sb_notify
>  344	common	container_create	__x64_sys_container_create
> +345	common	fork_into_container	__x64_sys_fork_into_container
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
> index a43212036257..080d9e21b697 100644
> --- a/arch/x86/ia32/sys_ia32.c
> +++ b/arch/x86/ia32/sys_ia32.c
> @@ -238,5 +238,5 @@ COMPAT_SYSCALL_DEFINE5(x86_clone, unsigned long, clone_flags,
>  		       unsigned long, tls_val, int __user *, child_tidptr)
>  {
>  	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr,
> -			tls_val);
> +			tls_val, NULL);
>  }
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 4907c9df86b3..357e743d5d4a 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -23,6 +23,7 @@
>  
>  struct cred;
>  struct inode;
> +struct container;
>  
>  /*
>   * COW Supplementary groups list
> @@ -155,7 +156,7 @@ struct cred {
>  
>  extern void __put_cred(struct cred *);
>  extern void exit_creds(struct task_struct *);
> -extern int copy_creds(struct task_struct *, unsigned long);
> +extern int copy_creds(struct task_struct *, unsigned long, struct container *);
>  extern const struct cred *get_task_cred(struct task_struct *);
>  extern struct cred *cred_alloc_blank(void);
>  extern struct cred *prepare_creds(void);
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 2ae1b1a4d84d..81838ae24a92 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -11,6 +11,7 @@ struct ipc_namespace;
>  struct pid_namespace;
>  struct cgroup_namespace;
>  struct fs_struct;
> +struct container;
>  
>  /*
>   * A structure to contain pointers to all per-process
> @@ -63,9 +64,13 @@ extern struct nsproxy init_nsproxy;
>   *         * /
>   *     task_unlock(task);
>   *
> + *  4. Container namespaces are set at container creation and cannot be
> + *     changed.
> + *
>   */
>  
> -int copy_namespaces(unsigned long flags, struct task_struct *tsk);
> +int copy_namespaces(unsigned long flags, struct task_struct *tsk,
> +		    struct container *dest_container);
>  void exit_task_namespaces(struct task_struct *tsk);
>  void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
>  void free_nsproxy(struct nsproxy *ns);
> diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
> index 44c6f15800ff..bdff71b0fb66 100644
> --- a/include/linux/sched/task.h
> +++ b/include/linux/sched/task.h
> @@ -73,7 +73,8 @@ extern void do_group_exit(int);
>  extern void exit_files(struct task_struct *);
>  extern void exit_itimers(struct signal_struct *);
>  
> -extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
> +extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *,
> +		     int __user *, unsigned long, struct container *);
>  extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
>  struct task_struct *fork_idle(int);
>  extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index dac42098c2dd..15e5cc704df3 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -946,6 +946,7 @@ asmlinkage long sys_sb_notify(int dfd, const char __user *path,
>  asmlinkage long sys_container_create(const char __user *name, unsigned int flags,
>  				     unsigned long spare3, unsigned long spare4,
>  				     unsigned long spare5);
> +asmlinkage long sys_fork_into_container(int containerfd);
>  
>  /*
>   * Architecture-specific system calls
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 21f4a97085b4..f0ee5cec533d 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -313,6 +313,43 @@ struct cred *prepare_exec_creds(void)
>  	return new;
>  }
>  
> +/*
> + * Handle forking a process into a container.
> + */
> +static struct cred *copy_container_creds(struct container *dest_container)
> +{
> +	struct cred *new;
> +
> +	validate_process_creds();
> +
> +	new = kmem_cache_alloc(cred_jar, GFP_KERNEL);
> +	if (!new)
> +		return NULL;
> +
> +	kdebug("prepare_creds() alloc %p", new);
> +
> +	memcpy(new, dest_container->cred, sizeof(struct cred));
> +
> +	atomic_set(&new->usage, 1);
> +	set_cred_subscribers(new, 0);
> +	get_group_info(new->group_info);
> +	get_uid(new->user);
> +	get_user_ns(new->user_ns);
> +
> +#ifdef CONFIG_SECURITY
> +	new->security = NULL;
> +#endif
> +
> +	if (security_prepare_creds(new, dest_container->cred, GFP_KERNEL) < 0)
> +		goto error;
> +	validate_creds(new);
> +	return new;
> +
> +error:
> +	abort_creds(new);
> +	return NULL;
> +}
> +
>  /*
>   * Copy credentials for the new process created by fork()
>   *
> @@ -322,7 +359,8 @@ struct cred *prepare_exec_creds(void)
>   * The new process gets the current process's subjective credentials as its
>   * objective and subjective credentials
>   */
> -int copy_creds(struct task_struct *p, unsigned long clone_flags)
> +int copy_creds(struct task_struct *p, unsigned long clone_flags,
> +	       struct container *dest_container)
>  {
>  	struct cred *new;
>  	int ret;
> @@ -343,7 +381,10 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
>  		return 0;
>  	}
>  
> -	new = prepare_creds();
> +	if (dest_container)
> +		new = copy_container_creds(dest_container);
> +	else
> +		new = prepare_creds();
>  	if (!new)
>  		return -ENOMEM;
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 009cf7e63894..71401deb4434 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1385,9 +1385,33 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
>  	return retval;
>  }
>  
> -static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
> +static int copy_fs(unsigned long clone_flags, struct task_struct *tsk,
> +		   struct container *dest_container)
>  {
>  	struct fs_struct *fs = current->fs;
> +
> +#ifdef CONFIG_CONTAINERS
> +	if (dest_container) {
> +		fs = kmem_cache_alloc(fs_cachep, GFP_KERNEL);
> +		if (!fs)
> +			return -ENOMEM;
> +
> +		fs->users = 1;
> +		fs->in_exec = 0;
> +		spin_lock_init(&fs->lock);
> +		seqcount_init(&fs->seq);
> +		fs->umask = 0022;
> +
> +		spin_lock(&dest_container->lock);
> +		fs->pwd = fs->root = dest_container->root;
> +		path_get(&fs->root);
> +		path_get(&fs->pwd);
> +		spin_unlock(&dest_container->lock);
> +		tsk->fs = fs;
> +		return 0;
> +	}
> +#endif
> +
>  	if (clone_flags & CLONE_FS) {
>  		/* tsk->fs is already what we want */
>  		spin_lock(&fs->lock);
> @@ -1679,7 +1703,8 @@ static __latent_entropy struct task_struct *copy_process(
>  					struct pid *pid,
>  					int trace,
>  					unsigned long tls,
> -					int node)
> +					int node,
> +					struct container *dest_container)
>  {
>  	int retval;
>  	struct task_struct *p;
> @@ -1783,7 +1808,7 @@ static __latent_entropy struct task_struct *copy_process(
>  	}
>  	current->flags &= ~PF_NPROC_EXCEEDED;
>  
> -	retval = copy_creds(p, clone_flags);
> +	retval = copy_creds(p, clone_flags, dest_container);
>  	if (retval < 0)
>  		goto bad_fork_free;
>  
> @@ -1905,7 +1930,7 @@ static __latent_entropy struct task_struct *copy_process(
>  	retval = copy_files(clone_flags, p);
>  	if (retval)
>  		goto bad_fork_cleanup_semundo;
> -	retval = copy_fs(clone_flags, p);
> +	retval = copy_fs(clone_flags, p, dest_container);
>  	if (retval)
>  		goto bad_fork_cleanup_files;
>  	retval = copy_sighand(clone_flags, p);
> @@ -1917,15 +1942,15 @@ static __latent_entropy struct task_struct *copy_process(
>  	retval = copy_mm(clone_flags, p);
>  	if (retval)
>  		goto bad_fork_cleanup_signal;
> -	retval = copy_namespaces(clone_flags, p);
> +	retval = copy_container(clone_flags, p, dest_container);
>  	if (retval)
>  		goto bad_fork_cleanup_mm;
> -	retval = copy_container(clone_flags, p, NULL);
> +	retval = copy_namespaces(clone_flags, p, dest_container);
>  	if (retval)
> -		goto bad_fork_cleanup_namespaces;
> +		goto bad_fork_cleanup_container;
>  	retval = copy_io(clone_flags, p);
>  	if (retval)
> -		goto bad_fork_cleanup_container;
> +		goto bad_fork_cleanup_namespaces;
>  	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
>  	if (retval)
>  		goto bad_fork_cleanup_io;
> @@ -2124,10 +2149,10 @@ static __latent_entropy struct task_struct *copy_process(
>  bad_fork_cleanup_io:
>  	if (p->io_context)
>  		exit_io_context(p);
> -bad_fork_cleanup_container:
> -	exit_container(p);
>  bad_fork_cleanup_namespaces:
>  	exit_task_namespaces(p);
> +bad_fork_cleanup_container:
> +	exit_container(p);
>  bad_fork_cleanup_mm:
>  	if (p->mm)
>  		mmput(p->mm);
> @@ -2183,7 +2208,7 @@ struct task_struct *fork_idle(int cpu)
>  {
>  	struct task_struct *task;
>  	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0,
> -			    cpu_to_node(cpu));
> +			    cpu_to_node(cpu), NULL);
>  	if (!IS_ERR(task)) {
>  		init_idle_pids(task);
>  		init_idle(task, cpu);
> @@ -2195,15 +2220,16 @@ struct task_struct *fork_idle(int cpu)
>  /*
>   *  Ok, this is the main fork-routine.
>   *
> - * It copies the process, and if successful kick-starts
> - * it and waits for it to finish using the VM if required.
> + * It copies the process into the specified container, and if successful
> + * kick-starts it and waits for it to finish using the VM if required.
>   */
>  long _do_fork(unsigned long clone_flags,
>  	      unsigned long stack_start,
>  	      unsigned long stack_size,
>  	      int __user *parent_tidptr,
>  	      int __user *child_tidptr,
> -	      unsigned long tls)
> +	      unsigned long tls,
> +	      struct container *dest_container)
>  {
>  	struct completion vfork;
>  	struct pid *pid;
> @@ -2229,8 +2255,32 @@ long _do_fork(unsigned long clone_flags,
>  			trace = 0;
>  	}
>  
> +	if (dest_container) {
> +		/* A process spawned into a container doesn't share anything
> +		 * with the parent other than namespaces.
> +		 */
> +		if (clone_flags & (CLONE_CHILD_CLEARTID |
> +				   CLONE_CHILD_SETTID |
> +				   CLONE_FILES |
> +				   CLONE_FS |
> +				   CLONE_IO |
> +				   CLONE_PARENT |
> +				   CLONE_PARENT_SETTID |
> +				   CLONE_PTRACE |
> +				   CLONE_SETTLS |
> +				   CLONE_SIGHAND |
> +				   CLONE_SYSVSEM |
> +				   CLONE_THREAD))
> +			return -EINVAL;
> +
> +		/* However, we do have to let kernel threads borrow a VM. */
> +		if ((clone_flags & CLONE_VM) && current->mm)
> +			return -EINVAL;
> +	}
> +	
>  	p = copy_process(clone_flags, stack_start, stack_size,
> -			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE);
> +			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE,
> +			 dest_container);
>  	add_latent_entropy();
>  
>  	if (IS_ERR(p))
> @@ -2279,7 +2329,7 @@ long do_fork(unsigned long clone_flags,
>  	      int __user *child_tidptr)
>  {
>  	return _do_fork(clone_flags, stack_start, stack_size,
> -			parent_tidptr, child_tidptr, 0);
> +			parent_tidptr, child_tidptr, 0, NULL);
>  }
>  #endif
>  
> @@ -2289,14 +2339,14 @@ long do_fork(unsigned long clone_flags,
>  pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
>  {
>  	return _do_fork(flags|CLONE_VM|CLONE_UNTRACED, (unsigned long)fn,
> -		(unsigned long)arg, NULL, NULL, 0);
> +			(unsigned long)arg, NULL, NULL, 0, NULL);
>  }
>  
>  #ifdef __ARCH_WANT_SYS_FORK
>  SYSCALL_DEFINE0(fork)
>  {
>  #ifdef CONFIG_MMU
> -	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0);
> +	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, NULL);
>  #else
>  	/* can not support in nommu mode */
>  	return -EINVAL;
> @@ -2308,7 +2358,26 @@ SYSCALL_DEFINE0(fork)
>  SYSCALL_DEFINE0(vfork)
>  {
>  	return _do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, 0,
> -			0, NULL, NULL, 0);
> +			0, NULL, NULL, 0, NULL);
> +}
> +#endif
> +
> +#ifdef CONFIG_CONTAINERS
> +SYSCALL_DEFINE1(fork_into_container, int, containerfd)
> +{
> +	struct fd f = fdget(containerfd);
> +	int ret;
> +
> +	if (!f.file)
> +		return -EBADF;
> +	ret = -EINVAL;
> +	if (is_container_file(f.file)) {
> +		struct container *dest_container = f.file->private_data;
> +
> +		ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, dest_container);
> +	}
> +	fdput(f);
> +	return ret;
>  }
>  #endif
>  
> @@ -2336,7 +2405,8 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
>  		 unsigned long, tls)
>  #endif
>  {
> -	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls);
> +	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls,
> +			NULL);
>  }
>  #endif
>  
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 4bb5184b3a80..4031075300a4 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -136,12 +136,19 @@ struct nsproxy *create_new_namespaces(unsigned long flags,
>   * called from clone.  This now handles copy for nsproxy and all
>   * namespaces therein.
>   */
> -int copy_namespaces(unsigned long flags, struct task_struct *tsk)
> +int copy_namespaces(unsigned long flags, struct task_struct *tsk,
> +		    struct container *dest_container)
>  {
>  	struct nsproxy *old_ns = tsk->nsproxy;
>  	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
>  	struct nsproxy *new_ns;
>  
> +	if (dest_container) {
> +		get_nsproxy(dest_container->ns);
> +		tsk->nsproxy = dest_container->ns;
> +		return 0;
> +	}
> +
>  	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
>  			      CLONE_NEWPID | CLONE_NEWNET |
>  			      CLONE_NEWCGROUP)))) {
> @@ -163,7 +170,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  		(CLONE_NEWIPC | CLONE_SYSVSEM)) 
>  		return -EINVAL;
>  
> -	new_ns = create_new_namespaces(flags, tsk->nsproxy, user_ns, tsk->fs);
> +	new_ns = create_new_namespaces(flags, old_ns, user_ns, tsk->fs);
>  	if (IS_ERR(new_ns))
>  		return  PTR_ERR(new_ns);
>  
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index f0455cbb91cf..a23ad529d548 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -144,6 +144,7 @@ COND_SYSCALL(container_create);
>  /* kernel/exit.c */
>  
>  /* kernel/fork.c */
> +COND_SYSCALL(fork_into_container);
>  
>  /* kernel/futex.c */
>  COND_SYSCALL(futex);
