Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 09 Jun 2008 11:51:51 -0400
To: Jeff Layton <jlayton@redhat.com>
From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --
	how best to	close the sockets?
In-Reply-To: <20080609111821.6e06d4f8@tleilax.poochiereds.net>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
Message-ID: <RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
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

At 11:18 AM 6/9/2008, Jeff Layton wrote:
>No, it's not specific to NFS. It can happen to any "service" that
>floats IP addresses between machines, but does not close the sockets
>that are connected to those addresses. Most services that fail over
>(at least in RH's cluster server) shut down the daemons on failover
>too, so tends to mitigate this problem elsewhere.

Why exactly don't you choose to restart the nfsd's (and lockd's) on the
victim server? Failing that, for TCP at least would ifdown/ifup accomplish
the socket reset?

Tom.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
