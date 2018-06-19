Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45260 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbeFSXJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 19:09:58 -0400
Subject: Re: [PATCH] locking/rwsem: Fix up_read_non_owner() warning with
 DEBUG_RWSEMS
To: Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Arnd Bergmann <arnd@arndb.de>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
References: <1527168398-4291-1-git-send-email-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <ba5a8266-b475-0f80-50eb-1ed39ffa6d2a@redhat.com>
Date: Wed, 20 Jun 2018 07:09:54 +0800
MIME-Version: 1.0
In-Reply-To: <1527168398-4291-1-git-send-email-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/2018 09:26 PM, Waiman Long wrote:
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
>  tch
>  	__down_read(sem);
> +	rwsem_set_reader_owned(sem);
>  }
>  
>  EXPORT_SYMBOL(down_read_non_owner);

Since the 4.18 merge window has been closed. Can that patch be merged
upstream?

Cheers,
Longman

