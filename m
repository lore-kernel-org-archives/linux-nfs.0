Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61854 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932634Ab3CDWIv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 17:08:51 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Mandeep Singh Baines <msb@chromium.org>, Jeff Layton <jlayton@redhat.com>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Mon, 4 Mar 2013 22:08:34 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	 <20130304092310.1d21100c@tlielax.poochiereds.net>
	 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
	 <20130304205307.GA13527@redhat.com>
In-Reply-To: <20130304205307.GA13527@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-03-04 at 21:53 +0100, Oleg Nesterov wrote:
> On 03/04, Mandeep Singh Baines wrote:
> >
> > The problem is that freezer_count() calls try_to_freeze(). In this
> > case, try_to_freeze() is not really adding any value.
> 
> Well, I tend to agree.
> 
> If a task calls __refrigerator() holding a lock which another freezable
> task can wait for, this is not freezer-friendly.
> 
> freezable_schedule/freezer_do_not_count/etc not only means "I won't be
> active if freezing()", it should also mean "I won't block suspend/etc".

If suspend for some reason requires a re-entrant mount, then yes, I can
see how it might be a problem that we're holding a mount-related lock.
The question is why is that necessary?

> OTOH, I understand that probably it is not trivial to change this code
> to make it freezer-friendly. But at least  I disagree with "push your
> problems onto others".

That code can't be made freezer-friendly if it isn't allowed to hold
basic filesystem-related locks across RPC calls. A number of those RPC
calls do things that need to be protected by VFS or MM-level locks.
i.e.: lookups, file creation/deletion, page fault in/out, ...
 
IOW: the problem would need to be solved differently, possibly by adding
a new FIFREEZE-like call to allow the filesystem to quiesce itself
_before_ NetworkManager pulls the rug out from underneath it. There
would still be plenty of corner cases to keep people entertained (e.g.
the server goes down before the quiesce call is invoked) but at least
the top 90% of cases would be solved.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
