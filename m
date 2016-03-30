Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45468 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbcC3Rkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2016 13:40:42 -0400
Date: Wed, 30 Mar 2016 13:40:40 -0400
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: out of order v3 write replies and cache invalidation
Message-ID: <20160330174040.GA12525@fieldses.org>
References: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 29, 2016 at 03:57:53PM -0400, Olga Kornievskaia wrote:
> Is it always the case that cache invalidation is unavoidable when
> client receives out of order replies back from the server? I believe
> it is because the change attribute mismatch is unavoidable but I'd
> like to check if my understanding is correct.
> 
> Here's what I mean:
> 1 write call 0-1024
> 2 write call 1024-2048
> 3 write call 2048-4096
> 4 write reply to 1
> 5 write reply to 3
> 6 write reply to 2
> 
> When #5 is received in the "before" attributes it doesn't have the
> "after" attributes of reply #4 and that leads to cache invalidation
> (this is what I'm seeing in the current code).

In theory, couldn't the client in theory handle these situations by
remembering some (before, after) pairs?  Then in the above case:

  assume file starts with change attribute A
> 1 write call 0-1024
  new change attribute after first write is B
> 2 write call 1024-2048
  new change attribute after second write is C
> 3 write call 2048-4096
  new change attribute after third write is D
> 4 write reply to 1
	returns (before, after) == (A, B): mark our cache as
	representing the state of the file at change attribute B.
> 5 write reply to 3
	returns (before, after) == (C, D): our cache is now untrusted,
	but would be trusted again if we saw (B, C).
> 6 write reply to 2
	returns (before, after) == (B, C): now we've seen both (B, C),
	and (C, D), so we can mark our cache as representing the state
	of the file at change attribute D.

In general, at a given point:

	- remember the last change attribute about which we had complete
	  information.
	- remember a list of change attribute intervals which we've seen
	  in replies.  Consolidate any pairs with common endpoints
	  (e.g., [(B,C),(C,D)] can be replaced by [(B,D)]).
	- if the result is a pair that matches the last known-good
	  change attribute, then delete that pair and just record the
	  right endpoint as the new known-good change attribute.

In practice to make it manageable don't record more than a few such
intervals, give up and invalidate cache if that isn't enough.  Maybe
even just one interval would be enough to catch most cases.

I don't know if that's worth it.

Also, it all depends on the assumption that the change attributes are
read atomically with respect with the write, which isn't really true.
But it sounds like we're already making that assumption.

If we assume no other writers until we close, couldn't you on close wait
for all writes, send a final getattr for change attribute, and trust
that?  If the extra getattr's too much, then you'd need some algorithm
like the above to determine which change attribute is the last.  Or
implement
https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-12.2.3
on client and server and just track the maximum returned value when the
server returns something other than NFS4_CHANGE_TYPE_IS_UNDEFINED.

--b.

> 
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
