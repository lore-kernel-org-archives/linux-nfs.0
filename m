Return-Path: linux-nfs-owner@vger.kernel.org
Received: from merlin.infradead.org ([205.233.59.134]:42749 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab2C0INH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2012 04:13:07 -0400
Message-ID: <1332835919.16159.195.camel@twins>
Subject: Re: [PATCH 4/6 OPTION-A version 3] completion: Add new
 wait_for_completion_timeout_state
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-security-module@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
        Paul Turner <pjt@google.com>, Thomas Gleixner <tglx@linutronix.de>,
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
Date: Tue, 27 Mar 2012 10:11:59 +0200
In-Reply-To: <4F7126E0.5080700@panasas.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
	 <4F7120B6.2090509@panasas.com> <4F7126E0.5080700@panasas.com>
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-03-26 at 19:33 -0700, Boaz Harrosh wrote:
> +int __sched
> +wait_for_completion_timeout_state(struct completion *x,
> +                                 unsigned long timeout, int state)
> +{
> +       long t;
> +       int ret;
> +
> +       if (!timeout)
> +               timeout = MAX_SCHEDULE_TIMEOUT;
> +
> +       switch (state) {
> +       default:
> +               WARN_ON_ONCE(1);
> +               /* fall through */
> +       case 0:
> +               state = TASK_UNINTERRUPTIBLE;
> +               break;
> +       case TASK_KILLABLE:
> +       case TASK_INTERRUPTIBLE:
> +               break;
> +       }

Don't do this, just pass in TASK_UNINTERRUPTIBLE (or TASK_NORMAL)
whatever you like/need.

Don't fudge it by over-loading TASK_RUNNING (aka. 0).

> +       t = wait_for_common(x, timeout, state);
> +       if (likely(t > 0)) {
> +               ret = 0;
> +       } else  {
> +               if (t < 0)
> +                       ret = t;
> +               else
> +                       ret = -ETIMEDOUT;
> +       }
> +       return ret;

Again, why wreck an entirely reasonable return code and break with the
rest of the API.

> +}
> +EXPORT_SYMBOL(wait_for_completion_timeout_state); 


So I'm fine with adding wait_for_completion_timeout_state(), but make it
look and smell like wait_for_completion_timeout() and use a proper
state, like wake_up_state().

IOW:

unsigned long __sched 
wait_for_completion_timeout_state(struct completion *x, 
				  unsigned long timeout,
				  unsigned int state)
{
	return wait_for_common(x, timeout, state);
}
EXPORT_SYMBOL(wait_for_completion_timeout_state);


