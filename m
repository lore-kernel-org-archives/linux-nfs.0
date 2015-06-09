Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35505 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbbFIGO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 02:14:59 -0400
Date: Tue, 9 Jun 2015 15:14:46 +0900
From: Tejun Heo <tj@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
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
Subject: Re: [RFC PATCH 00/18] kthreads/signal: Safer kthread API and signal
 handling
Message-ID: <20150609061446.GV21465@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <20150605162216.GK19282@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150605162216.GK19282@twins.programming.kicks-ass.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey, Peter.

On Fri, Jun 05, 2015 at 06:22:16PM +0200, Peter Zijlstra wrote:
> There's a lot more problems with workqueues:
> 
>  - they're not regular tasks and all the task controls don't work on
>    them. This means all things scheduler, like cpu-affinity, nice, and
>    RT/deadline scheduling policies. Instead there is some half baked
>    secondary interface for some of these.

Because there's a pool of them and the workers come and go
dynamically.  There's no way around it.  The attributes just have to
be per-pool.

>    But this also very much includes things like cgroups, which brings me
>    to the second point.
>
>  - its oblivious to cgroups (as it is to RT priority for example) both
>    leading to priority inversion. A work enqueued from a deep/limited
>    cgroup does not inherit the task's cgroup. Instead this work is ran
>    from the root cgroup.
> 
>    This breaks cgroup isolation, more significantly so when a large part
>    of the actual work is done from workqueues (as some workloads end up
>    being). Instead of being able to control the work, it all ends up in
>    the root cgroup outside of control.

cgroup support will surely be added but I'm not sure we can or should
do inheritance automatically.  Using a different API doesn't solve the
problem automatically either.  A lot of kthreads are shared
system-wide after all.  We'll need an abstraction layer to deal with
that no matter where we do it.

Thanks.

-- 
tejun
