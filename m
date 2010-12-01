Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57469 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab0LAC5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 21:57:50 -0500
Date: Wed, 1 Dec 2010 13:57:40 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Steve Dickson <SteveD@redhat.com>, Spelic <spelic@shiftmail.org>,
        linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101201135740.0d3b5948@notabene.brown>
In-Reply-To: <20101130223627.GC5054@fieldses.org>
References: <4CF3ED05.3070401@shiftmail.org>
	<1291054975.12784.17.camel@heimdal.trondhjem.org>
	<4CF3F326.4060608@shiftmail.org>
	<20101129190122.GA31843@fieldses.org>
	<1291057747.12784.38.camel@heimdal.trondhjem.org>
	<4CF519F2.8080900@RedHat.com>
	<1291155578.2998.38.camel@heimdal.trondhjem.org>
	<20101130222651.GB5054@fieldses.org>
	<1291156414.4393.2.camel@heimdal.trondhjem.org>
	<20101130223627.GC5054@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 30 Nov 2010 17:36:27 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Nov 30, 2010 at 05:33:34PM -0500, Trond Myklebust wrote:
> > On Tue, 2010-11-30 at 17:26 -0500, J. Bruce Fields wrote:
> > > On Tue, Nov 30, 2010 at 05:19:38PM -0500, Trond Myklebust wrote:
....
> > > > Some reasons for doing this in the kernel are:
> > > > 
> > > > 1) it is easy to do so.
> > > > 2) it allows the kernel to take action to recover
> > > > 3) it fixes the nfsroot problem, provided that the server also sends
> > > > uids/gids in this situation.
> > > 
> > > Makes sense to me.
> > > 
> > > The server side might still be easiest to do in idmapd/libnfsidmap.
> > 
> > The NFS server has to be able to tell the idmapper which variety of
> > mapping it wants. The reason is, as I said, that we want to handle
> > RPCSEC_GSS based authentication (and possibly AUTH_NULL too) differently
> > from AUTH_SYS. The idmapper by itself has no way to distinguish what
> > authentication the client used.
> 
> I still don't understand what the advantage of that would be: why would
> we want to return different file owners depending on which
> authentication flavor the client's request used?
> 

I have a strong memory from about 7 years ago of Brian Pawlowski saying - or
possibly being quoted as saying - that the user information in NFS requests
(the stuff that idmapper handles) is totally independent of the RPC
authentication mechanism being used (the AUTH_SYS / RPCSEC_GSS stuff).

I always thought that was nonsense, but I wasn't in a position to discuss it
at the time for reasons that I really don't recall.

If users are being authorised using numbers (AUTH_SYS) then it only (to me)
makes sense to communication all identies as numbers.
And if users are being authenticated as name@domain strings, then it only
make sense to communicate all identities as name@domain.

But this path is not the path for NFSv4 followed.

I've very glad to see Linux NFS allowing numeric IDs "on the wire" and hope
to see this very sensible approach widely adopted (where AUTH_SYS is used).
I think it would be great if nfsd did the same thing completely in-kernel
without reference to idmapd.  Accepting either numeric or domain-based is
trivial.  Choosing which to send on a per-client basis might be a challenge,
but probably not a big one.


I wonder if Brian remembers saying anything like that...

NeilBrown


> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

