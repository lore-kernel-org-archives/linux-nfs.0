Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0045.hostedemail.com ([216.40.44.45]:51755 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751550AbbFOPds (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2015 11:33:48 -0400
Date: Mon, 15 Jun 2015 11:33:43 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Petr Mladek <pmladek@suse.cz>
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
Message-ID: <20150615113343.215bcd43@gandalf.local.home>
In-Reply-To: <20150615152313.GC3135@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
	<1433516477-5153-16-git-send-email-pmladek@suse.cz>
	<20150608134417.3fb7a811@gandalf.local.home>
	<20150615152313.GC3135@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 15 Jun 2015 17:23:13 +0200
Petr Mladek <pmladek@suse.cz> wrote:


> Please, find below a version of the patch that can be applied against
> current Linus tree and also against your for-next branch.
> 

Thanks, just on Friday, I was testing ring buffer changes with the
ringbuffer benchmark, and was bitching about how I had to wait the 10
seconds before the module would unload ;-)

-- Steve
