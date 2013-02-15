Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080Ab3BOWVF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 17:21:05 -0500
Date: Fri, 15 Feb 2013 17:20:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in
 reply cache stats
Message-ID: <20130215172058.29941a54@tlielax.poochiereds.net>
In-Reply-To: <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net>
	<1360958672-5692-1-git-send-email-jlayton@redhat.com>
	<299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Feb 2013 16:14:56 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 15, 2013, at 3:04 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > So we can get a feel for how effective the hashing function is.
> > 
> > As Chuck Lever pointed out to me, it's generally acceptable to do
> > "expensive" stuff when reading the stats since that's a relatively
> > rare activity.
> 
> A good measure of the efficacy of a hash function is the ratio of the maximum chain length to the optimal chain length (which can be computed by dividing the total number of cache entries by the number of hash chains).
> 

Right, the number of chains is always 64 for now (maybe we should print
that out in the stats too), so you can compute that from the values
provided here.

> If we plan to stick with a hash table for this cache, there should be some indication when the hash function falls over.  This will matter because the DRC can now grow much larger, which is turning out to be the real fundamental change with this work.
> 

That's the kicker. With the patch below, computing the max chain length
on the fly is somewhat expensive since you have to walk every entry.
It's certainly possible though (even likely) that the real max length
will occur at some point when we're not looking at this file. So how to
best gauge that?

Maybe we should just punt and move it all to a rbtree or something. A
self-balancing structure is nice and simple to deal with, even if the
insertion penalty is a bit higher...

> A philosophical question though is "How can we know when the DRC is large enough?"
> 

An excellent question, and not an easy one to answer. Clearly 1024
entries was not enough. We now cap the size as a function of the
available low memory, which I think is a reasonable way to keep it from
ballooning so large that the box falls over. We also have a shrinker
and periodic cache cleaner to prune off entries that have expired.

Of course one thing I haven't really considered enough is the
performance implications of walking the potentially much longer hash
chains here.

If that is a problem, then one way to counter that without moving to a
different structure altogether might be to alter the hash function
based on the max size of the cache. IOW, grow the number of hash buckets
as the max cache size grows?

-- 
Jeff Layton <jlayton@redhat.com>
