Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60661 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964854Ab2CVDB5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 23:01:57 -0400
Message-ID: <4F6A92FC.6060702@panasas.com>
Date: Wed, 21 Mar 2012 19:48:28 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Oleg Nesterov <oleg@redhat.com>
CC: "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
        David Rientjes <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()
 API
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com>
In-Reply-To: <4F691383.5040506@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/20/2012 04:32 PM, Boaz Harrosh wrote:
> 
> In the blasphemous occasions that a the Kernel must call a user-mode program
> half of the times it is more robust to not wait forever but limit the wait
> for a specified timeout.
> 
> So add a new  call_usermodehelper_timeout() that implements that.
> (Users of this new API will be added once this API is in mainline)
> 
> call_usermodehelper_fns() is added an extra timeout parameter which
> is then implemented in call_usermodehelper_exec. The few users of
> call_usermodehelper_fns() are also changed in this patch.
> 
> Since now the executing threads might come back after the waiting
> thread has returned, do to a timeout. I used a simple kref pattern
> to govern the life time of the subprocess_info struct.
> 
> Should some wait-forever callers today, be converted to this new
> schema?
> 
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/exec.c                   |    2 +-
>  include/linux/kmod.h        |   15 +++++++++++++--
>  kernel/kmod.c               |   29 +++++++++++++++++++++--------
>  kernel/sys.c                |    2 +-
>  security/keys/request_key.c |    2 +-
>  5 files changed, 37 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 92ce83a..e696081 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -2197,7 +2197,7 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
>  		}
>  
>  		retval = call_usermodehelper_fns(helper_argv[0], helper_argv,
> -					NULL, UMH_WAIT_EXEC, umh_pipe_setup,
> +					NULL, UMH_WAIT_EXEC, 0, umh_pipe_setup,
>  					NULL, &cprm);
>  		argv_free(helper_argv);
>  		if (retval) {
> diff --git a/include/linux/kmod.h b/include/linux/kmod.h
> index 5a89c00..eccc3f5 100644
> --- a/include/linux/kmod.h
> +++ b/include/linux/kmod.h
> @@ -25,6 +25,7 @@
>  #include <linux/compiler.h>
>  #include <linux/workqueue.h>
>  #include <linux/sysctl.h>
> +#include <linux/kref.h>
>  
>  #define KMOD_PATH_LEN 256
>  
> @@ -55,12 +56,14 @@ enum umh_wait {
>  };
>  
>  struct subprocess_info {
> +	struct kref kref;
>  	struct work_struct work;
>  	struct completion *complete;
>  	char *path;
>  	char **argv;
>  	char **envp;
>  	enum umh_wait wait;
> +	unsigned long wait_timeout;
>  	int retval;
>  	int (*init)(struct subprocess_info *info, struct cred *new);
>  	void (*cleanup)(struct subprocess_info *info);
> @@ -69,14 +72,22 @@ struct subprocess_info {
>  
>  extern int
>  call_usermodehelper_fns(char *path, char **argv, char **envp,
> -			enum umh_wait wait,
> +			enum umh_wait wait, unsigned long timeout,
>  			int (*init)(struct subprocess_info *info, struct cred *new),
>  			void (*cleanup)(struct subprocess_info *), void *data);
>  
>  static inline int
>  call_usermodehelper(char *path, char **argv, char **envp, enum umh_wait wait)
>  {
> -	return call_usermodehelper_fns(path, argv, envp, wait,
> +	return call_usermodehelper_fns(path, argv, envp, wait, 0,
> +				       NULL, NULL, NULL);
> +}
> +
> +static inline int
> +call_usermodehelper_timeout(char *path, char **argv, char **envp,
> +			    enum umh_wait wait, unsigned long timeout)
> +{
> +	return call_usermodehelper_fns(path, argv, envp, wait, timeout,
>  				       NULL, NULL, NULL);
>  }
>  
> diff --git a/kernel/kmod.c b/kernel/kmod.c
> index 3cb7457..a72eefa 100644
> --- a/kernel/kmod.c
> +++ b/kernel/kmod.c
> @@ -129,7 +129,7 @@ int __request_module(bool wait, const char *fmt, ...)
>  	trace_module_request(module_name, wait, _RET_IP_);
>  
>  	ret = call_usermodehelper_fns(modprobe_path, argv, envp,
> -			wait ? UMH_WAIT_PROC : UMH_WAIT_EXEC,
> +			wait ? UMH_WAIT_PROC : UMH_WAIT_EXEC, 0,
>  			NULL, NULL, NULL);
>  
>  	atomic_dec(&kmod_concurrent);
> @@ -191,8 +191,11 @@ fail:
>  	do_exit(0);
>  }
>  
> -static void call_usermodehelper_freeinfo(struct subprocess_info *info)
> +static void call_usermodehelper_freeinfo(struct kref *kref)
>  {
> +	struct subprocess_info *info =
> +		container_of(kref, struct subprocess_info, kref);
> +
>  	if (info->cleanup)
>  		(*info->cleanup)(info);
>  	kfree(info);
> @@ -235,6 +238,7 @@ static int wait_for_helper(void *data)
>  	}
>  
>  	complete(sub_info->complete);
> +	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
>  	return 0;
>  }
>  
> @@ -258,7 +262,8 @@ static void __call_usermodehelper(struct work_struct *work)
>  
>  	switch (wait) {
>  	case UMH_NO_WAIT:
> -		call_usermodehelper_freeinfo(sub_info);
> +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
> +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
>  		break;
>  
>  	case UMH_WAIT_PROC:
> @@ -269,6 +274,7 @@ static void __call_usermodehelper(struct work_struct *work)
>  		if (pid < 0)
>  			sub_info->retval = pid;
>  		complete(sub_info->complete);
> +		kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
>  	}
>  }
>  
> @@ -387,6 +393,7 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
>  	if (!sub_info)
>  		goto out;
>  
> +	kref_init(&sub_info->kref);
>  	INIT_WORK(&sub_info->work, __call_usermodehelper);
>  	sub_info->path = path;
>  	sub_info->argv = argv;
> @@ -452,22 +459,27 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info,
>  
>  	sub_info->complete = &done;
>  	sub_info->wait = wait;
> +	if (!sub_info->wait_timeout)
> +		sub_info->wait_timeout = MAX_SCHEDULE_TIMEOUT;
>  
> +	/* Balanced in __call_usermodehelper or wait_for_helper */
> +	kref_get(&sub_info->kref);
>  	queue_work(khelper_wq, &sub_info->work);
>  	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
>  		goto unlock;
> -	wait_for_completion(&done);
> -	retval = sub_info->retval;
> -
> +	if (likely(wait_for_completion_timeout(&done, sub_info->wait_timeout)))
> +		retval = sub_info->retval;
> +	else
> +		retval = -ETIMEDOUT;
>  out:
> -	call_usermodehelper_freeinfo(sub_info);
> +	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
>  unlock:
>  	helper_unlock();
>  	return retval;
>  }
>  
>  int call_usermodehelper_fns(char *path, char **argv, char **envp,
> -			enum umh_wait wait,
> +			enum umh_wait wait, unsigned long timeout,
>  			int (*init)(struct subprocess_info *info, struct cred *new),
>  			void (*cleanup)(struct subprocess_info *), void *data)
>  {
> @@ -480,6 +492,7 @@ int call_usermodehelper_fns(char *path, char **argv, char **envp,
>  		return -ENOMEM;
>  
>  	call_usermodehelper_setfns(info, init, cleanup, data);
> +	info->wait_timeout = timeout;
>  
>  	return call_usermodehelper_exec(info, wait);
>  }
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 9947fb0..a9079d1 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2013,7 +2013,7 @@ int orderly_poweroff(bool force)
>  		goto out;
>  	}
>  
> -	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT,
> +	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT, 0,
>  				      NULL, argv_cleanup, NULL);
>  
>    out:
> diff --git a/security/keys/request_key.c b/security/keys/request_key.c
> index b8cc38c..28050ea 100644
> --- a/security/keys/request_key.c
> +++ b/security/keys/request_key.c
> @@ -93,7 +93,7 @@ static void umh_keys_cleanup(struct subprocess_info *info)
>  static int call_usermodehelper_keys(char *path, char **argv, char **envp,
>  			 struct key *session_keyring, enum umh_wait wait)
>  {
> -	return call_usermodehelper_fns(path, argv, envp, wait,
> +	return call_usermodehelper_fns(path, argv, envp, wait, 0,
>  				       umh_keys_init, umh_keys_cleanup,
>  				       key_get(session_keyring));
>  }

Hi Oleg, Tetsuo, and Andrew

Tetsuo Handa has brought to my attention the existence of this patch:
	http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=ccc7cdcf6ecf7d92300dc83315dde0efb2907f39

Author: Oleg Nesterov <oleg@redhat.com>
Date:   Wed Mar 21 10:57:41 2012 +1100

    usermodehelper: implement UMH_KILLABLE
    
    Implement UMH_KILLABLE, should be used along with UMH_WAIT_EXEC/PROC.  The
    caller must ensure that subprocess_info->path/etc can not go away until
    call_usermodehelper_freeinfo().
    
    call_usermodehelper_exec(UMH_KILLABLE) does wait_for_completion_killable.
    If it fails, it uses xchg(&sub_info->complete, NULL) to serialize with
    umh_complete() which does the same xhcg() to access sub_info->complete.
    
    If call_usermodehelper_exec wins, it can safely return.  umh_complete()
    should get NULL and call call_usermodehelper_freeinfo().
    
    Otherwise we know that umh_complete() was already called, in this case
    call_usermodehelper_exec() falls back to wait_for_completion() which
    should succeed "very soon".
    
    Note: UMH_NO_WAIT == -1 but it obviously should not be used with
    UMH_KILLABLE.  We delay the neccessary cleanup to simplify the back
    porting.
    
    Signed-off-by: Oleg Nesterov <oleg@redhat.com>
    Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Cc: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Tejun Heo <tj@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

And it's surrounding patchset.

I think that my patch above does a much better/cleaner lifetime management of the 
subprocess_info struct, with the use of a kref. Anyway I thought that we are not
suppose to use xhcg() since it is not portable to all ARCHs. ;-)

Please review my patchset above, and comment. If you guys want I can combine
the two sets into one patchset ASAP. (Will try to finish an RFC tomorrow)
Since we are inventing the same mechanisms for slightly different needs.
But basically we both need support for the waiter to be returning before
the child has completed.

Thanks
Boaz
