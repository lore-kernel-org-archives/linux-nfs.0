Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36093 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517AbbFIHUQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 03:20:16 -0400
Date: Tue, 9 Jun 2015 16:20:03 +0900
From: Tejun Heo <tj@kernel.org>
To: Petr Mladek <pmladek@suse.cz>
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
Subject: Re: [RFC PATCH 07/18] kthread: Make iterant kthreads freezable by
 default
Message-ID: <20150609072003.GY21465@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-8-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-8-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Petr.

On Fri, Jun 05, 2015 at 05:01:06PM +0200, Petr Mladek wrote:
> Many kthreads already calls set_freezable() before they enter the main
> cycle. One of the reasons for creating iterant kthreads is to create
> a safe point for freezing and make even more kthreads properly
> freezable. Therefore it would make sense to set all iterant
> kthreads freezable by default.

Actually, for most cases, making kthreads freezable is unnecessary and
often indicative of something going wrong.  This is a crude mechanism
which goes along the line of "if all threads are stopped, the machine
should be safe to be put into whatever state", which isn't true at all
as there usually are a lot of stuff going on asynchronously especially
when interacting with hardware.

In most cases, we want to implement proper power management callbacks
which plug new issuance of whatever work-unit the code is dealing with
and drain in-flight ones.  Whether the worker threads are frozen or
not doesn't matter once that's implemented.

It seems that people have been marking kthreads freezable w/o really
thinking about it - some of them are subtly broken due to missing
drainage of in-flight things while others simply don't need freezing
for correctness.

We do want to clean up freezer usage in the kernel but definitely do
not want to make kthreads freezable by default especially given that
the freezer essentially is one giant lockdep-less system-wide lock.

> However some kthreads might be hard to make properly freezable.
> For example, if they do non-interruptible sleeps. They would
> need to explicitly clear PF_NOFREEZE flag in the init() call.
> But it should be avoided whenever possible.

So, big no here.

Thanks.

-- 
tejun
