Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.ij.cx ([212.13.201.15]:55539 "EHLO wes.ijneb.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755192Ab0KPTFs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 14:05:48 -0500
Date: Tue, 16 Nov 2010 19:05:45 +0000 (GMT)
From: Mark Hills <mark@pogo.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: Listen backlog set to 64
In-Reply-To: <20101116182026.GA3971@fieldses.org>
Message-ID: <alpine.NEB.2.01.1011161854580.6298@jrf.vwaro.pbz>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz> <20101116182026.GA3971@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 16 Nov 2010, J. Bruce Fields wrote:

> On Mon, Nov 15, 2010 at 06:43:52PM +0000, Mark Hills wrote:
> > I am looking into an issue of hanging clients to a set of NFS servers, on 
> > a large HPC cluster.
> > 
> > My investigation took me to the RPC code, svc_create_socket().
> > 
> > 	if (protocol == IPPROTO_TCP) {
> > 		if ((error = kernel_listen(sock, 64)) < 0)
> > 			goto bummer;
> > 	}
> > 
> > A fixed backlog of 64 connections at the server seems like it could be too 
> > low on a cluster like this, particularly when the protocol opens and 
> > closes the TCP connection.
> > 
> > I wondered what is the rationale is behind this number, particuarly as it 
> > is a fixed value. Perhaps there is a reason why this has no effect on 
> > nfsd, or is this a FAQ for people on large systems?
> > 
> > The servers show overflow of a listening queue, which I imagine is 
> > related.
> > 
> >   $ netstat -s
> >   [...]
> >   TcpExt:
> >     6475 times the listen queue of a socket overflowed
> >     6475 SYNs to LISTEN sockets ignored
> > 
> > The affected servers are old, kernel 2.6.9. But this limit of 64 is 
> > consistent across that and the latest kernel source.
> 
> Looks like the last time that was touched was 8 years ago, by Neil (below, from
> historical git archive).
> 
> I'd be inclined to just keep doubling it until people don't complain,
> unless it's very expensive.  (How much memory (or whatever else) does a
> pending connection tie up?)

Perhaps SOMAXCONN could also be appropriate.
 
> The clients should be retrying, though, shouldn't they?

I think so, but a quick glance at net/sunrpc/clnt.c looks like the 
timeouts are fixed, not randomised. With nothing to smooth out the load 
from a large number of (identical) clients, potentially they could 
continue this process for some time.

I may be in the wrong client code here though for a client TCP connection, 
perhaps someone with more experience can comment. I hope to investigate 
further tomorrow.

-- 
Mark
