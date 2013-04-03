Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44308 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762599Ab3DCRMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 13:12:15 -0400
Date: Wed, 3 Apr 2013 13:12:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>, Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130403171213.GB3344@fieldses.org>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
 <20130402183907.GB18900@umich.edu>
 <1364928519.2660.1279.camel@willson.li.ssimo.org>
 <20130403134407.GB13951@fieldses.org>
 <20130403144055.GA7049@umich.edu>
 <1365005018.2660.1315.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365005018.2660.1315.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 03, 2013 at 12:03:38PM -0400, Simo Sorce wrote:
> On Wed, 2013-04-03 at 10:40 -0400, Jim Rees wrote:
> > J. Bruce Fields wrote:
> > 
> >   Like Jim I don't understand how that fits the definition of a "man in
> >   the middle" attack.
> > 
> > If Bruce is having trouble too, I think the explanation needs to be
> > improved. But I think the latest patch set drops the talk about a
> > vulnerability, and I'm fine with that.
> 
> Yeah I figured that just concentrating on the functional aspect of being
> able to work on networks with missing PTR records is sufficient to
> explain why this patchset is good :-)

Definitely, you're fine.  I was just nitpicking language, the problem's
clear enough:

> However let me give a try at explaining in a different way using the
> same example I gave before but from a different angle.
> 
> - Assume user Alice has very important documents that are backed up
> daily to a server named secure.server.name where Alice can write to and
> nobody can read from.
> - Assume an attacker Eve, that is in the condition of intercepting and
> modifying all network traffic from Alice.
> - Assume there exist another server called public.server.name where
> Alice can write to and Eve can read from.
> 
> Eve wants to fool Alice in mounting /export from public.server.name
> instead or secure.server.name so she can copy Alice's documents away.
> 
> 
> So Eve, manipulates traffic and when Alice's machine tries to talk to
> secure.server.name, Eve redirects all the traffic to public.server.name
> instead. (Can be done by a simple DNS poisoning attack that gives back
> to Alice computer the public.server.name IP address, or by actual DNAT
> on Alice's computer packets).
> Now, normally, if Krb5 authentication is used the mount would fail,
> because Alice would try to authenticate to public.server.com using a
> ticket she obtained to talk to secure.server.com (remember that Alice
> thinks she is mounting the secure.server.name share).
> 
> Here the reverse DNS resolution performed by Alice's computer's rpc.gssd
> daemon is what allows Eve to successfully redirect Alice's mount
> instead. Because at the time Alice's computer needs to grab a ticket for
> the 'target' server, Eve fakes the DNS replies and tells Alice's
> computer that the destination name for the secure.server.name's IP
> address is 'public.server.name'.
> 
> So with current behavior Alice's computer asks the KDC for a ticket for
> 'public.server.name' instead of 'secure.server.name'.
> 
> Now Krb5 authentication does not fail anymore because Alice does have
> the 'right' ticket for the server it is connecting to.
> 
> Alice authentication against the 'substituted' (by Eve, through packet
> redirection) server therefore succeeds, and her computer is fooled to
> think it really mounted secure.server.name when it really has mounted
> public.server.name, the cron job for the backup starts and copies all
> files to public.server.name, where Eve can find and access them.

Argh, sorry Simo, I didn't mean to make you write all that out.

> Call it MITM, call it something else,

This was literally my only complaint.  The above doesn't sound to me
like what I'd normally call a "man in the middle" attack.

--b.
