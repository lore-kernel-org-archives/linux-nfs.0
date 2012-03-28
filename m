Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758228Ab2C1Rrc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 13:47:32 -0400
Date: Wed, 28 Mar 2012 19:38:58 +0200
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
Subject: Re: [PATCH 4/6 OPTION-A version 3] completion: Add new
	wait_for_completion_timeout_state
Message-ID: <20120328173858.GC18944@redhat.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com> <4F7120B6.2090509@panasas.com> <4F7126E0.5080700@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F7126E0.5080700@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26, Boaz Harrosh wrote:
>
> +int __sched
> +wait_for_completion_timeout_state(struct completion *x,
> +				  unsigned long timeout, int state)
> +{
> +	long t;
> +	int ret;
> +
> +	if (!timeout)
> +		timeout = MAX_SCHEDULE_TIMEOUT;
> +
> +	switch (state) {
> +	default:
> +		WARN_ON_ONCE(1);
> +		/* fall through */
> +	case 0:
> +		state = TASK_UNINTERRUPTIBLE;
> +		break;

Well, this looks strange, imho. If the caller wants TASK_UNINTERRUPTIBLE,
it should simply pass TASK_UNINTERRUPTIBLE.
wait_for_completion_timeout_state(state => 0) looks confusing, and this
is not symmetrical wrt other states.

> +	t = wait_for_common(x, timeout, state);
> +	if (likely(t > 0)) {
> +		ret = 0;
> +	} else  {
> +		if (t < 0)
> +			ret = t;
> +		else
> +			ret = -ETIMEDOUT;
> +	}
> +	return ret;

I tend to agree with Peter. This is the common helper, probably it
will have more users. We shouldn't throw out the positive return
value, it can be useful.

call_usermodehelper_exec() can simply do

	retval = wait_for_common(...);

	if (retval > 0)
		retval = sub_info->retval;
	else if (!retval)
		retval = -ETIMEDOUT;

Oleg.

