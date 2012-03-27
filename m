Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab2C0PwW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 11:52:22 -0400
Date: Tue, 27 Mar 2012 17:43:05 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-security-module@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>,
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
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: Re: [PATCH 5/6] kmod: Add new call_usermodehelper_timeout() API
Message-ID: <20120327154305.GA19314@redhat.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com> <4F712246.6030201@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F712246.6030201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz,

I'll read this series tomorrow, but

On 03/26, Boaz Harrosh wrote:
>
>  int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
>  {
>  	DECLARE_COMPLETION_ONSTACK(done);
> +	int wait_state;
>  	int retval = 0;
>
>  	helper_lock();
> @@ -540,19 +541,15 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
>  	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
>  		goto unlock;
>
> -	if (wait & UMH_KILLABLE) {
> -		retval = wait_for_completion_killable(&done);
> -		if (!retval)
> -			goto wait_done;
> -
> +	wait_state = (wait & UMH_KILLABLE) ? TASK_KILLABLE : 0;
> +	retval = wait_for_completion_timeout_state(&done, sub_info->timeout,
> +						   wait_state);
> +	if (unlikely(retval)) {
>  		/* umh_complete() will see NULL and free sub_info */
>  		if (xchg(&sub_info->complete, NULL))
>  			goto unlock;
> -		/* fallthrough, umh_complete() was already called */
>  	}
>
> -	wait_for_completion(&done);

at first glance this looks certainly wrong, or I misread the patch.

We can't remove the "fallback to wait_for_completion" logic until
you move the completion into subprocess_info (the next patch seems
to do this).

xchg() can race with umh_complete(). If it returns NULL, umh_complete()
was already called and got ->complete != NULL, we must not return until
umh_complete() finishes complete().

Oleg.

