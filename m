Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 12:01:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --  how
	best to	close the sockets?
Message-ID: <20080609120110.1fee7221@tleilax.poochiereds.net>
In-Reply-To: <RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        nhorman@redhat.com
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 09 Jun 2008 11:51:51 -0400
"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:

> At 11:18 AM 6/9/2008, Jeff Layton wrote:
> >No, it's not specific to NFS. It can happen to any "service" that
> >floats IP addresses between machines, but does not close the sockets
> >that are connected to those addresses. Most services that fail over
> >(at least in RH's cluster server) shut down the daemons on failover
> >too, so tends to mitigate this problem elsewhere.
> 
> Why exactly don't you choose to restart the nfsd's (and lockd's) on the
> victim server?

The victim server might have other nfsd/lockd's running on them. Stopping
all the nfsd's could bring down lockd, and then you have to deal with lock
recovery on the stuff that isn't moving to the other server.

> Failing that, for TCP at least would ifdown/ifup accomplish
> the socket reset?
> 

I don't think ifdown/ifup closes the sockets, but maybe someone can
correct me on this...

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
