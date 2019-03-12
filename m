Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C79C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:01:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFF1720449
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:01:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726612AbfCLUBL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 16:01:11 -0400
Received: from fieldses.org ([173.255.197.46]:57402 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726585AbfCLUBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 16:01:11 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id A76331C84; Tue, 12 Mar 2019 16:01:09 -0400 (EDT)
Date:   Tue, 12 Mar 2019 16:01:09 -0400
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/7] kthreads: allow multiple kthreadd's
Message-ID: <20190312200109.GE29990@fieldses.org>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
 <1549656647-25115-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549656647-25115-4-git-send-email-bfields@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'd like to try to get this in 5.2.  Can anyone give me an ACK for the
kthread parts?  Or tell me who to ask?  Let me know if I should resend.
Or, of course, tell me if I've missed something and this is all a
terrible idea.

--b.

On Fri, Feb 08, 2019 at 03:10:43PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Allow subsystems to run their own kthreadd's.
> 
> I'm experimenting with this to allow nfsd to put its threads into its
> own thread group to make it easy for the vfs to tell when nfsd is
> breaking one of its own leases.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  include/linux/kthread.h |  20 ++++++-
>  init/main.c             |   4 +-
>  kernel/kthread.c        | 113 ++++++++++++++++++++++++++++++----------
>  3 files changed, 107 insertions(+), 30 deletions(-)
> 
> diff --git a/include/linux/kthread.h b/include/linux/kthread.h
> index c1961761311d..10b5836dfb2a 100644
> --- a/include/linux/kthread.h
> +++ b/include/linux/kthread.h
> @@ -6,6 +6,24 @@
>  #include <linux/sched.h>
>  #include <linux/cgroup.h>
>  
> +struct kthread_group {
> +	char *name;
> +	spinlock_t create_lock;
> +	struct list_head create_list;
> +	struct task_struct *task;
> +};
> +
> +extern struct kthread_group kthreadd_default;
> +
> +struct kthread_group *kthread_start_group(char *);
> +void kthread_stop_group(struct kthread_group *);
> +
> +struct task_struct *kthread_group_create_on_node(struct kthread_group *,
> +					int (*threadfn)(void *data),
> +					 void *data,
> +					 int node,
> +					 const char namefmt[], ...);
> +
>  __printf(4, 5)
>  struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
>  					   void *data,
> @@ -63,7 +81,7 @@ int kthread_park(struct task_struct *k);
>  void kthread_unpark(struct task_struct *k);
>  void kthread_parkme(void);
>  
> -int kthreadd(void *unused);
> +int kthreadd(void *);
>  extern struct task_struct *kthreadd_task;
>  extern int tsk_fork_get_node(struct task_struct *tsk);
>  
> diff --git a/init/main.c b/init/main.c
> index e2e80ca3165a..c4ed4d75aca7 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -417,9 +417,9 @@ noinline void __ref rest_init(void)
>  	rcu_read_unlock();
>  
>  	numa_default_policy();
> -	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES);
> +	pid = kernel_thread(kthreadd, &kthreadd_default, CLONE_FS | CLONE_FILES);
>  	rcu_read_lock();
> -	kthreadd_task = find_task_by_pid_ns(pid, &init_pid_ns);
> +	kthreadd_default.task = find_task_by_pid_ns(pid, &init_pid_ns);
>  	rcu_read_unlock();
>  
>  	/*
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index 4428fd586cd8..b515557b98c9 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -22,9 +22,44 @@
>  #include <linux/uaccess.h>
>  #include <trace/events/sched.h>
>  
> -static DEFINE_SPINLOCK(kthread_create_lock);
> -static LIST_HEAD(kthread_create_list);
> -struct task_struct *kthreadd_task;
> +struct kthread_group kthreadd_default = {
> +	.name = "kthreadd",
> +	.create_lock = __SPIN_LOCK_UNLOCKED(kthreadd_default.create_lock),
> +	.create_list = LIST_HEAD_INIT(kthreadd_default.create_list),
> +};
> +
> +void wake_kthreadd(struct kthread_group *kg)
> +{
> +	wake_up_process(kg->task);
> +}
> +
> +struct kthread_group *kthread_start_group(char *name)
> +{
> +	struct kthread_group *new;
> +	struct task_struct *task;
> +
> +	new = kmalloc(sizeof(struct kthread_group), GFP_KERNEL);
> +	if (!new)
> +		return ERR_PTR(-ENOMEM);
> +	spin_lock_init(&new->create_lock);
> +	INIT_LIST_HEAD(&new->create_list);
> +	new->name = name;
> +	task = kthread_run(kthreadd, new, name);
> +	if (IS_ERR(task)) {
> +		kfree(new);
> +		return ERR_CAST(task);
> +	}
> +	new->task = task;
> +	return new;
> +}
> +EXPORT_SYMBOL_GPL(kthread_start_group);
> +
> +void kthread_stop_group(struct kthread_group *kg)
> +{
> +	kthread_stop(kg->task);
> +	kfree(kg);
> +}
> +EXPORT_SYMBOL_GPL(kthread_stop_group);
>  
>  struct kthread_create_info
>  {
> @@ -279,11 +314,13 @@ static void create_kthread(struct kthread_create_info *create)
>  	}
>  }
>  
> -static __printf(4, 0)
> -struct task_struct *__kthread_create_on_node(int (*threadfn)(void *data),
> -						    void *data, int node,
> -						    const char namefmt[],
> -						    va_list args)
> +
> +static __printf(5, 0)
> +struct task_struct *__kthread_group_create_on_node(struct kthread_group *kg,
> +						int (*threadfn)(void *data),
> +						void *data, int node,
> +						const char namefmt[],
> +						va_list args)
>  {
>  	DECLARE_COMPLETION_ONSTACK(done);
>  	struct task_struct *task;
> @@ -297,11 +334,11 @@ struct task_struct *__kthread_create_on_node(int (*threadfn)(void *data),
>  	create->node = node;
>  	create->done = &done;
>  
> -	spin_lock(&kthread_create_lock);
> -	list_add_tail(&create->list, &kthread_create_list);
> -	spin_unlock(&kthread_create_lock);
> +	spin_lock(&kg->create_lock);
> +	list_add_tail(&create->list, &kg->create_list);
> +	spin_unlock(&kg->create_lock);
>  
> -	wake_up_process(kthreadd_task);
> +	wake_kthreadd(kg);
>  	/*
>  	 * Wait for completion in killable state, for I might be chosen by
>  	 * the OOM killer while kthreadd is trying to allocate memory for
> @@ -343,6 +380,25 @@ struct task_struct *__kthread_create_on_node(int (*threadfn)(void *data),
>  	return task;
>  }
>  
> +__printf(5, 0)
> +struct task_struct *kthread_group_create_on_node(struct kthread_group *kg,
> +						int (*threadfn)(void *data),
> +						void *data, int node,
> +						const char namefmt[],
> +						...)
> +{
> +	struct task_struct *task;
> +	va_list args;
> +
> +	va_start(args, namefmt);
> +	task = __kthread_group_create_on_node(kg, threadfn,
> +						data, node, namefmt, args);
> +	va_end(args);
> +
> +	return task;
> +}
> +EXPORT_SYMBOL_GPL(kthread_group_create_on_node);
> +
>  /**
>   * kthread_create_on_node - create a kthread.
>   * @threadfn: the function to run until signal_pending(current).
> @@ -375,7 +431,8 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
>  	va_list args;
>  
>  	va_start(args, namefmt);
> -	task = __kthread_create_on_node(threadfn, data, node, namefmt, args);
> +	task = __kthread_group_create_on_node(&kthreadd_default, threadfn,
> +						data, node, namefmt, args);
>  	va_end(args);
>  
>  	return task;
> @@ -555,30 +612,31 @@ int kthread_stop(struct task_struct *k)
>  }
>  EXPORT_SYMBOL(kthread_stop);
>  
> -void kthread_do_work(void)
> +void kthread_do_work(struct kthread_group *kg)
>  {
> -	spin_lock(&kthread_create_lock);
> -	while (!list_empty(&kthread_create_list)) {
> +	spin_lock(&kg->create_lock);
> +	while (!list_empty(&kg->create_list)) {
>  		struct kthread_create_info *create;
>  
> -		create = list_entry(kthread_create_list.next,
> +		create = list_entry(kg->create_list.next,
>  				    struct kthread_create_info, list);
>  		list_del_init(&create->list);
> -		spin_unlock(&kthread_create_lock);
> +		spin_unlock(&kg->create_lock);
>  
>  		create_kthread(create);
>  
> -		spin_lock(&kthread_create_lock);
> +		spin_lock(&kg->create_lock);
>  	}
> -	spin_unlock(&kthread_create_lock);
> +	spin_unlock(&kg->create_lock);
>  }
>  
> -int kthreadd(void *unused)
> +int kthreadd(void *data)
>  {
> +	struct kthread_group *kg = data;
>  	struct task_struct *tsk = current;
>  
>  	/* Setup a clean context for our children to inherit. */
> -	set_task_comm(tsk, "kthreadd");
> +	set_task_comm(tsk, kg->name);
>  	ignore_signals(tsk);
>  	set_cpus_allowed_ptr(tsk, cpu_all_mask);
>  	set_mems_allowed(node_states[N_MEMORY]);
> @@ -586,13 +644,13 @@ int kthreadd(void *unused)
>  	current->flags |= PF_NOFREEZE;
>  	cgroup_init_kthreadd();
>  
> -	for (;;) {
> +	while (current == kthreadd_default.task || !kthread_should_stop()) {
>  		set_current_state(TASK_INTERRUPTIBLE);
> -		if (list_empty(&kthread_create_list))
> +		if (list_empty(&kg->create_list))
>  			schedule();
>  		__set_current_state(TASK_RUNNING);
>  
> -		kthread_do_work();
> +		kthread_do_work(kg);
>  	}
>  
>  	return 0;
> @@ -690,8 +748,9 @@ __kthread_create_worker(int cpu, unsigned int flags,
>  	if (cpu >= 0)
>  		node = cpu_to_node(cpu);
>  
> -	task = __kthread_create_on_node(kthread_worker_fn, worker,
> -						node, namefmt, args);
> +	task = __kthread_group_create_on_node(&kthreadd_default,
> +					kthread_worker_fn,
> +					worker, node, namefmt, args);
>  	if (IS_ERR(task))
>  		goto fail_task;
>  
> -- 
> 2.20.1
