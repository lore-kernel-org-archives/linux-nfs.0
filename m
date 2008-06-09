From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
Date: Mon, 9 Jun 2008 13:14:41 -0400
Message-ID: <20080609171441.GA26920@fieldses.org>
References: <20080609103137.2474aabd@tleilax.poochiereds.net> <484D4659.9000105@redhat.com> <20080609111821.6e06d4f8@tleilax.poochiereds.net> <RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com> <20080609120110.1fee7221@tleilax.poochiereds.net> <RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	Peter Staubach <staubach@redhat.com>,
	linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
	nhorman@redhat.com
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57864 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbYFIROq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 13:14:46 -0400
In-Reply-To: <RTPCLUEXC1-PRDF8Eqf000001d4-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 09, 2008 at 12:09:48PM -0400, Talpey, Thomas wrote:
> At 12:01 PM 6/9/2008, Jeff Layton wrote:
> >On Mon, 09 Jun 2008 11:51:51 -0400
> >"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
> >
> >> At 11:18 AM 6/9/2008, Jeff Layton wrote:
> >> >No, it's not specific to NFS. It can happen to any "service" that
> >> >floats IP addresses between machines, but does not close the sockets
> >> >that are connected to those addresses. Most services that fail over
> >> >(at least in RH's cluster server) shut down the daemons on failover
> >> >too, so tends to mitigate this problem elsewhere.
> >> 
> >> Why exactly don't you choose to restart the nfsd's (and lockd's) on the
> >> victim server?
> >
> >The victim server might have other nfsd/lockd's running on them. Stopping
> >all the nfsd's could bring down lockd, and then you have to deal with lock
> >recovery on the stuff that isn't moving to the other server.
> 
> But but but... the IP address is the only identification the client can use
> to isolate a server.

Right.

> You're telling me that some locks will migrate and some won't?  Good
> luck with that! The clients are going to be mightily confused.

Locks migrate or not depending on the server ip address.  Where do you
see the confusion?

--b.
