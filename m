Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35286 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbbFIGYD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 02:24:03 -0400
Date: Tue, 9 Jun 2015 15:23:49 +0900
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
Subject: Re: [RFC PATCH 02/18] kthread: Add API for iterant kthreads
Message-ID: <20150609062349.GW21465@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-3-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-3-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Petr.

On Fri, Jun 05, 2015 at 05:01:01PM +0200, Petr Mladek wrote:
> +static int kthread_iterant_fn(void *kti_ptr)
> +{
> +	struct kthread_iterant *kti = kti_ptr;
> +	void *data = kti->data;
> +
> +	if (kti->init)
> +		kti->init(data);
> +
> +	do {
> +		if (kti->func)
> +			kti->func(data);

Is supporting kthread_iterant w/o the body function intentional?  If
so, did you have anything specific on mind for it?  I don't think it
matters either way.  Just curious how this came to be.

Thanks.

-- 
tejun
