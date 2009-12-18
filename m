From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error
Date: Fri, 18 Dec 2009 14:42:29 -0500
Message-ID: <1261165349.3420.26.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
	<20091218093912.1c426ad6@tlielax.poochiereds.net>
	<1261147672.3229.14.camel@localhost>
	<1261149142.3229.20.camel@localhost>
	<20091218103723.38510cce@tlielax.poochiereds.net>
	<1261161027.3420.6.camel@localhost>
	<20091218141408.03bfa07a@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091218141408.03bfa07a@tlielax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 14:14 -0500, Jeff Layton wrote: 
> On Fri, 18 Dec 2009 13:30:27 -0500
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Fri, 2009-12-18 at 10:37 -0500, Jeff Layton wrote: 
> > > On Fri, 18 Dec 2009 10:12:22 -0500
> > > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > > 
> > > > On Fri, 2009-12-18 at 09:47 -0500, Trond Myklebust wrote: 
> > > > > On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > > > > > Without a separate downcall error field, we'll need to special case at
> > > > > > least 2 different errors -- one for a "real" EACCES and one that
> > > > > > indicates that the ticket expired and the upcall should be retried
> > > > > > instead.
> > > > > 
> > > > > We can find another error for the 'ticket expired' case. EKEYEXPIRED
> > > > > springs to mind...
> > > > 
> > > > BTW: Here be dragons!
> > > > 
> > > > I think we need to handle the 'ticket expired' case as if it were an
> > > > NFS4ERR_DELAY/EJUKEBOX, and actually do the retry in the NFS layer after
> > > > a suitable exponential back-off period.
> > > > 
> > > > Otherwise, we end up holding onto resources (in particular NFSv4.1
> > > > slots, but also RPC slots, ...) which will cause congestion, and prevent
> > > > other RPC calls from making progress.
> > > > 
> > > 
> > > Thanks. My original thought was that we should handle this situation as
> > > we do when gssd is down -- just retry at the RPC layer. I hadn't
> > > considered the resource issue however. I'll shoot for making the retry
> > > happen at the NFS layer instead. That should also make it easier to
> > > handle this situation differently on hard vs. soft mounts too.
> > > 
> > 
> > It will also make it easier to do things like preventing flushd from
> > hanging forever on a set of writebacks that cannot make progress.
> > 
> > At some point we might also want to allow the administrator to set a
> > limit on the number of write retries, so that a user who decides to go
> > on a 1 year sabbatical doesn't end up holding up access to a file
> > forever...
> > 
> 
> Possibly. To make the calls start erroring out with the design I'm
> working on, all you'd need to do is destroy their credcache. That's a
> manual process though and it might be better to be able to handle this
> situation more automatically. I'll need to ponder it some...
> 
> I'd like to avoid too much scope creep here. My feeling here is that we
> should start simply and just make this situation behave like
> NFS4ERR_DELAY/EJUKEBOX for the first pass. If that turns up problems,
> then we can modify that behavior.
> 
> Sound ok?

Sure. I fully agree that the first pass should be to do the
NFS4ERR_DELAY/EJUKEBOX behaviour. I'm just saying that this may be
something that we want to do in the future, and so it is worth
considering what consequences that will have for the very basic
design...

Trond
