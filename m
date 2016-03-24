Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40161 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751448AbcCXHpx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2016 03:45:53 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 6541A21CE9
	for <linux-nfs@vger.kernel.org>; Thu, 24 Mar 2016 03:45:52 -0400 (EDT)
Message-ID: <1458805544.3099.16.camel@themaw.net>
Subject: Re: call_usermodehelper in containers
From: Ian Kent <raven@themaw.net>
To: Oleg Nesterov <oleg@redhat.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com
Date: Thu, 24 Mar 2016 15:45:44 +0800
In-Reply-To: <20131118172844.GA10005@redhat.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	 <20131112004703.GB15377@kroah.com>
	 <20131112061201.04cf25ab@tlielax.poochiereds.net>
	 <528226EC.4050701@parallels.com>
	 <20131112083043.0ab78e67@tlielax.poochiereds.net>
	 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	 <20131118172844.GA10005@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
> On 11/15, Eric W. Biederman wrote:
> > 
> > I don't understand that one.  Having a preforked thread with the
> > proper
> > environment that can act like kthreadd in terms of spawning user
> > mode
> > helpers works and is simple.
> 
> Can't we ask ->child_reaper to create the non-daemonized kernel thread
> with the "right" ->nsproxy, ->fs, etc?
> 
> IOW. Please the the "patch" below. It is obviously incomplete and
> wrong,
> and it can be more clear/clean. And probably we need another API. Just
> to explain what I mean.
> 
> With this patch call_usermodehelper(..., UMH_IN_MY_NS) should do exec
> from the caller's namespace.

Umm ... I don't think this can work.

I don't think it can be assumed that the init process of a container
will behave like an init process.

If you try and do this with a Docker container that has /bin/bash as the
init process signals never arrive and work doesn't start until some
other signal arrives at which time it fails to create the kernel thread
returning an error ERESTARTNOINTER (IIRC).

In fact a number of other things relating to signalling processes to
cleanly shutdown in a container suffer the same problem.

I probably don't understand what's actually going on, this is just my
impression of what I'm seeing.

> 
> Oleg.
> ---
> 
> --- a/include/linux/kmod.h
> +++ b/include/linux/kmod.h
> @@ -24,6 +24,7 @@
>  #include <linux/errno.h>
>  #include <linux/compiler.h>
>  #include <linux/workqueue.h>
> +#include <linux/task_work.h>
>  #include <linux/sysctl.h>
>  
>  #define KMOD_PATH_LEN 256
> @@ -53,8 +54,14 @@ struct file;
>  #define UMH_WAIT_PROC	2	/* wait for the process to
> complete */
>  #define UMH_KILLABLE	4	/* wait for EXEC/PROC killable
> */
>  
> +// FIXME: IMH_* is not actually a mask
> +#define UMH_IN_MY_NS	8
> +
>  struct subprocess_info {
> -	struct work_struct work;
> +	union {
> +		struct work_struct work;
> +		struct callback_head twork;
> +	};
>  	struct completion *complete;
>  	char *path;
>  	char **argv;
> --- a/kernel/kmod.c
> +++ b/kernel/kmod.c
> @@ -541,7 +541,6 @@ struct subprocess_info
> *call_usermodehelper_setup(char *path, char **argv,
>  	if (!sub_info)
>  		goto out;
>  
> -	INIT_WORK(&sub_info->work, __call_usermodehelper);
>  	sub_info->path = path;
>  	sub_info->argv = argv;
>  	sub_info->envp = envp;
> @@ -554,6 +553,24 @@ struct subprocess_info
> *call_usermodehelper_setup(char *path, char **argv,
>  }
>  EXPORT_SYMBOL(call_usermodehelper_setup);
>  
> +static int call_call_usermodehelper(void *twork)
> +{
> +	struct subprocess_info *sub_info =
> +		container_of(twork, struct subprocess_info, twork);
> +
> +	__call_usermodehelper(&sub_info->work);
> +	do_exit(0);
> +
> +}
> +
> +static void fork_umh_helper(struct callback_head *twork)
> +{
> +	if (current->flags & PF_EXITING)
> +		return;	// WRONG, FIXME
> +
> +	kernel_thread(call_call_usermodehelper, twork, SIGCHLD);
> +}
> +
>  /**
>   * call_usermodehelper_exec - start a usermode application
>   * @sub_info: information about the subprocessa
> @@ -570,6 +587,10 @@ int call_usermodehelper_exec(struct
> subprocess_info *sub_info, int wait)
>  {
>  	DECLARE_COMPLETION_ONSTACK(done);
>  	int retval = 0;
> +	bool in_my_ns;
> +
> +	in_my_ns = wait & UMH_IN_MY_NS;
> +	wait &= ~UMH_IN_MY_NS;
>  
>  	if (!sub_info->path) {
>  		call_usermodehelper_freeinfo(sub_info);
> @@ -594,7 +615,21 @@ int call_usermodehelper_exec(struct
> subprocess_info *sub_info, int wait)
>  	sub_info->complete = &done;
>  	sub_info->wait = wait;
>  
> -	queue_work(khelper_wq, &sub_info->work);
> +	if (likely(!in_my_ns)) {
> +		INIT_WORK(&sub_info->work, __call_usermodehelper);
> +		queue_work(khelper_wq, &sub_info->work);
> +	} else {
> +		// RACY, WRONG, ETC
> +		struct task_struct *my_init =
> task_active_pid_ns(current)->child_reaper;
> +
> +		init_task_work(&sub_info->twork, fork_umh_helper);
> +		task_work_add(my_init, &sub_info->twork, false);
> +
> +		// until we have task_work_add_interruptibel()
> +		do_send_sig_info(SIGCHLD, SEND_SIG_FORCED, my_init,
> false);
> +
> +	}
> +
>  	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
>  		goto unlock;
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux
> -fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
