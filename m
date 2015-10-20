Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbbJTVKU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2015 17:10:20 -0400
Date: Tue, 20 Oct 2015 17:10:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v2] nfsd: don't revoke delegations that a client has
 stated it doesn't have
Message-ID: <20151020211017.GA22828@fieldses.org>
References: <1445350911-63530-1-git-send-email-aweits@rit.edu>
 <20151020172949.GA21687@fieldses.org>
 <m2twplxuc8.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2twplxuc8.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 20, 2015 at 02:34:15PM -0400, Andrew W Elble wrote:
> 
> > Are clients really allowed to just lose a delegation?  (Have you seen
> > such a case, other than the duplicate-delegation case which you already
> > fixed?)
> 
> In short, yes, we're still seeing it. We have also been seeing increasing
> stability from the work that has been done (which also increases the
> time between replication).
> 
> The reason for v2 was I got coverage on the destruction path in
> testing and discovered my mistake in v1. This one is extremely
> frustrating to chase down (I've been 14+ hours deep in
> packet captures to try and find the allocation to the recall - I
> keep running out of disk space).

Ugh.  Maybe patching in some well-chosen printk's could help.

Or doing some filtering as you capture.   You could capture just
operations that might have a delegation stateid--OPEN, DELEGRETURN,
CB_RECALL.  And probably SEQUENCE replies with any flags set.

> > Another thing we could do here is finally implement the server-side
> > support for referring triples (I think the client's done?):
> >
> > 	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Referring_triples
> > 	https://tools.ietf.org/html/rfc5661#section-2.10.6.3
> >
> > That would eliminate the need for the recall retries.
> >
> > Though that would still leave open the question of how to handle those
> > errors on a recall.  We still not be able to conclude that it's safe for
> > the server to destroy the delegation.
> 
> Would this be more appropriately "fixed" by supporting DELEGPURGE in a
> limited fashion to clear out cl_revoked? (I'm not quite sure
> that's a valid interpretation of RFC5561) to clear out any "lost"
> delegations?

I haven't thought it through, but that's clearly not what's intended
for, so I'm pessimistic.  Note also we'd need to implement it first.

There may be other ways the client could better recover, but we'd still
rather avoid such situations in the first place.  The recovery logic is
already complicated enough, it would be worse if it also needed to
handle a lot of cases that could only occur due to outright bugs.

--b.
