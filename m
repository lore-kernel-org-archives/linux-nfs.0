Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53365 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab2HXVXx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Aug 2012 17:23:53 -0400
Date: Fri, 24 Aug 2012 14:23:48 -0700
From: Tejun Heo <tj@kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
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
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
Message-ID: <20120824212348.GK21325@google.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
 <1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
 <20120822180138.GA19212@google.com>
 <50357840.5020201@gmail.com>
 <20120823200456.GD14962@google.com>
 <5037DA47.9010306@gmail.com>
 <20120824195941.GC21325@google.com>
 <5037E00B.6090606@gmail.com>
 <20120824203332.GF21325@google.com>
 <5037E9D9.9000605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5037E9D9.9000605@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Fri, Aug 24, 2012 at 10:53:45PM +0200, Sasha Levin wrote:
> Yup, but we could be using the same API for dynamic non-resizable and static if
> we go with the DECLARE/hash_init. We could switch between them (and other
> implementations) without having to change the code.

I think it's better to stick with the usual conventions.

> > * DECLARE/DEFINE
> > * hash_head()
> > * hash_for_each_head()
> > * hash_add*()
> > * hash_for_each_possible*()
>  * hash_for_each*() ?
> 
> Why do we need hash_head/hash_for_each_head()? I haven't stumbled on a place yet
> that needed direct access to the bucket itself.

Because whole hash table walking is much less common and we can avoid
another full set of iterators.

> This basically means 11 macros/functions that would let us have full
> encapsulation and will make it very easy for future implementations to work with
> this API instead of making up a new one. It's also not significantly (+~2-3)
> more than the ones you listed.

I'm not sure whether full encapsulation is a good idea for trivial
hashtable.  For higher level stuff, sure but at this level I think
benefits coming from known obvious implementation can be larger.
e.g. suppose the caller knows certain entries to be way colder than
others and wants to put them at the end of the chain.

So, I think implmenting the minimal set of helpers which reflect the
underlying trivial implementation explicitly could actually be better
even when discounting the reduced number of wrappers.

Thanks.

-- 
tejun
