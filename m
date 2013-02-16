Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:42884 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab3BPRS3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Feb 2013 12:18:29 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in reply cache stats
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130216133927.GA28824@fieldses.org>
Date: Sat, 16 Feb 2013 12:18:18 -0500
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net> <1360958672-5692-1-git-send-email-jlayton@redhat.com> <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com> <20130215172058.29941a54@tlielax.poochiereds.net> <20130216133927.GA28824@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 16, 2013, at 8:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Feb 15, 2013 at 05:20:58PM -0500, Jeff Layton wrote:
>> An excellent question, and not an easy one to answer. Clearly 1024
>> entries was not enough. We now cap the size as a function of the
>> available low memory, which I think is a reasonable way to keep it from
>> ballooning so large that the box falls over. We also have a shrinker
>> and periodic cache cleaner to prune off entries that have expired.
>> 
>> Of course one thing I haven't really considered enough is the
>> performance implications of walking the potentially much longer hash
>> chains here.
>> 
>> If that is a problem, then one way to counter that without moving to a
>> different structure altogether might be to alter the hash function
>> based on the max size of the cache. IOW, grow the number of hash buckets
>> as the max cache size grows?

The trouble with a hash table is that once you've allocated it, it's a heavy lift to increase the table size.  That sort of logic adds complexity and additional locking, and is often difficult to test.

> Another reason to organize the cache per client address?


In theory, an active single client could evict all entries for other clients, but do we know this happens in practice?

> With a per-client maximum number of entries, sizing the hash tables
> should be easier.


When a server has only one client, should that client be allowed to maximize the use of a server's resources (eg, use all of the DRC resource the server has available)?  How about when a server has one active client and multiple quiescent clients?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




