Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57602 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbFJJHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2015 05:07:38 -0400
Date: Wed, 10 Jun 2015 11:07:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>,
        Ingo Molnar <mingo@redhat.com>, Richard Weinberger <richard@nod.at>,
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
Subject: Re: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in
 iterant kthreads
Message-ID: <20150610090724.GD3644@twins.programming.kicks-ass.net>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-10-git-send-email-pmladek@suse.cz>
 <20150605161021.GJ19282@twins.programming.kicks-ass.net>
 <20150608134810.3abd862b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150608134810.3abd862b@gandalf.local.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 08, 2015 at 01:48:10PM -0400, Steven Rostedt wrote:
> > commit 80ed87c8a9ca0cad7ca66cf3bbdfb17559a66dcf
> > Author: Peter Zijlstra <peterz@infradead.org>
> > Date:   Fri May 8 14:23:45 2015 +0200
> > 
> >     sched/wait: Introduce TASK_NOLOAD and TASK_IDLE
> >     
> >     Currently people use TASK_INTERRUPTIBLE to idle kthreads and wait for
> >     'work' because TASK_UNINTERRUPTIBLE contributes to the loadavg. Having
> >     all idle kthreads contribute to the loadavg is somewhat silly.
> 
> Not to mention, tasks in TASK_UNINTERRUPTIBLE state for too long will
> trigger hung task detection.

Right, and I had not considered that, but it turns out the hung_task
detector checks p->state == TASK_UNINTERRUPTIBLE, so TASK_IDLE is indeed
safe from that.
