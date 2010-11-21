Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:47087 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab0KUGnB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 01:43:01 -0500
Date: Sat, 20 Nov 2010 22:43:01 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101121064301.GB3285@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org> <20101119202004.GA3270@hostway.ca> <1290201888.3135.61.camel@heimdal.trondhjem.org> <20101119220356.GB3270@hostway.ca> <1290205039.3135.74.camel@heimdal.trondhjem.org> <20101119225803.GC3270@hostway.ca> <1290208645.3135.88.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290208645.3135.88.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 06:17:25PM -0500, Trond Myklebust wrote:

> On Fri, 2010-11-19 at 14:58 -0800, Simon Kirby wrote:
> > On Fri, Nov 19, 2010 at 05:17:19PM -0500, Trond Myklebust wrote:
> > > So what were all the 
> > > 
> > > 'lockd: server 10.10.52.xxx not responding, still trying'
> > > 
> > > messages all about? There were quite a few of them for a number of
> > > different servers in the moments leading up to the hang. Could it be a
> > > problem with the switch these clients are attached to?
> > 
> > If it were a switch problem, would we see port 2049 socket backlogs with
> > netstat -tan or ss -tan?  I haven't seen this at all when the problem
> > occurs.  All of the sockets are idle (and usually it seems to close them
> > all except the one server that all of the slots are stuck on).  tcpdump
> > shows no problems, just very slow requests rates that match the rpc/nfs
> > debugging.
> 
> No retransmits that might indicate dropped packets at the switch? How
> fast are the tcp ACKs from the server being returned?

That tcpdump I sent included the ACKs, which all looked normal.
Unfortunately, we haven't seen the problem again yet.  Is your "Fix an
infinite loop in call_refresh/call_refreshresult" patch possibly related?

> > If the rpc slots are stuck full, would that cause lockd to print those
> > timeouts?
> 
> Yes. That would be the only kind of event that would trigger these
> messages.

and in this case, rpcinto -t and -u should look normal, I would assume,
unless there is a switch/network issue?

Still waiting for it to occur again to try those commands.

Simon-
