Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbbFFW7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jun 2015 18:59:54 -0400
Date: Sun, 7 Jun 2015 00:58:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
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
        Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>,
        live-patching@vger.kernel.org, linux-api@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 11/18] jffs2: Convert jffs2_gcd_mtd kthread into
	the iterant API
Message-ID: <20150606225854.GA20352@redhat.com>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-12-git-send-email-pmladek@suse.cz> <20150606211648.GA15591@redhat.com> <alpine.LNX.2.00.1506062322550.12753@pobox.suse.cz> <20150606223001.GA18838@redhat.com> <alpine.LNX.2.00.1506070034100.12753@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.00.1506070034100.12753@pobox.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07, Jiri Kosina wrote:
>
> On Sun, 7 Jun 2015, Oleg Nesterov wrote:
>
> > > I personally don't see a huge principal difference between
> > > "kthread_signal_dequeue() + kthread_do_signal_{stop,...}" vs. generic
> > > "kthread_do_signal()" that's just basically completely general and
> > > takes care of 'everything necessary'.
> >
> > Then why do we need the new API ?
>
> Well, in a nutshell, because of the "it's general and takes care of
> everything" part.

...

> Signal handling is just
> one of the piggy-backers on top of this general cleanup.

And to avoid the confusion: so far I only argued with the signal
handling part of this API. Namely with kthread_do_signal(), especially
with the SIG_DFL logic.

If we want somthing like kthread_iterant agree it should probably help to
handle the signals too. But afaics kthread_do_signal() doesn't really help
and certainly it is not strictly necessary.

Oleg.

