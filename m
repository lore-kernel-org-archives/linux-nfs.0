Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:24072 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932341Ab2JaBQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 21:16:31 -0400
Message-ID: <1351646186.4004.41.camel@gandalf.local.home>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive
 hashtable
From: Steven Rostedt <rostedt@goodmis.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org,
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
Date: Tue, 30 Oct 2012 21:16:26 -0400
In-Reply-To: <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
	 <20121030214257.GB2681@htj.dyndns.org>
	 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-10-30 at 20:33 -0400, Sasha Levin wrote:
> On Tue, Oct 30, 2012 at 5:42 PM, Tejun Heo <tj@kernel.org> wrote:
> > Hello,
> >
> > Just some nitpicks.
> >
> > On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
> >> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> >> +#define hash_min(val, bits)                                                  \
> >> +({                                                                           \
> >> +     sizeof(val) <= 4 ?                                                      \
> >> +     hash_32(val, bits) :                                                    \
> >> +     hash_long(val, bits);                                                   \
> >> +})
> >
> > Doesn't the above fit in 80 column.  Why is it broken into multiple
> > lines?  Also, you probably want () around at least @val.  In general,
> > it's a good idea to add () around any macro argument to avoid nasty
> > surprises.
> 
> It was broken to multiple lines because it looks nicer that way (IMO).
> 
> If we wrap it with () it's going to go over 80, so it's going to stay
> broken down either way :)

({								      \
	sizeof(val) <= 4 ? hash_32(val, bits) : hash_long(val, bits); \
})

Is the better way to go. We are C programmers, we like to see the ?: on
a single line if possible. The way you have it, looks like three
statements run consecutively.

-- Steve


