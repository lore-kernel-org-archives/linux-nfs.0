Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0194.hostedemail.com ([216.40.44.194]:42162 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752022AbbFHRx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 13:53:56 -0400
Date: Mon, 8 Jun 2015 13:44:17 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Richard Weinberger <richard@nod.at>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 15/18] ring_buffer: Allow to exit the ring buffer
 benchmark immediately
Message-ID: <20150608134417.3fb7a811@gandalf.local.home>
In-Reply-To: <1433516477-5153-16-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
	<1433516477-5153-16-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  5 Jun 2015 17:01:14 +0200
Petr Mladek <pmladek@suse.cz> wrote:

> It takes a while until the ring_buffer_benchmark module is removed
> when the ring buffer hammer is running. It is because it takes
> few seconds and kthread_should_terminate() is not being checked.
> 
> This patch adds the check for kthread termination into the producer.
> It uses the existing kill_test flag to finish the kthreads as
> cleanly as possible.
> 
> It disables printing the "ERROR" message when the kthread is going.
> 
> Also it makes sure that producer does not go into the 10sec sleep
> when it is being killed.

This patch looks like something I may take regardless of the other
patches (if it applies cleanly).

As for the other patches, the ring buffer benchmark is just that, a
benchmark that I use when making changes to the ring buffer. It's not
something for production systems.

What about just adding a depend on !LIVE_PATCHING to
RING_BUFFER_BENCHMARK, or force it to shut down during patching.
There's no reason to make it safe to be running when you patch the
kernel. Just adds complexity to some simple code.

-- Steve
