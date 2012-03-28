Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53095 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932411Ab2C1SVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 14:21:11 -0400
Message-ID: <4F735642.9030905@panasas.com>
Date: Wed, 28 Mar 2012 11:19:46 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
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
Subject: Re: [PATCH 4/6 OPTION-A version 3] completion: Add new wait_for_completion_timeout_state
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>  <4F7120B6.2090509@panasas.com> <4F7126E0.5080700@panasas.com> <1332835919.16159.195.camel@twins>
In-Reply-To: <1332835919.16159.195.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2012 01:11 AM, Peter Zijlstra wrote:

> On Mon, 2012-03-26 at 19:33 -0700, Boaz Harrosh wrote:
> 
> 
> So I'm fine with adding wait_for_completion_timeout_state(), but make it
> look and smell like wait_for_completion_timeout() and use a proper
> state, like wake_up_state().
> 
> IOW:
> 
> unsigned long __sched 
> wait_for_completion_timeout_state(struct completion *x, 
> 				  unsigned long timeout,
> 				  unsigned int state)
> {
> 	return wait_for_common(x, timeout, state);
> }
> EXPORT_SYMBOL(wait_for_completion_timeout_state);
> 



Looks good thanks It's what I had at first, and went
overboard with it. KISS right?

I'll resend and use it as is? Should I add a BUG_ON
if state is not one of:
	TASK_UNINTERRUPTIBLE
	TASK_KILLABLE
	TASK_INTERRUPTIBLE

Thanks Peter, this will help me a lot
Boaz
