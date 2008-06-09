From: Neil Horman <nhorman@redhat.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how best
	to	close the sockets?
Date: Mon, 9 Jun 2008 12:03:39 -0400
Message-ID: <20080609160339.GC20181@hmsendeavour.rdu.redhat.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609120110.1fee7221@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
	nhorman@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080609120110.1fee7221@tleilax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 09, 2008 at 12:01:10PM -0400, Jeff Layton wrote:
> On Mon, 09 Jun 2008 11:51:51 -0400
> "Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
> 
> > At 11:18 AM 6/9/2008, Jeff Layton wrote:
> > >No, it's not specific to NFS. It can happen to any "service" that
> > >floats IP addresses between machines, but does not close the sockets
> > >that are connected to those addresses. Most services that fail over
> > >(at least in RH's cluster server) shut down the daemons on failover
> > >too, so tends to mitigate this problem elsewhere.
> > 
> > Why exactly don't you choose to restart the nfsd's (and lockd's) on the
> > victim server?
> 
> The victim server might have other nfsd/lockd's running on them. Stopping
> all the nfsd's could bring down lockd, and then you have to deal with lock
> recovery on the stuff that isn't moving to the other server.
> 
> > Failing that, for TCP at least would ifdown/ifup accomplish
> > the socket reset?
> > 
> 
> I don't think ifdown/ifup closes the sockets, but maybe someone can
> correct me on this...
> 
if up/down doesn't do anything to the sockets per-se, but could have any number
of side effects depending how other aspects of your network/application are
configured.  Certainly not a reliable way to destroy a connection.
Neil

> -- 
> Jeff Layton <jlayton@redhat.com>

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
