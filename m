Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:63581 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751508AbbJTSeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 14:34:17 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v2] nfsd: don't revoke delegations that a client has stated it doesn't have
References: <1445350911-63530-1-git-send-email-aweits@rit.edu>
	<20151020172949.GA21687@fieldses.org>
Date: Tue, 20 Oct 2015 14:34:15 -0400
In-Reply-To: <20151020172949.GA21687@fieldses.org> (J. Bruce Fields's message
	of "Tue, 20 Oct 2015 13:29:49 -0400")
Message-ID: <m2twplxuc8.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Are clients really allowed to just lose a delegation?  (Have you seen
> such a case, other than the duplicate-delegation case which you already
> fixed?)

In short, yes, we're still seeing it. We have also been seeing increasing
stability from the work that has been done (which also increases the
time between replication).

The reason for v2 was I got coverage on the destruction path in
testing and discovered my mistake in v1. This one is extremely
frustrating to chase down (I've been 14+ hours deep in
packet captures to try and find the allocation to the recall - I
keep running out of disk space).

The operational reason to avoid this is because a lost delegation
effectively kills the mount when the state managers are looping. I have
a patch that alters fault injection to recreate the scenario.

>> 1.) Any race between a delegation grant and a recall has been
>>     presumably avoided by the delay and second attempt.
>
> If something happened to the forechannel connection, then I believe it
> could take longer than 2 seconds to time out and recover.

Hrm, yes I see.

> So I'm inclined to instead fix any bugs that result in servers and
> client disagreeing about whether there's a delegation.

Not abandoning trying to track it down. It's quite clearly going to take
a while.

> Another thing we could do here is finally implement the server-side
> support for referring triples (I think the client's done?):
>
> 	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Referring_triples
> 	https://tools.ietf.org/html/rfc5661#section-2.10.6.3
>
> That would eliminate the need for the recall retries.
>
> Though that would still leave open the question of how to handle those
> errors on a recall.  We still not be able to conclude that it's safe for
> the server to destroy the delegation.

Would this be more appropriately "fixed" by supporting DELEGPURGE in a
limited fashion to clear out cl_revoked? (I'm not quite sure
that's a valid interpretation of RFC5561) to clear out any "lost"
delegations?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
