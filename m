Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49986 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbbFOMqr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 08:46:47 -0400
Date: Mon, 15 Jun 2015 14:46:40 +0200
From: Petr Mladek <pmladek@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
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
Subject: Re: [RFC PATCH 02/18] kthread: Add API for iterant kthreads
Message-ID: <20150615124640.GM9409@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-3-git-send-email-pmladek@suse.cz>
 <20150609062349.GW21465@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150609062349.GW21465@mtj.duckdns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 2015-06-09 15:23:49, Tejun Heo wrote:
> Hello, Petr.
> 
> On Fri, Jun 05, 2015 at 05:01:01PM +0200, Petr Mladek wrote:
> > +static int kthread_iterant_fn(void *kti_ptr)
> > +{
> > +	struct kthread_iterant *kti = kti_ptr;
> > +	void *data = kti->data;
> > +
> > +	if (kti->init)
> > +		kti->init(data);
> > +
> > +	do {
> > +		if (kti->func)
> > +			kti->func(data);
> 
> Is supporting kthread_iterant w/o the body function intentional?  If
> so, did you have anything specific on mind for it?  I don't think it
> matters either way.  Just curious how this came to be.

Good question. It might make sense to add a warning for kthreads
with empty main function.

Best Regards,
Petr
