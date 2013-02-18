Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:47860 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab3BRQSW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 11:18:22 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in reply cache stats
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130218093948.670ddb06@tlielax.poochiereds.net>
Date: Mon, 18 Feb 2013 11:18:06 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <50239A71-7563-434D-B69C-9D7009BD43F1@oracle.com>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net> <1360958672-5692-1-git-send-email-jlayton@redhat.com> <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com> <20130215172058.29941a54@tlielax.poochiereds.net> <20130216133927.GA28824@fieldses.org> <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com> <20130218093948.670ddb06@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 9:39 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Sat, 16 Feb 2013 12:18:18 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Feb 16, 2013, at 8:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> On Fri, Feb 15, 2013 at 05:20:58PM -0500, Jeff Layton wrote:
>>>> An excellent question, and not an easy one to answer. Clearly 1024
>>>> entries was not enough. We now cap the size as a function of the
>>>> available low memory, which I think is a reasonable way to keep it from
>>>> ballooning so large that the box falls over. We also have a shrinker
>>>> and periodic cache cleaner to prune off entries that have expired.
>>>> 
>>>> Of course one thing I haven't really considered enough is the
>>>> performance implications of walking the potentially much longer hash
>>>> chains here.
>>>> 
>>>> If that is a problem, then one way to counter that without moving to a
>>>> different structure altogether might be to alter the hash function
>>>> based on the max size of the cache. IOW, grow the number of hash buckets
>>>> as the max cache size grows?
>> 
>> The trouble with a hash table is that once you've allocated it, it's a heavy lift to increase the table size.  That sort of logic adds complexity and additional locking, and is often difficult to test.
>> 
> 
> I wasn't suggesting that we resize/rebalance the table on the fly. We
> determine the max allowable number of cache entries when the server
> starts. We could also determine the number of buckets at the same time,
> and alter the hashing function to take that number into account.
> 
> Of course, more buckets may not help if the hash function just sucks.

My point was that using a data structure like an rbtree, as you suggested, has the advantage of not requiring any extra logic (whether done statically or dynamically).  An rbtree implementation is much more likely to exercise exactly the same code paths no matter how many entries are in the cache.  It will scale deterministically as DRC capacity continues to increase over time.  And it is not dependent on efficient hash-ability of client XIDs.


> 
>>> Another reason to organize the cache per client address?
>> 
>> 
>> In theory, an active single client could evict all entries for other clients, but do we know this happens in practice?
>> 
> 
> I'm pretty sure that's what's been happening to our QA group. They have
> some shared NFS servers set up in the test lab for client testing. When
> things get busy, they the DRC just plain doesn't appear to work. It's
> hard to know for sure though since the problem only crops up very
> rarely.
> 
> My hope is that the massive increase in the size of the DRC should
> prevent that from occurring now.

Well, right.  If the DRC is too small already, any client can cause entries to be evicted prematurely, even its own entries.  Now we have an opportunity to ask whether a larger cache makes it much less likely that a single obnoxious client will effect his neighbors.  In other words, maybe per-client sensitivity doesn't buy us much if the DRC can grow larger.


> 
>>> With a per-client maximum number of entries, sizing the hash tables
>>> should be easier.
>> 
>> 
>> When a server has only one client, should that client be allowed to maximize the use of a server's resources (eg, use all of the DRC resource the server has available)?  How about when a server has one active client and multiple quiescent clients?
>> 
> 
> Again, we have two "problems" to solve, and we need to take care not to
> conflate them too much.
> 
> 1) how do we best organize the cache for efficient lookups?
> 
> 2) what cache eviction policy should we use?

These are related, I feel.  Because memory capacity is increasing faster than memory bandwidth, I think lookup time efficiency is relatively more important than cache space efficiency.  Also, above we were arguing that a larger DRC is more effective.

What's more, 2) is a much harder problem to solve well.  And if lookups are efficient anyway, then 2) should matter much less, as it will only be needed to deal with memory pressure on the server, and not to keep lookup time efficient.

I was proposing the approach of dealing with per-client caching with 2) (choosing which entry to evict based on how many entries there are for each client).  But 2) looks less critical than 1), thus perhaps per-client caching may not provide a lot of benefit.


> Organizing the cache based on client address might help both of those,
> but we'll need to determine whether it's worth the extra complexity.

Agree.  Data, data, data.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




