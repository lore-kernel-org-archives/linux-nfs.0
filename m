Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32848 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbbFJDNg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 23:13:36 -0400
Date: Wed, 10 Jun 2015 12:13:21 +0900
From: Tejun Heo <tj@kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>,
        live-patching@vger.kernel.org, linux-api@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 06/18] signal/kthread: Initial implementation of
 kthread signal handling
Message-ID: <20150610031321.GF11955@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-7-git-send-email-pmladek@suse.cz>
 <20150609071022.GX21465@mtj.duckdns.org>
 <alpine.LNX.2.00.1506091405360.12753@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.00.1506091405360.12753@pobox.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jiri.

On Tue, Jun 09, 2015 at 02:15:24PM +0200, Jiri Kosina wrote:
> To me, the ultimate goal (*) is to make it possible for kthread to be able 
> to decide whether it wants "some kind of default behavior" (however that'd 
> be defined), or "ignore all", or "just handle this set of signals with 
> these handlers", and make API for this that would avoid every kthread 
> implementing its own complete signal handling.

Yes, cleaning up the current usages like above would be great but one
concern is that the above might inadvertantly encourage usage of
signals in kthreads which I don't think is a good idea.  It'd be great
if we can consolidate the current users while also making it clear
that we shouldn't be adding new ones.

> > While we do have several kthread signal users, they aren't too many and 
> > majority of them use it to allow userland to tell it to shutdown and 
> 
> Yeah. Via SIGKILL. Or SIGTERM. Or SIGINT. Or SIGQUIT. Not really 
> consistent either.

Exactly, and it's pretty confusing from userland.  Why do some
kthreads take SIGTERM but not SIGKILL while others do the other way
and yet others ignore them all?  This is too low level for a userland
visible interface which is tied too closely to the implementation
detail (usage of one kthread) and often unclear in terms of the
meaning of the action.

> > there seem to be a couple which use HUP/USR1 to cancel whatever it's 
> > processing / waiting on at the moment.  Hmmm... jffs uses STOP/CONT too.
> 
> > I don't know how this should be done but let's please try to
> > 
> > 1. Encourage uniform behaviors across the signals.
> 
> Fully agreed.
> 
> > 2. Ultimately discourage usage of signals on kthreads as this closely
> >    ties implementation detail (use of single kthread) to the userland
> >    visible interface in a way where we can't easily get back out of.
> >    For example, what if jffs needs its gc workers to be multi-threaded
> >    and per-NUMA for high-iops devices later on?
> 
> What kind of multi-threading kthreads are you referring to here? Something 
> more sophisticated than simply spawning several per-CPU (or 
> per-whatever-resource) full-fledged kthreads?

Becoming simple multi-threaded or per-cpu are good examples but these
things not too rarely develop into something which needs more
sophiscation.  e.g. jobs which process considerable amount data are
usually best served by NUMA-node-affine workers roughly matching the
number of CPUs in each node.  workqueue is half way there but still
lacking an automatic way to regulate concurrency in those cases.

For certain use cases, you really can't avoid employing a pool of
workers and once things get there, having tied userland interface to a
single kthread becomes pretty awkward.  It sure works for certain use
cases and sending signals to kthreads *might* be considered a "softer"
interface where userland is meddling with kernel implementation
details that it can be changed later on but it can still be painful
for users depending on it.

Thanks.

-- 
tejun
