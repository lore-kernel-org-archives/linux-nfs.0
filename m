Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:7930 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab2JaBgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 21:36:35 -0400
Message-ID: <1351647390.4004.47.camel@gandalf.local.home>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive
 hashtable
From: Steven Rostedt <rostedt@goodmis.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Date: Tue, 30 Oct 2012 21:36:30 -0400
In-Reply-To: <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
	 <20121030214257.GB2681@htj.dyndns.org>
	 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
	 <1351646186.4004.41.camel@gandalf.local.home>
	 <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-10-30 at 18:25 -0700, Linus Torvalds wrote:
> On Tue, Oct 30, 2012 at 6:16 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > ({                                                                    \
> >         sizeof(val) <= 4 ? hash_32(val, bits) : hash_long(val, bits); \
> > })
> >
> > Is the better way to go. We are C programmers, we like to see the ?: on
> > a single line if possible. The way you have it, looks like three
> > statements run consecutively.
> 
> If we're C programmers, why use the non-standard statement-expression
> at all? And split it onto three lines when it's just a single one?

I like the blue color over the pink. Anyway, I was just expressing an
opinion and really didn't care if it was changed or not.


> 
> But whatever. This series has gotten way too much bike-shedding
> anyway. I think it should just be applied, since it does remove lines
> of code overall. I'd even possibly apply it to mainline, but it seems
> to be against linux-next.

I would think this change is a bit too big for an -rc4 release, but
you're the boss.  I've already given my ack for my code that this set
touches. Let it go to Stephen's repo then.

-- Steve


