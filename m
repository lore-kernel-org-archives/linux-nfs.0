Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861Ab3EFK7K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 06:59:10 -0400
Date: Mon, 6 May 2013 06:58:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506065842.25a018f6@tlielax.poochiereds.net>
In-Reply-To: <20130506085025.GB13861@dyad.programming.kicks-ass.net>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130506085025.GB13861@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 6 May 2013 10:50:25 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Fri, May 03, 2013 at 02:04:09PM -0700, Colin Cross wrote:
> > NFS calls the freezable helpers with locks held, which is unsafe
> > and caused lockdep warnings when 6aa9707 "lockdep: check that no
> > locks held at freeze time" was applied (reverted in dbf520a).
> > Add new *_unsafe versions of the helpers that will not run the
> > lockdep test when 6aa9707 is reapplied, and call them from NFS.
> 
> Am I the only one that would like a bit more information about why NFS does
> this and why we need to work around it?
> 

NFS does this because this is how we initially "fixed" it to not block
the freezer. It sucks and is prone to deadlocking if you selectively
freeze processes via the cgroup freezer. It does basically "work" in
most cases though if the freezer is running to suspend the whole system.

I'm looking at fixing this by instead setting points within the NFS/RPC
layers that cause these calls to return something like ERESTARTSYS
instead when a freeze event comes in, depending on whether a call has
already been transmitted to the server.

That's likely to take a while though, and in the meantime we don't want
lockdep complaining every time someone fires off a RPC call with locks
held. So for now, we'd like to "opt out" of these lockdep warnings.

-- 
Jeff Layton <jlayton@redhat.com>
