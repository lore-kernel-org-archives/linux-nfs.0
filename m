From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] xprtrdma: fix XDR tail buf marshalling for all
	ops
Date: Mon, 10 Dec 2007 11:23:55 -0500
Message-ID: <1197303835.10573.3.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
	 <1196969392.7990.9.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
	 <EXNANE01G5aYY61LEdy00000ae1@exnane01.hq.netapp.com>
	 <1197300897.21931.9.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:48326 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbXLJQYD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 11:24:03 -0500
In-Reply-To: <1197300897.21931.9.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-10 at 09:34 -0600, Tom Tucker wrote:
> On Fri, 2007-12-07 at 12:02 -0500, Talpey, Thomas wrote:
> > At 06:11 PM 12/6/2007, James Lentini wrote:
> > >On Thu, 6 Dec 2007, Trond Myklebust wrote:
> > >> Eeewwww.... What an unholy mess!
> > >> 
> > >> Why are you trying to shoehorn reading and writing into 
> > >> rpcrdma_create_chunks()? The way every action is split into 'if 
> > >> (read) {} else {}' should be an obvious hint that none of this 
> > >> belongs together. Please split this up for 2.6.25.
> > >
> > >ok.
> > 
> > Agreed - well except for the "unholy mess" part. This code has been
> > in the nfs/rdma client basically since it was written (for 2.4.18). The
> > split version introduces quite a bit of redundancy, but clarity is good
> > too. I'll split it willingly.
> > 
> 
> Hmm. I guess I disagree. I don't see how consolidating similar logic is
> an unholy mess. The purpose of the function is singular, i.e. preparing
> the chunk list contained in the request sent to the server. Although it
> is true that the chunklist encodes memory in the response (for read
> requests), the chunk list itself is a single entity. Splitting it up may
> be more confusing than combining and will certainly introduce copied
> logic.

Look at the damned thing. _Every_ chunk in it has an 'if (read)' else.
It that is 'similar logic' then I'm a duck.

Trond

