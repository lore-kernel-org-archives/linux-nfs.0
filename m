From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error
Date: Fri, 18 Dec 2009 13:30:27 -0500
Message-ID: <1261161027.3420.6.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	 <1261145468.3229.7.camel@localhost>
	 <20091218093912.1c426ad6@tlielax.poochiereds.net>
	 <1261147672.3229.14.camel@localhost> <1261149142.3229.20.camel@localhost>
	 <20091218103723.38510cce@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47275 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932187AbZLRSac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2009 13:30:32 -0500
In-Reply-To: <20091218103723.38510cce-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 10:37 -0500, Jeff Layton wrote: 
> On Fri, 18 Dec 2009 10:12:22 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Fri, 2009-12-18 at 09:47 -0500, Trond Myklebust wrote: 
> > > On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > > > Without a separate downcall error field, we'll need to special case at
> > > > least 2 different errors -- one for a "real" EACCES and one that
> > > > indicates that the ticket expired and the upcall should be retried
> > > > instead.
> > > 
> > > We can find another error for the 'ticket expired' case. EKEYEXPIRED
> > > springs to mind...
> > 
> > BTW: Here be dragons!
> > 
> > I think we need to handle the 'ticket expired' case as if it were an
> > NFS4ERR_DELAY/EJUKEBOX, and actually do the retry in the NFS layer after
> > a suitable exponential back-off period.
> > 
> > Otherwise, we end up holding onto resources (in particular NFSv4.1
> > slots, but also RPC slots, ...) which will cause congestion, and prevent
> > other RPC calls from making progress.
> > 
> 
> Thanks. My original thought was that we should handle this situation as
> we do when gssd is down -- just retry at the RPC layer. I hadn't
> considered the resource issue however. I'll shoot for making the retry
> happen at the NFS layer instead. That should also make it easier to
> handle this situation differently on hard vs. soft mounts too.
> 

It will also make it easier to do things like preventing flushd from
hanging forever on a set of writebacks that cannot make progress.

At some point we might also want to allow the administrator to set a
limit on the number of write retries, so that a user who decides to go
on a 1 year sabbatical doesn't end up holding up access to a file
forever...

Cheers
  Trond

