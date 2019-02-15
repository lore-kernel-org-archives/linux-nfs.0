Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553FBC10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 17:52:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0871D21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 17:52:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=tycho.nsa.gov header.i=@tycho.nsa.gov header.b="DYlvZqic"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729482AbfBORwn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 12:52:43 -0500
Received: from ucol19pa14.eemsg.mail.mil ([214.24.24.87]:24564 "EHLO
        ucol19pa14.eemsg.mail.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729579AbfBORwm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 12:52:42 -0500
X-Greylist: delayed 708 seconds by postgrey-1.27 at vger.kernel.org; Fri, 15 Feb 2019 12:52:42 EST
X-EEMSG-check-017: 673674681|UCOL19PA14_EEMSG_MP12.csd.disa.mil
X-IronPort-AV: E=Sophos;i="5.58,373,1544486400"; 
   d="scan'208";a="673674681"
Received: from emsm-gh1-uea11.ncsc.mil ([214.29.60.3])
  by ucol19pa14.eemsg.mail.mil with ESMTP/TLS/DHE-RSA-AES256-SHA256; 15 Feb 2019 17:39:36 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=tycho.nsa.gov; i=@tycho.nsa.gov; q=dns/txt;
  s=tycho.nsa.gov; t=1550252376; x=1581788376;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=ERBrSQG797Vrck3+kKL0c5QQwfSNaI5EDX6+BFnSdh8=;
  b=DYlvZqic4gzxYQT3D08IpT+sP2NZIo43zp+sYcq+3vAsy9b1JgQ26nnH
   1EDvxSxomc00XxpBAry/i3FBDtd9WY3nWiufdmYuCDH7+tktGOAhNnGpR
   VgT9CkTqTpWVOLdbYHoL7GfjItPs2SSW1uFKm2nY787AhIaVKJVvbgadZ
   ymvazf/5dCo6mxsJXd9Meuyumqw7/VtgTOqV4f1pgvzvyCAi7bX2rxK91
   isc0pO6lQy8QMgKU+0pb06TLdOhmyKYAjOs74jS+H6r/A2j85HDhUWveU
   3YfFcn5qmL0/9njtVTF2Ja02axnNPsykW03AFLuGzUdBnjtYuw4//Irgs
   Q==;
X-IronPort-AV: E=Sophos;i="5.58,373,1544486400"; 
   d="scan'208";a="23989935"
IronPort-PHdr: =?us-ascii?q?9a23=3A1GH6qhc+1SUoohWNk9LZQaSblGMj4u6mDksu8p?=
 =?us-ascii?q?Mizoh2WeGdxc2+YxaN2/xhgRfzUJnB7Loc0qyK6/CmATRIyK3CmUhKSIZLWR?=
 =?us-ascii?q?4BhJdetC0bK+nBN3fGKuX3ZTcxBsVIWQwt1Xi6NU9IBJS2PAWK8TW94jEIBx?=
 =?us-ascii?q?rwKxd+KPjrFY7OlcS30P2594HObwlSizexfbB/IA+qoQnNq8IbnZZsJqEtxx?=
 =?us-ascii?q?XTv3BGYf5WxWRmJVKSmxbz+MK994N9/ipTpvws6ddOXb31cKokQ7NYCi8mM3?=
 =?us-ascii?q?0u683wqRbDVwqP6WACXWgQjxFFHhLK7BD+Xpf2ryv6qu9w0zSUMMHqUbw5Xy?=
 =?us-ascii?q?mp4rx1QxH0ligIKz858HnWisNuiqJbvAmhrAF7z4LNfY2ZKOZycqbbcNwUX2?=
 =?us-ascii?q?pBWttaWTJHDI2ycoADC/MNMfhEo4X4oVYFsBmwChS2BO731zFGmHH206053e?=
 =?us-ascii?q?ovHw7J0w4vEM4BvnnPsNX4Nr0fXfypwKTGzzjOae5d1zfn6IjPdxAsueyCXa?=
 =?us-ascii?q?5ufsrJyUkgCQXFhUiNp4zgJTyV0uANvHab7uF9Uu+vkHMoqxpqrzizxsYjlo?=
 =?us-ascii?q?nJhoUPxlDC7iV22pw5JdK/SE5leNOpFoZbuSKCN4ZuX88vTG5ltDw6x7Ebo5?=
 =?us-ascii?q?K3YicHxIo9yxLCbfGMbpKG7Qj5VOmLJDd1nHdleLWiiBms6UWg0ej8VtWs0F?=
 =?us-ascii?q?ZNsypFjsHAtnAT2BzX7ciKUud98V272TaOygDT8ftIIVw0lKXHK54hxaQ8lp?=
 =?us-ascii?q?wPvkTYAiD6gkD2jK6Sdkk8++io7froYqn+q5OBOIJ5hRvyP6QzlsClH+g1PR?=
 =?us-ascii?q?YCU3KG9eik0b3s50z5QLFEjv0slanZtYjXJd8Gqa6iGAJVzoYi5Aq/Dzehyt?=
 =?us-ascii?q?gYm2IHI0hfdBKIiIjpJUnCIOrkAvenn1SsjDBryujbMb3hBZXMIGbMkLPlfb?=
 =?us-ascii?q?Zm8ENc0hQ8ws1f551OFrENOu78Wkj0tNbAFB82LxS0w/r7CNV6zo4eWnyAA6?=
 =?us-ascii?q?+DMKPTt1+I6fkvLvKSZI8apjn9MeIp5/3wgn8jn18SY62p0YEQaHCiEfRsO1?=
 =?us-ascii?q?+Zbmb0gtcdDWcKuRIzTPDwiF2FVz5cemy+X6c85zE4DIKpE5zMRp22gLydxy?=
 =?us-ascii?q?q7HodZZmVDCl+SC3fobJ2EVO0QZy2MOMNujjsEVb25QY87yR6urBP6y6ZgLu?=
 =?us-ascii?q?fM4S0Yu4jj28Zz5+LPlRE/7id0AN6Y026WVW54hGQIRyU53Kpnu0xy1k+D0b?=
 =?us-ascii?q?Rkg/xfDdFT4/JJUgEnNZ/T1uB6EM79VR7cfteTSVamXtWnDSg0TtI23tAOfk?=
 =?us-ascii?q?J9FMu5gxDd0CqlHaUVm6aIBJMq6KLc2Wb+J8Jnx3bBzqkhgEEsQtFTOm2+mq?=
 =?us-ascii?q?5/6w/TCpbNk0WYkaaqaKsd0DfL9GeN1mqDp19YUAFuXqXfR3wfZVXZrc7/5k?=
 =?us-ascii?q?zcS7+iE7MnMhFOycSaMKtFdsXpjUlaRPfkINneZ2Oxm2GtBReH37+DcIvqe2?=
 =?us-ascii?q?sG3CjGFkgEnB4c/WycOQg9GCihuWTeAyJqFV71ZEPs6+Z+omuhTkAo1wGKc1?=
 =?us-ascii?q?Fh172t9x4RhPycTe4T370dtCcvsDV7AUiy38zIBNqEvAdhYqpcbs0n4Ftd1m?=
 =?us-ascii?q?LWqRZ9Ppq+IKBmnFIedB53v0z23RVtFopAidQqrG8tzAdqM6KY30hOeiiC3Z?=
 =?us-ascii?q?/uJ7LXKnP9/Ay1Z6HK3VHe1c6c+r0T5/Qgt1XjoAapG1Im83Vm1dlVznSd6o?=
 =?us-ascii?q?zJDAUMS5LxVFg49xxhqrHEbSky+ZnU2WdvMaaqqD/C3cwmBO8/xhanZddfP/?=
 =?us-ascii?q?DMKAinP8QEBsTmCOs1llytdVpQMOBV66MwO9iObfaK2Ke3eu1nmWTixWdK8Z?=
 =?us-ascii?q?p81E2X3zRzR/SO3JsfxfycmAydWHO0kE2mtMyxnJFHYTwYA3Gj4SjtAYtcfL?=
 =?us-ascii?q?ZqdI0GT2ypJon/3dtkipjmW1ZD/VupDhUBwsD6VwCVagnGwQBI1UkR6UeikC?=
 =?us-ascii?q?+8wi08xyoltYKDzSfOxKLkbxNBNWlVEjoxxWzwKJS52ohJFHOjaBIkwV78vx?=
 =?us-ascii?q?73?=
X-IPAS-Result: =?us-ascii?q?A2DCAQA2+GZc/wHyM5BkHAEBAQQBAQcEAQGBVAQBAQsBg?=
 =?us-ascii?q?VkpgWonhAaTfkwBAQEBAQEGgQgIJYk5kFk4AYRAAoNqIjcGDQEDAQEBAQEBA?=
 =?us-ascii?q?gFsKII6KQGCZwEFIwQRQRALDgQGAgImAgJJDgYBDAYCAQGCXz2BZg2sPXwzh?=
 =?us-ascii?q?USEa4ELizkXeIEHgREnDIIxLogKglcCiWMgKoYWSztakRcJklAGGZJ6ikGTe?=
 =?us-ascii?q?iKBVisIAhgIIQ87gmyCKBeOPCEDMIEFAQGMZiuCIAEB?=
Received: from tarius.tycho.ncsc.mil ([144.51.242.1])
  by emsm-gh1-uea11.NCSC.MIL with ESMTP; 15 Feb 2019 17:39:35 +0000
Received: from moss-pluto.infosec.tycho.ncsc.mil (moss-pluto [192.168.25.131])
        by tarius.tycho.ncsc.mil (8.14.4/8.14.4) with ESMTP id x1FHdYYV031000;
        Fri, 15 Feb 2019 12:39:35 -0500
Subject: Re: [RFC PATCH 04/27] containers: Allow a process to be forked into a
 container
To:     David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024686966.21651.5963892339360034863.stgit@warthog.procyon.org.uk>
From:   Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <1a138c44-5822-2e47-fa7c-fb01ee11a5c3@tycho.nsa.gov>
Date:   Fri, 15 Feb 2019 12:39:34 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <155024686966.21651.5963892339360034863.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2/15/19 11:07 AM, David Howells wrote:
> Allow a single process to be forked directly into a container using a new
> syscall, thereby 'booting' the container:
> 
> 	pid_t pid = fork_into_container(int container_fd);
> 
> This process will be the 'init' process of the container.
> 
> Further attempts to fork into the container will be rejected.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>   arch/x86/entry/syscalls/syscall_32.tbl |    1
>   arch/x86/entry/syscalls/syscall_64.tbl |    1
>   arch/x86/ia32/sys_ia32.c               |    2 -
>   include/linux/cred.h                   |    3 +
>   include/linux/nsproxy.h                |    7 ++
>   include/linux/sched/task.h             |    3 +
>   include/linux/syscalls.h               |    1
>   kernel/cred.c                          |   45 +++++++++++++
>   kernel/fork.c                          |  110 ++++++++++++++++++++++++++------
>   kernel/nsproxy.c                       |   11 +++
>   kernel/sys_ni.c                        |    1
>   11 files changed, 157 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 3564814a5d21..8666693510f9 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -408,3 +408,4 @@
>   394	i386	mount_notify		sys_mount_notify		__ia32_sys_mount_notify
>   395	i386	sb_notify		sys_sb_notify			__ia32_sys_sb_notify
>   396	i386	container_create	sys_container_create		__ia32_sys_container_create
> +397	i386	fork_into_container	sys_fork_into_container		__ia32_sys_fork_into_container
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index aa6cccbe5271..d40d4790fcb2 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -353,6 +353,7 @@
>   342	common	mount_notify		__x64_sys_mount_notify
>   343	common	sb_notify		__x64_sys_sb_notify
>   344	common	container_create	__x64_sys_container_create
> +345	common	fork_into_container	__x64_sys_fork_into_container
>   
>   #
>   # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
> index a43212036257..080d9e21b697 100644
> --- a/arch/x86/ia32/sys_ia32.c
> +++ b/arch/x86/ia32/sys_ia32.c
> @@ -238,5 +238,5 @@ COMPAT_SYSCALL_DEFINE5(x86_clone, unsigned long, clone_flags,
>   		       unsigned long, tls_val, int __user *, child_tidptr)
>   {
>   	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr,
> -			tls_val);
> +			tls_val, NULL);
>   }
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 4907c9df86b3..357e743d5d4a 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -23,6 +23,7 @@
>   
>   struct cred;
>   struct inode;
> +struct container;
>   
>   /*
>    * COW Supplementary groups list
> @@ -155,7 +156,7 @@ struct cred {
>   
>   extern void __put_cred(struct cred *);
>   extern void exit_creds(struct task_struct *);
> -extern int copy_creds(struct task_struct *, unsigned long);
> +extern int copy_creds(struct task_struct *, unsigned long, struct container *);
>   extern const struct cred *get_task_cred(struct task_struct *);
>   extern struct cred *cred_alloc_blank(void);
>   extern struct cred *prepare_creds(void);
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 2ae1b1a4d84d..81838ae24a92 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -11,6 +11,7 @@ struct ipc_namespace;
>   struct pid_namespace;
>   struct cgroup_namespace;
>   struct fs_struct;
> +struct container;
>   
>   /*
>    * A structure to contain pointers to all per-process
> @@ -63,9 +64,13 @@ extern struct nsproxy init_nsproxy;
>    *         * /
>    *     task_unlock(task);
>    *
> + *  4. Container namespaces are set at container creation and cannot be
> + *     changed.
> + *
>    */
>   
> -int copy_namespaces(unsigned long flags, struct task_struct *tsk);
> +int copy_namespaces(unsigned long flags, struct task_struct *tsk,
> +		    struct container *dest_container);
>   void exit_task_namespaces(struct task_struct *tsk);
>   void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
>   void free_nsproxy(struct nsproxy *ns);
> diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
> index 44c6f15800ff..bdff71b0fb66 100644
> --- a/include/linux/sched/task.h
> +++ b/include/linux/sched/task.h
> @@ -73,7 +73,8 @@ extern void do_group_exit(int);
>   extern void exit_files(struct task_struct *);
>   extern void exit_itimers(struct signal_struct *);
>   
> -extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
> +extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *,
> +		     int __user *, unsigned long, struct container *);
>   extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
>   struct task_struct *fork_idle(int);
>   extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index dac42098c2dd..15e5cc704df3 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -946,6 +946,7 @@ asmlinkage long sys_sb_notify(int dfd, const char __user *path,
>   asmlinkage long sys_container_create(const char __user *name, unsigned int flags,
>   				     unsigned long spare3, unsigned long spare4,
>   				     unsigned long spare5);
> +asmlinkage long sys_fork_into_container(int containerfd);
>   
>   /*
>    * Architecture-specific system calls
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 21f4a97085b4..f0ee5cec533d 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -313,6 +313,43 @@ struct cred *prepare_exec_creds(void)
>   	return new;
>   }
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
>   /*
>    * Copy credentials for the new process created by fork()
>    *
> @@ -322,7 +359,8 @@ struct cred *prepare_exec_creds(void)
>    * The new process gets the current process's subjective credentials as its
>    * objective and subjective credentials
>    */
> -int copy_creds(struct task_struct *p, unsigned long clone_flags)
> +int copy_creds(struct task_struct *p, unsigned long clone_flags,
> +	       struct container *dest_container)
>   {
>   	struct cred *new;
>   	int ret;
> @@ -343,7 +381,10 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
>   		return 0;
>   	}
>   
> -	new = prepare_creds();
> +	if (dest_container)
> +		new = copy_container_creds(dest_container);

Shouldn't there be a check between the current process' credentials and 
the destination container's credentials before allowing this to occur?

> +	else
> +		new = prepare_creds();
>   	if (!new)
>   		return -ENOMEM;
>   
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 009cf7e63894..71401deb4434 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1385,9 +1385,33 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
>   	return retval;
>   }
>   
> -static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
> +static int copy_fs(unsigned long clone_flags, struct task_struct *tsk,
> +		   struct container *dest_container)
>   {
>   	struct fs_struct *fs = current->fs;
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
>   	if (clone_flags & CLONE_FS) {
>   		/* tsk->fs is already what we want */
>   		spin_lock(&fs->lock);
> @@ -1679,7 +1703,8 @@ static __latent_entropy struct task_struct *copy_process(
>   					struct pid *pid,
>   					int trace,
>   					unsigned long tls,
> -					int node)
> +					int node,
> +					struct container *dest_container)
>   {
>   	int retval;
>   	struct task_struct *p;
> @@ -1783,7 +1808,7 @@ static __latent_entropy struct task_struct *copy_process(
>   	}
>   	current->flags &= ~PF_NPROC_EXCEEDED;
>   
> -	retval = copy_creds(p, clone_flags);
> +	retval = copy_creds(p, clone_flags, dest_container);
>   	if (retval < 0)
>   		goto bad_fork_free;
>   
> @@ -1905,7 +1930,7 @@ static __latent_entropy struct task_struct *copy_process(
>   	retval = copy_files(clone_flags, p);
>   	if (retval)
>   		goto bad_fork_cleanup_semundo;
> -	retval = copy_fs(clone_flags, p);
> +	retval = copy_fs(clone_flags, p, dest_container);
>   	if (retval)
>   		goto bad_fork_cleanup_files;
>   	retval = copy_sighand(clone_flags, p);
> @@ -1917,15 +1942,15 @@ static __latent_entropy struct task_struct *copy_process(
>   	retval = copy_mm(clone_flags, p);
>   	if (retval)
>   		goto bad_fork_cleanup_signal;
> -	retval = copy_namespaces(clone_flags, p);
> +	retval = copy_container(clone_flags, p, dest_container);
>   	if (retval)
>   		goto bad_fork_cleanup_mm;
> -	retval = copy_container(clone_flags, p, NULL);
> +	retval = copy_namespaces(clone_flags, p, dest_container);
>   	if (retval)
> -		goto bad_fork_cleanup_namespaces;
> +		goto bad_fork_cleanup_container;
>   	retval = copy_io(clone_flags, p);
>   	if (retval)
> -		goto bad_fork_cleanup_container;
> +		goto bad_fork_cleanup_namespaces;
>   	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
>   	if (retval)
>   		goto bad_fork_cleanup_io;
> @@ -2124,10 +2149,10 @@ static __latent_entropy struct task_struct *copy_process(
>   bad_fork_cleanup_io:
>   	if (p->io_context)
>   		exit_io_context(p);
> -bad_fork_cleanup_container:
> -	exit_container(p);
>   bad_fork_cleanup_namespaces:
>   	exit_task_namespaces(p);
> +bad_fork_cleanup_container:
> +	exit_container(p);
>   bad_fork_cleanup_mm:
>   	if (p->mm)
>   		mmput(p->mm);
> @@ -2183,7 +2208,7 @@ struct task_struct *fork_idle(int cpu)
>   {
>   	struct task_struct *task;
>   	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0,
> -			    cpu_to_node(cpu));
> +			    cpu_to_node(cpu), NULL);
>   	if (!IS_ERR(task)) {
>   		init_idle_pids(task);
>   		init_idle(task, cpu);
> @@ -2195,15 +2220,16 @@ struct task_struct *fork_idle(int cpu)
>   /*
>    *  Ok, this is the main fork-routine.
>    *
> - * It copies the process, and if successful kick-starts
> - * it and waits for it to finish using the VM if required.
> + * It copies the process into the specified container, and if successful
> + * kick-starts it and waits for it to finish using the VM if required.
>    */
>   long _do_fork(unsigned long clone_flags,
>   	      unsigned long stack_start,
>   	      unsigned long stack_size,
>   	      int __user *parent_tidptr,
>   	      int __user *child_tidptr,
> -	      unsigned long tls)
> +	      unsigned long tls,
> +	      struct container *dest_container)
>   {
>   	struct completion vfork;
>   	struct pid *pid;
> @@ -2229,8 +2255,32 @@ long _do_fork(unsigned long clone_flags,
>   			trace = 0;
>   	}
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
>   	p = copy_process(clone_flags, stack_start, stack_size,
> -			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE);
> +			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE,
> +			 dest_container);
>   	add_latent_entropy();
>   
>   	if (IS_ERR(p))
> @@ -2279,7 +2329,7 @@ long do_fork(unsigned long clone_flags,
>   	      int __user *child_tidptr)
>   {
>   	return _do_fork(clone_flags, stack_start, stack_size,
> -			parent_tidptr, child_tidptr, 0);
> +			parent_tidptr, child_tidptr, 0, NULL);
>   }
>   #endif
>   
> @@ -2289,14 +2339,14 @@ long do_fork(unsigned long clone_flags,
>   pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
>   {
>   	return _do_fork(flags|CLONE_VM|CLONE_UNTRACED, (unsigned long)fn,
> -		(unsigned long)arg, NULL, NULL, 0);
> +			(unsigned long)arg, NULL, NULL, 0, NULL);
>   }
>   
>   #ifdef __ARCH_WANT_SYS_FORK
>   SYSCALL_DEFINE0(fork)
>   {
>   #ifdef CONFIG_MMU
> -	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0);
> +	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, NULL);
>   #else
>   	/* can not support in nommu mode */
>   	return -EINVAL;
> @@ -2308,7 +2358,26 @@ SYSCALL_DEFINE0(fork)
>   SYSCALL_DEFINE0(vfork)
>   {
>   	return _do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, 0,
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
>   }
>   #endif
>   
> @@ -2336,7 +2405,8 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
>   		 unsigned long, tls)
>   #endif
>   {
> -	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls);
> +	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls,
> +			NULL);
>   }
>   #endif
>   
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 4bb5184b3a80..4031075300a4 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -136,12 +136,19 @@ struct nsproxy *create_new_namespaces(unsigned long flags,
>    * called from clone.  This now handles copy for nsproxy and all
>    * namespaces therein.
>    */
> -int copy_namespaces(unsigned long flags, struct task_struct *tsk)
> +int copy_namespaces(unsigned long flags, struct task_struct *tsk,
> +		    struct container *dest_container)
>   {
>   	struct nsproxy *old_ns = tsk->nsproxy;
>   	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
>   	struct nsproxy *new_ns;
>   
> +	if (dest_container) {
> +		get_nsproxy(dest_container->ns);
> +		tsk->nsproxy = dest_container->ns;
> +		return 0;
> +	}
> +
>   	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
>   			      CLONE_NEWPID | CLONE_NEWNET |
>   			      CLONE_NEWCGROUP)))) {
> @@ -163,7 +170,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>   		(CLONE_NEWIPC | CLONE_SYSVSEM))
>   		return -EINVAL;
>   
> -	new_ns = create_new_namespaces(flags, tsk->nsproxy, user_ns, tsk->fs);
> +	new_ns = create_new_namespaces(flags, old_ns, user_ns, tsk->fs);
>   	if (IS_ERR(new_ns))
>   		return  PTR_ERR(new_ns);
>   
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index f0455cbb91cf..a23ad529d548 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -144,6 +144,7 @@ COND_SYSCALL(container_create);
>   /* kernel/exit.c */
>   
>   /* kernel/fork.c */
> +COND_SYSCALL(fork_into_container);
>   
>   /* kernel/futex.c */
>   COND_SYSCALL(futex);
> 

