Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57362 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbbFQLfH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 07:35:07 -0400
Date: Wed, 17 Jun 2015 04:34:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
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
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 00/18] kthreads/signal: Safer kthread API and signal
 handling
Message-ID: <20150617113450.GA28508@infradead.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2015 at 05:00:59PM +0200, Petr Mladek wrote:
> Kthreads are implemented as an infinite loop. They include check points
> for termination, freezer, parking, and even signal handling.
> 
> We need to touch all kthreads every time we want to add or
> modify the behavior of such checkpoints. It is not easy because
> there are several hundreds of kthreads and each of them is
> implemented in a slightly different way.
> 
> This anarchy brings potentially broken or non-standard behavior.
> For example, few kthreads already handle signals a strange way.
> 
> 
> This patchset is a _proof-of-concept_ how to improve the situation.

Maybe it might be a better idea to audit the existing callers of
signals for kthreads and first check if we can get rid of them.  Then
as a second step if any are left convert them to signalfd-style
operation where signals aren't checked synchronously but as something
the threads can consume on a as needed basis.
