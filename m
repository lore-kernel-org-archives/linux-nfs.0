From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
 (RFC)
Date: Tue, 25 Nov 2008 10:12:58 -0500
Message-ID: <20081125101258.48751871@tleilax.poochiereds.net>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
	<20081122011555.GA28485@fieldses.org>
	<20081124103313.0c779324@tleilax.poochiereds.net>
	<20081124170653.GF17862@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59199 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbYKYPOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2008 10:14:09 -0500
In-Reply-To: <20081124170653.GF17862@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 24 Nov 2008 12:06:53 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> 
> I still haven't looked at the code yet.  Probably the first thing I'd
> check would whether the previous code depends on an assumption that each
> grant request results in revisit of exactly one rpc.  I can't see a
> problem.
> 

That's the case with the existing code, since it stops looking for
blocks once it finds a match. The patch I sent changes
nlmsvc_grant_deferred to walk the entire list and set up matching
blocks to be granted.

I think at that point, lockd will rewalk the list (via
nlmsvc_retry_blocked) and revisit each one that got moved to the head
of the list. Please correct me if I'm wrong here though. This code has
a lot of indirection and I'm not sure I fully understand the way
revisits work.

As a side note, one thing that might be nice for this is to have
nlmsvc_grant_deferred to only walk the list of blocks that is
associated with this file. nlm_blocked is an ordered list though, so
I'm not sure whether this might have an effect on "fairness" when
several hosts or processes are contending for the same range.

-- 
Jeff Layton <jlayton@redhat.com>
