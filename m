From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd: convert reclaimer thread to kthread interface
Date: Mon, 3 Nov 2008 22:20:05 -0500
Message-ID: <6986AC0B-97C8-4FBB-9ED2-7586CCA679D0@fys.uio.no>
References: <1225278945-15407-1-git-send-email-jlayton@redhat.com> <20081103131215.75a83236.akpm@linux-foundation.org> <20081103191924.16528bfd@tleilax.poochiereds.net>
Mime-Version: 1.0 (iPhone Mail 5F136)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"hch@infradead.org" <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:37106 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbYKDDUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 22:20:35 -0500
In-Reply-To: <20081103191924.16528bfd-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 3, 2008, at 19:19, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 3 Nov 2008 13:12:15 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Wed, 29 Oct 2008 07:15:45 -0400
>> Jeff Layton <jlayton@redhat.com> wrote:
>>
>>> My understanding is that there is a push to turn the kernel_thread
>>> interface into a non-exported symbol and move all kernel threads  
>>> to use
>>> the kthread API. This patch changes lockd to use kthread_run to  
>>> spawn
>>> the reclaimer thread.
>>>
>>> I've made the assumption here that the extra module references taken
>>> when we spawn this thread are unnecessary and removed them. I've  
>>> also
>>> added a KERN_ERR printk that pops if the thread can't be spawned  
>>> to warn
>>> the admin that the locks won't be reclaimed.
>>>
>>> I consider this patch 2.6.29 material.
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> fs/lockd/clntlock.c |   14 +++++++++-----
>>> 1 files changed, 9 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
>>> index 8307dd6..fcc2378 100644
>>> --- a/fs/lockd/clntlock.c
>>> +++ b/fs/lockd/clntlock.c
>>> @@ -14,6 +14,7 @@
>>> #include <linux/sunrpc/svc.h>
>>> #include <linux/lockd/lockd.h>
>>> #include <linux/smp_lock.h>
>>> +#include <linux/kthread.h>
>>>
>>> #define NLMDBG_FACILITY        NLMDBG_CLIENT
>>>
>>> @@ -191,11 +192,15 @@ __be32 nlmclnt_grant(const struct sockaddr  
>>> *addr, const struct nlm_lock *lock)
>>> void
>>> nlmclnt_recovery(struct nlm_host *host)
>>> {
>>> +    struct task_struct *task;
>>> +
>>>    if (!host->h_reclaiming++) {
>>>        nlm_get_host(host);
>>> -        __module_get(THIS_MODULE);
>>> -        if (kernel_thread(reclaimer, host, CLONE_FS |  
>>> CLONE_FILES) < 0)
>>> -            module_put(THIS_MODULE);
>>> +        task = kthread_run(reclaimer, host, "%s-reclaim", host- 
>>> >h_name);
>>> +        if (IS_ERR(task))
>>> +            printk(KERN_ERR "lockd: unable to spawn reclaimer "
>>> +                "thread. Locks for %s won't be reclaimed! "
>>> +                "(%ld)\n", host->h_name, PTR_ERR(task));
>>>    }
>>> }
>>>
>>> @@ -207,7 +212,6 @@ reclaimer(void *ptr)
>>>    struct file_lock *fl, *next;
>>>    u32 nsmstate;
>>>
>>> -    daemonize("%s-reclaim", host->h_name);
>>>    allow_signal(SIGKILL);
>>>
>>>    down_write(&host->h_rwsem);
>>> @@ -261,5 +265,5 @@ restart:
>>>    nlm_release_host(host);
>>>    lockd_down();
>>>    unlock_kernel();
>>> -    module_put_and_exit(0);
>>> +    return 0;
>>> }
>>
>> Looks OK to me.  I assume the SIGKILL handling has been carefully  
>> tested?
>>
>>
>> Is it correct to emit a warning and keep going if the thread didn't
>> start?  Or would it be safer&saner to fail the whole mount (or  
>> whatever
>> syscall we're doing here..)
>>
>
> Forgot to answer this part...
>
> This thread gets kicked off when the server has rebooted and we need  
> to
> reclaim our locks. There isn't a syscall on which we can return an
> error to the user.
>
> Aside from just warning the admin, I'm not sure what we can do here.  
> We
> might be able to start making all syscalls on the mount fail somehow,
> but I don't think we have infrastructure for that and that may be
> overkill anyway. I suppose we could also go to sleep and try to  
> spawn the
> thread again, but there's no guarantee of success there.
>>
>>
>>
>>
>>
>>

At some point RSN we should implement SIGLOST. That would be the  
closest thing we have to a *NIX standard for reporting the loss of  
filesystem state to the application.

Trond
