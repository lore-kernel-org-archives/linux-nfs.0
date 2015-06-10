Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0103.hostedemail.com ([216.40.44.103]:34862 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965211AbbFJOHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2015 10:07:35 -0400
Date: Wed, 10 Jun 2015 10:07:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Peter Zijlstra <peterz@infradead.org>
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
Message-ID: <20150610100729.6a674c15@gandalf.local.home>
In-Reply-To: <20150610090724.GD3644@twins.programming.kicks-ass.net>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
	<1433516477-5153-10-git-send-email-pmladek@suse.cz>
	<20150605161021.GJ19282@twins.programming.kicks-ass.net>
	<20150608134810.3abd862b@gandalf.local.home>
	<20150610090724.GD3644@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Jun 2015 11:07:24 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> > Not to mention, tasks in TASK_UNINTERRUPTIBLE state for too long will
> > trigger hung task detection.
> 
> Right, and I had not considered that, but it turns out the hung_task
> detector checks p->state == TASK_UNINTERRUPTIBLE, so TASK_IDLE is indeed
> safe from that.

Also, I would assume that TASK_IDLE only makes sense for kernel
threads, I wonder if we should add an assertion in schedule that
triggers if a task is scheduling with TASK_IDLE and is not a kernel
thread (has its own mm?)

-- Steve
