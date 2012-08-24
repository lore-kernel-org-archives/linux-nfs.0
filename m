Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51113 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933042Ab2HXULa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Aug 2012 16:11:30 -0400
Message-ID: <5037E00B.6090606@gmail.com>
Date: Fri, 24 Aug 2012 22:11:55 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
To: Tejun Heo <tj@kernel.org>
CC: torvalds@linux-foundation.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com> <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com>
In-Reply-To: <20120824195941.GC21325@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/24/2012 09:59 PM, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Fri, Aug 24, 2012 at 09:47:19PM +0200, Sasha Levin wrote:
>>> I think this is problematic.  It looks exactly like other existing
>>> DEFINE macros yet what its semantics is different.  I don't think
>>> that's a good idea.
>>
>> I can switch that to be DECLARE_HASHTABLE() if the issue is semantics.
> 
> If this implementation is about the common trivial case, why not just
> have the usual DECLARE/DEFINE_HASHTABLE() combination?

When we add the dynamic non-resizable support, how would DEFINE_HASHTABLE() look?

>>> So, I think it would be best to keep this one as straight-forward and
>>> trivial as possible.  Helper macros to help its users are fine but
>>> let's please not go for full encapsulation.
>>
>> What if we cut off the dynamic allocated (but not resizable) hashtable out for
>> the moment, and focus on the most common statically allocated hashtable case?
>>
>> The benefits would be:
>>
>>  - Getting rid of all the _size() macros, which will make the amount of helpers
>> here reasonable.
>>  - Dynamically allocated hashtable can be easily added as a separate
>> implementation using the same API. We already have some of those in the kernel...
> 
> It seems we have enough of this static usage and solving the static
> case first shouldn't hinder the dynamic (!resize) case later, so,
> yeah, sounds good to me.
> 
>>  - When that's ready, I feel it's a shame to lose full encapsulation just due to
>> hash_hashed().
> 
> I don't know.  If we stick to the static (or even !resize dymaic)
> straight-forward hash - and we need something like that - I don't see
> what the full encapsulation buys us other than a lot of trivial
> wrappers.

Which macros do you consider as trivial within the current API?

Basically this entire thing could be reduced to DEFINE/DECLARE_HASHTABLE and
get_bucket(), but it would make the life of anyone who wants a slightly
different hashtable a hell.

I think that right now the only real trivial wrapper is hash_hashed(), and I
think it's a price worth paying to have a single hashtable API instead of
fragmenting it when more implementations come along.

Thanks,
Sasha

> 
> Thanks.
> 

