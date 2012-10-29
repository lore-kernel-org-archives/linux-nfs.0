Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58831 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932647Ab2J2Q3I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 12:29:08 -0400
Date: Mon, 29 Oct 2012 12:29:04 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and naive
	hashtable
Message-ID: <20121029162904.GA19509@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <20121029112907.GA9115@Krystal> <CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com> <20121029161412.GB18944@Krystal> <CA+1xoqfBXM4sjvcZtUncnWAaUxA9_YBod3Hjx3ZO=K1oJO_j7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+1xoqfBXM4sjvcZtUncnWAaUxA9_YBod3Hjx3ZO=K1oJO_j7g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On Mon, Oct 29, 2012 at 12:14 PM, Mathieu Desnoyers
> <mathieu.desnoyers@efficios.com> wrote:
> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> On Mon, Oct 29, 2012 at 7:29 AM, Mathieu Desnoyers
> >> <mathieu.desnoyers@efficios.com> wrote:
> >> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> >> +
> >> >> +     for (i = 0; i < sz; i++)
> >> >> +             INIT_HLIST_HEAD(&ht[sz]);
> >> >
> >> > ouch. How did this work ? Has it been tested at all ?
> >> >
> >> > sz -> i
> >>
> >> Funny enough, it works perfectly. Generally as a test I boot the
> >> kernel in a VM and let it fuzz with trinity for a bit, doing that with
> >> the code above worked flawlessly.
> >>
> >> While it works, it's obviously wrong. Why does it work though? Usually
> >> there's a list op happening pretty soon after that which brings the
> >> list into proper state.
> >>
> >> I've been playing with a patch that adds a magic value into list_head
> >> if CONFIG_DEBUG_LIST is set, and checks that magic in the list debug
> >> code in lib/list_debug.c.
> >>
> >> Does it sound like something useful? If so I'll send that patch out.
> >
> > Most of the calls to this initialization function apply it on zeroed
> > memory (static/kzalloc'd...), which makes it useless. I'd actually be in
> > favor of removing those redundant calls (as I pointed out in another
> > email), and document that zeroed memory don't need to be explicitly
> > initialized.
> 
> Why would that make it useless? The idea is that the init functions
> will set the magic field to something random, like:
> 
> .magic = 0xBADBEEF0;
> 
> And have list_add() and friends WARN(.magic != 0xBADBEEF0, "Using an
> uninitialized list\n");
> 
> This way we'll catch all places that don't go through list initialization code.

As I replied to Tejun Heo already, I agree that keeping the
initialization in place makes sense for future-proofness. This intent
should probably be documented in a comment about the initialization
function though, just to make sure nobody will try to skip it.

Thanks,

Mathieu

> 
> 
> Thanks,
> Sasha

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
