Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34336 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754283AbbFOPyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 11:54:33 -0400
Date: Mon, 15 Jun 2015 17:54:28 +0200
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
Message-ID: <20150615155428.GD3135@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-16-git-send-email-pmladek@suse.cz>
 <20150608134417.3fb7a811@gandalf.local.home>
 <20150615152313.GC3135@pathway.suse.cz>
 <20150615113343.215bcd43@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150615113343.215bcd43@gandalf.local.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2015-06-15 11:33:43, Steven Rostedt wrote:
> On Mon, 15 Jun 2015 17:23:13 +0200
> Petr Mladek <pmladek@suse.cz> wrote:
> 
> 
> > Please, find below a version of the patch that can be applied against
> > current Linus tree and also against your for-next branch.
> > 
> 
> Thanks, just on Friday, I was testing ring buffer changes with the
> ringbuffer benchmark, and was bitching about how I had to wait the 10
> seconds before the module would unload ;-)

I am glad that it will be useful.

Please, find below a version with a small typo fix. Heh, I spent a lot
of time with doulbe checking the patch and then decided to do a last
minute change. It produced "only" compilation warning that I missed.
It was not visible with my testing :-(
