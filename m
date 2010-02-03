Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54950 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756539Ab0BCWef (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 17:34:35 -0500
Date: Wed, 3 Feb 2010 17:34:43 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] sunrpc: close connection when a request is
	irretrievably lost.
Message-ID: <20100203223443.GG13336@fieldses.org>
References: <20100203060657.12945.27293.stgit@notabene.brown> <20100203063131.12945.34978.stgit@notabene.brown> <4B699988.9000209@oracle.com> <20100204082354.0bf3b7e5@notabene.brown> <1265235610.5217.21.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1265235610.5217.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 03, 2010 at 05:20:10PM -0500, Trond Myklebust wrote:
> On Thu, 2010-02-04 at 08:23 +1100, Neil Brown wrote: 
> > On Wed, 03 Feb 2010 10:43:04 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > 
> > > I don't think dropping the connection will cause the client to 
> > > retransmit sooner.  Clients I have encountered will reconnect and 
> > > retransmit only after their retransmit timeout fires, never sooner.
> > > 
> > 
> > I thought I had noticed the Linux client resending immediately, but it would
> > have been a while ago, and I could easily be remembering wrongly.
> 
> It depends on who closes the connection.
> 
> The client assumes that if the _server_ closes the connection, then it
> may be having resource congestion issues. In order to give the server
> time to recover, the client will delay reconnecting for 3 seconds (with
> an exponential back off).
> 
> If, on the other hand, the client was the one that initiated the
> connection closure, then it will try to reconnect immediately.

So, if I understand Neil's patches right:

	- First we try waiting at least one second for the upcall.
	- Then we try to return JUKEBOX/DELAY.  (But if we're still
	  processing the rpc header we may not have the option.)
	- Then we give up and drop the request.

Upcalls shouldn't normally take a second; so something's broken or
congested, whether it's us or our kerberos server.  So telling the
client we're congested sounds right, as does the client response Trond
describes.

--b.
