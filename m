From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Wed, 23 May 2007 12:32:06 +1000
Message-ID: <20070523023206.GA14076@sgi.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<20070518040509.GC5104@sgi.com>
	<1179495234.23385.30.camel@trinity.ogc.int>
	<20070522111653.GF1202@sgi.com>
	<1179855263.9389.118.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqgeB-00033u-4t
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 19:32:19 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HqgeD-0008L9-Pw
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 19:32:22 -0700
In-Reply-To: <1179855263.9389.118.camel@trinity.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, May 22, 2007 at 12:34:23PM -0500, Tom Tucker wrote:
> On Tue, 2007-05-22 at 21:16 +1000, Greg Banks wrote:
> >
> > The wspace management code in knfsd is designed to avoid having
> > nfsds ever block in the network stack; I don't see how the NFS/RDMA
> > code achieves that.  Or is there something I've missed?
> > 
> 
> You're dead on. We should implement wspace properly. I'll look into
> fixing this. 

Great.

> The bulk of the stats were exported in order to evaluate different I/O
> models. For example, do we poll some number of times on an SQ stall? How
> about an RQ stall, etc... I think many of these stats should be removed.
> I'd appreciate feedback on which ones we should retain.

Actually I quite like the stats, although the reap_[sr]q_at_* counters
don't seem to be used.  For rdma_stat_rq_prod, I would have had a
counter increment where wc.status reports an error, thus futzing with
the global cacheline only once in the normal success path.

But I think it would be better to report them through the existing
/proc/net/rpc/nfsd mechanism, i.e. add an RDMA-specific call to
svc_seq_show() and add your new counters to struct svc_stat.


> What's happening here is that you're pounding the server with NFS WRITE
> and recvfrom is dutifully queuing another thread to process the next RPC
> in the RQ, which happens to require another RDMA READ and another wait
> and so on. As you point out, this is not productive and quickly consumes
> all your threads -- Ugh. 

Exactly.

> A simple optimization to the current design for this case is that if the
> RPC contains a read-list don't call svc_sock_enqueue until _after_ the
> RDMA READ completes.

I assume you meant "don't release the SK_BUSY bit", because
svc_sock_enqueue will be called from the dto tasklet every time
a new call arrives whether or not we've finished the RDMA READ.

> The current thread will wait, but the remaining
> threads (127 in your case) will be free to do other work for other mount
> points. 
> 
> This only falls over in the limit of 128 mounts all pounding the server
> with writes. Comments?

A common deployment scenario I would expect to see would have at
least twice as many clients as threads, and SGI have successfully
tested scenarios with a 16:1 client:thread ratio.  So I don't think
we can solve the problem in any way which ties down a thread for
up to 6 seconds per client, because there won't be enough threads
to go around.

The other case that needs to work is a single fat client trying to
throw as many bits as possible down the wire.  For this case your
proposal would limit the server to effectively serving WRITE RPCs
serially, with what I presume would be a catastrophic effect on
write performance.  What you want is for knfsd to be able to throw
as many threads at the single fat client as possible.

The knfsd design actually handles both these extreme cases quite
well today with TCP sockets.  The features which I think are key
to providing this flexibility are:

 * a pool of threads whose size is only loosely tied to the number
   of clients

 * threads are not tied to clients, they compete for individual
   incoming RPCs

 * threads take care to avoid blocking on the network

The problem we have achieving the last point for NFS/RDMA is that
RDMA READs are fundamentally neither a per-svc_sock nor a per-thread
concept.  To achieve parallelism you want multiple sequences of RDMA
READs proceeding per svc_sock.  To avoid blocking threads you want a
thread to be able to abandon a sequence of RDMA READs partway through
and go back to it's main loop.  Doing both implies a new object to hold
the state for a single sequence of RDMA READs for a single WRITE RPC.

So I think the "right" way to handle RDMA READs is to define a
new struct, for argument's sake "struct svc_rdma_read", containing
some large fraction of the auto variables currently in the function
rdma_read_xdr() and some from it's caller.  When an RPC with a read
list arrives, allocate a struct svc_rdma_read and add it to a list
of such structs on the corresponding struct svcxprt_rdma.  Issue some
READ WRs, until doing so would block.  When the completions for issued
WRs arrive, mark the struct svc_rdma_read, instead of waking the
nfsd as you do now, set SK_DATA on the svcxprt_rdma and enqueue it.
When an nfsd later calls svc_rdma_recvfrom(), first check whether any
of the struct svc_rdma_reads in flight have progressed, and depending
on whether they're complete either issue some more READ WRs or finalise
the struct svc_rdma_read by setting up the thread's page array.

In other words, invert the rdma_read_xdr() logic so nfsd return
to the main loop instead of blocking.

Unfortunately it's kind of a major change.  Thoughts?

> > And every now and again something goes awry in
> > IB land and each thread ends up waiting for 6 seconds or more.
> 
> Yes. Note that when this happens, the connection gets terminated.

Indeed.  Meanwhile, for the last 6 seconds all the nfsds are
blocked waiting for the one client, and none of the other clients
are getting any service.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
