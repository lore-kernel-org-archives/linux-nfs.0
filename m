Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:60474 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753594AbeFTJR7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2018 05:17:59 -0400
Date: Wed, 20 Jun 2018 11:17:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Arnd Bergmann <arnd@arndb.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] locking/rwsem: Fix up_read_non_owner() warning with
 DEBUG_RWSEMS
Message-ID: <20180620091752.GL2476@hirez.programming.kicks-ass.net>
References: <1527168398-4291-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1527168398-4291-1-git-send-email-longman@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2018 at 09:26:38AM -0400, Waiman Long wrote:
> It was found that the use of up_read_non_owner() in NFS was causing
> the following warning when DEBUG_RWSEMS was configured.
> 
>   DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)(1UL << 0)))
> 
> Looking into the rwsem.c file, it was discovered that the corresponding
> down_read_non_owner() function was not setting the owner field properly.
> This is fixed now, and the warning should be gone.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> ---
>  kernel/locking/rwsem.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
> index bc1e507..776308d 100644
> --- a/kernel/locking/rwsem.c
> +++ b/kernel/locking/rwsem.c
> @@ -181,6 +181,7 @@ void down_read_non_owner(struct rw_semaphore *sem)
>  	might_sleep();
>  
>  	__down_read(sem);
> +	rwsem_set_reader_owned(sem);
>  }
>  
>  EXPORT_SYMBOL(down_read_non_owner);
> -- 
> 1.8.3.1
> 
