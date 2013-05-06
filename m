Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787Ab3EFK4w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 06:56:52 -0400
Date: Mon, 6 May 2013 06:56:05 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>,
        smfrench@gmail.com
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506065605.6e5ed5e2@tlielax.poochiereds.net>
In-Reply-To: <1367615050-3894-1-git-send-email-ccross@android.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  3 May 2013 14:04:09 -0700
Colin Cross <ccross@android.com> wrote:

> NFS calls the freezable helpers with locks held, which is unsafe
> and caused lockdep warnings when 6aa9707 "lockdep: check that no
> locks held at freeze time" was applied (reverted in dbf520a).
> Add new *_unsafe versions of the helpers that will not run the
> lockdep test when 6aa9707 is reapplied, and call them from NFS.
> 
> Signed-off-by: Colin Cross <ccross@android.com>
> ---
>  fs/nfs/inode.c          |  2 +-
>  fs/nfs/nfs3proc.c       |  2 +-
>  fs/nfs/nfs4proc.c       |  4 ++--
>  include/linux/freezer.h | 42 +++++++++++++++++++++++++++++++++++++++++-
>  net/sunrpc/sched.c      |  2 +-
>  5 files changed, 46 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1f94167..53cbee5 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -79,7 +79,7 @@ int nfs_wait_bit_killable(void *word)
>  {
>  	if (fatal_signal_pending(current))
>  		return -ERESTARTSYS;
> -	freezable_schedule();
> +	freezable_schedule_unsafe();
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index 43ea96c..ce90eb4 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -33,7 +33,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
>  		res = rpc_call_sync(clnt, msg, flags);
>  		if (res != -EJUKEBOX)
>  			break;
> -		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
> +		freezable_schedule_timeout_killable_unsafe(NFS_JUKEBOX_RETRY_TIME);
>  		res = -ERESTARTSYS;
>  	} while (!fatal_signal_pending(current));
>  	return res;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0ad025e..a236077 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -266,7 +266,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
>  		*timeout = NFS4_POLL_RETRY_MIN;
>  	if (*timeout > NFS4_POLL_RETRY_MAX)
>  		*timeout = NFS4_POLL_RETRY_MAX;
> -	freezable_schedule_timeout_killable(*timeout);
> +	freezable_schedule_timeout_killable_unsafe(*timeout);
>  	if (fatal_signal_pending(current))
>  		res = -ERESTARTSYS;
>  	*timeout <<= 1;
> @@ -4309,7 +4309,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
>  static unsigned long
>  nfs4_set_lock_task_retry(unsigned long timeout)
>  {
> -	freezable_schedule_timeout_killable(timeout);
> +	freezable_schedule_timeout_killable_unsafe(timeout);
>  	timeout <<= 1;
>  	if (timeout > NFS4_LOCK_MAXTIMEOUT)
>  		return NFS4_LOCK_MAXTIMEOUT;
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index e70df40..5b31e21c 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -46,7 +46,11 @@ extern int freeze_kernel_threads(void);
>  extern void thaw_processes(void);
>  extern void thaw_kernel_threads(void);
>  
> -static inline bool try_to_freeze(void)
> +/*
> + * DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION
> + * If try_to_freeze causes a lockdep warning it means the caller may deadlock
> + */
> +static inline bool try_to_freeze_unsafe(void)
>  {
>  	might_sleep();
>  	if (likely(!freezing(current)))
> @@ -54,6 +58,11 @@ static inline bool try_to_freeze(void)
>  	return __refrigerator(false);
>  }
>  
> +static inline bool try_to_freeze(void)
> +{
> +	return try_to_freeze_unsafe();
> +}
> +
>  extern bool freeze_task(struct task_struct *p);
>  extern bool set_freezable(void);
>  
> @@ -115,6 +124,14 @@ static inline void freezer_count(void)
>  	try_to_freeze();
>  }
>  
> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +static inline void freezer_count_unsafe(void)
> +{
> +	current->flags &= ~PF_FREEZER_SKIP;
> +	smp_mb();
> +	try_to_freeze_unsafe();
> +}
> +
>  /**
>   * freezer_should_skip - whether to skip a task when determining frozen
>   *			 state is reached
> @@ -152,6 +169,14 @@ static inline bool freezer_should_skip(struct task_struct *p)
>  	freezer_count();						\
>  })
>  
> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +#define freezable_schedule_unsafe()					\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule();							\
> +	freezer_count_unsafe();						\
> +})
> +
>  /* Like schedule_timeout_killable(), but should not block the freezer. */
>  #define freezable_schedule_timeout_killable(timeout)			\
>  ({									\
> @@ -162,6 +187,16 @@ static inline bool freezer_should_skip(struct task_struct *p)
>  	__retval;							\
>  })
>  
> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +#define freezable_schedule_timeout_killable_unsafe(timeout)		\
> +({									\
> +	long __retval;							\
> +	freezer_do_not_count();						\
> +	__retval = schedule_timeout_killable(timeout);			\
> +	freezer_count_unsafe();						\
> +	__retval;							\
> +})
> +
>  /*
>   * Freezer-friendly wrappers around wait_event_interruptible(),
>   * wait_event_killable() and wait_event_interruptible_timeout(), originally
> @@ -225,9 +260,14 @@ static inline void set_freezable(void) {}
>  
>  #define freezable_schedule()  schedule()
>  
> +#define freezable_schedule_unsafe()  schedule()
> +
>  #define freezable_schedule_timeout_killable(timeout)			\
>  	schedule_timeout_killable(timeout)
>  
> +#define freezable_schedule_timeout_killable_unsafe(timeout)		\
> +	schedule_timeout_killable(timeout)
> +
>  #define wait_event_freezable(wq, condition)				\
>  		wait_event_interruptible(wq, condition)
>  
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index f8529fc..8dcfadc 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -254,7 +254,7 @@ static int rpc_wait_bit_killable(void *word)
>  {
>  	if (fatal_signal_pending(current))
>  		return -ERESTARTSYS;
> -	freezable_schedule();
> +	freezable_schedule_unsafe();
>  	return 0;
>  }
>  

Looks reasonable, but note that CIFS uses wait_event_freezekillable
with locks held too, which will likely have the same problem and will
need the same workaround for now.

-- 
Jeff Layton <jlayton@redhat.com>
