From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error
Date: Fri, 18 Dec 2009 10:37:23 -0500
Message-ID: <20091218103723.38510cce@tlielax.poochiereds.net>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
	<20091218093912.1c426ad6@tlielax.poochiereds.net>
	<1261147672.3229.14.camel@localhost>
	<1261149142.3229.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1261149142.3229.20.camel@localhost>
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

On Fri, 18 Dec 2009 10:12:22 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2009-12-18 at 09:47 -0500, Trond Myklebust wrote: 
> > On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > > Without a separate downcall error field, we'll need to special case at
> > > least 2 different errors -- one for a "real" EACCES and one that
> > > indicates that the ticket expired and the upcall should be retried
> > > instead.
> > 
> > We can find another error for the 'ticket expired' case. EKEYEXPIRED
> > springs to mind...
> 
> BTW: Here be dragons!
> 
> I think we need to handle the 'ticket expired' case as if it were an
> NFS4ERR_DELAY/EJUKEBOX, and actually do the retry in the NFS layer after
> a suitable exponential back-off period.
> 
> Otherwise, we end up holding onto resources (in particular NFSv4.1
> slots, but also RPC slots, ...) which will cause congestion, and prevent
> other RPC calls from making progress.
> 

Thanks. My original thought was that we should handle this situation as
we do when gssd is down -- just retry at the RPC layer. I hadn't
considered the resource issue however. I'll shoot for making the retry
happen at the NFS layer instead. That should also make it easier to
handle this situation differently on hard vs. soft mounts too.

-- 
Jeff Layton <jlayton@redhat.com>
