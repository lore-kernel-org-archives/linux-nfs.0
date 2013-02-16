Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39048 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab3BPNjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 08:39:35 -0500
Date: Sat, 16 Feb 2013 08:39:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in
 reply cache stats
Message-ID: <20130216133927.GA28824@fieldses.org>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net>
 <1360958672-5692-1-git-send-email-jlayton@redhat.com>
 <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
 <20130215172058.29941a54@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130215172058.29941a54@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 15, 2013 at 05:20:58PM -0500, Jeff Layton wrote:
> An excellent question, and not an easy one to answer. Clearly 1024
> entries was not enough. We now cap the size as a function of the
> available low memory, which I think is a reasonable way to keep it from
> ballooning so large that the box falls over. We also have a shrinker
> and periodic cache cleaner to prune off entries that have expired.
> 
> Of course one thing I haven't really considered enough is the
> performance implications of walking the potentially much longer hash
> chains here.
> 
> If that is a problem, then one way to counter that without moving to a
> different structure altogether might be to alter the hash function
> based on the max size of the cache. IOW, grow the number of hash buckets
> as the max cache size grows?

Another reason to organize the cache per client address?

Two levels of hash tables might be good enough: one global hash table
for the client address, one per-client for the rest.

With a per-client maximum number of entries, sizing the hash tables
should be easier.

If we wanted to be fancy in theory the address lookup could probably be
lockless in the typical case.

--b.
