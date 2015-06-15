Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60227 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754246AbbFOPXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 11:23:17 -0400
Date: Mon, 15 Jun 2015 17:23:13 +0200
From: Petr Mladek <pmladek@suse.cz>
To: Steven Rostedt <rostedt@goodmis.org>
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
Message-ID: <20150615152313.GC3135@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-16-git-send-email-pmladek@suse.cz>
 <20150608134417.3fb7a811@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150608134417.3fb7a811@gandalf.local.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2015-06-08 13:44:17, Steven Rostedt wrote:
> On Fri,  5 Jun 2015 17:01:14 +0200
> Petr Mladek <pmladek@suse.cz> wrote:
> 
> > It takes a while until the ring_buffer_benchmark module is removed
> > when the ring buffer hammer is running. It is because it takes
> > few seconds and kthread_should_terminate() is not being checked.
> > 
> > This patch adds the check for kthread termination into the producer.
> > It uses the existing kill_test flag to finish the kthreads as
> > cleanly as possible.
> > 
> > It disables printing the "ERROR" message when the kthread is going.
> > 
> > Also it makes sure that producer does not go into the 10sec sleep
> > when it is being killed.
> 
> This patch looks like something I may take regardless of the other
> patches (if it applies cleanly).

Please, find below a version of the patch that can be applied against
current Linus tree and also against your for-next branch.

> As for the other patches, the ring buffer benchmark is just that, a
> benchmark that I use when making changes to the ring buffer. It's not
> something for production systems.

I see.

> What about just adding a depend on !LIVE_PATCHING to
> RING_BUFFER_BENCHMARK, or force it to shut down during patching.
> There's no reason to make it safe to be running when you patch the
> kernel. Just adds complexity to some simple code.

I would like to convert all kthreads into some sane API. I hope
that it will make them rather easier. Let's see how it will look
like in the end.

Anyway, the two kthreads in this benchmark are in the "easy" group
regarding patching because they are sleeping only limited time.
