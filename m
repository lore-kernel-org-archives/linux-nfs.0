From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Tue, 22 May 2007 21:16:54 +1000
Message-ID: <20070522111653.GF1202@sgi.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<20070518040509.GC5104@sgi.com>
	<1179495234.23385.30.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqSMT-0001VY-Hi
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 04:17:10 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19XzCwZoqiZ+yHThg5s38vtTe707vTGGvs=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqSMV-00022W-6c
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 04:17:08 -0700
In-Reply-To: <1179495234.23385.30.camel@trinity.ogc.int>
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

On Fri, May 18, 2007 at 08:33:54AM -0500, Tom Tucker wrote:
> On Fri, 2007-05-18 at 14:05 +1000, Greg Banks wrote:
> > On Thu, May 17, 2007 at 08:30:39PM +1000, Neil Brown wrote:
> > >  Do that mean that RDMA will never
> > > reject a write due to lack of space? 
> > 
> > No, it means that the current RDMA send code will block waiting
> > for space to become available.  That's right, nfsd threads block on
> > the network.  Steel yourself, there's worse to come.
> > 
> 
> Uh... Not really. The queue depths are designed to match credits to
> worst case reply sizes. In the normal case, it should never have to
> wait. The wait is to catch the margins in the same way that a kmalloc
> will wait for memory to become available. 

This is news to me, but then I just read that code not write it ;-)
I just poked around in your GIT tree and AFAICT the software queue
depth limits are set by this logic:

    743 static int
    744 svc_rdma_accept(struct svc_rqst *rqstp)
    745 {
    ...
    775         ret = ib_query_device(newxprt->sc_cm_id->device, &devattr);
    ...
    788         newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
    789                                    (size_t)svcrdma_max_requests);
    790         newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;


     54 unsigned int svcrdma_max_requests = RPCRDMA_MAX_REQUESTS;
     
    143 #define RPCRDMA_SQ_DEPTH_MULT   8
    145 #define RPCRDMA_MAX_REQUESTS    16

A brief experiment shows that devattr.max_qp_wr = 16384 on recent
Mellanox cards, so the actual sc_sq_depth value will be ruled
by svcrdma_max_requests, and be 128.

The worst case is a 4K page machine writing a 1MB reply to a READ rpc,
which if I understand the code correctly uses a WR per page plus one
for the reply header, or 1024/4+1 = 257 WRs.  Now imagine all the nfsd
threads(*) trying to do that to the same QP.  SGI runs with 128 threads.

In this scenario, every call to svc_rdma_send() stands a good chance
of blocking.  The wait is not interruptible and has no timeout.  If
the client's HCA has a conniption under this load, the server will
have some large fraction of the nfsds unkillably blocked until the
server's HCA gives up and reports an error (I presume it does this?).

The wspace management code in knfsd is designed to avoid having
nfsds ever block in the network stack; I don't see how the NFS/RDMA
code achieves that.  Or is there something I've missed?

 * I would expect there to be a client-side limit on the number of
   outstanding READs so this doesn't normally happen, but part of the
   reason for knfsd's wspace management is to avoid DoS attacks from
   malicious or broken clients.

> There's actually a stat kept by the transport that counts the number of
> times it waits.

Ah, that would be rdma_stat_sq_starve?  It's been added since the
November code drop so I hadn't noticed it.  BTW is there a reason
for emitting statistics to userspace as sysctls?

> There is a place that a wait is done in the "normal" case and that's for
> the completion of an RDMA_READ in the process of gathering the data for
> and RPC on receive. That wait happens _every_ time.

Yes indeed, and this is the "worse" I was referring to.  I have
a crash dump in which 122 of the 128 nfsd threads are doing this:

 0 schedule+0x249c [0xa00000010052799c]
 1 schedule_timeout+0x1ac [0xa00000010052958c]
 2 rdma_read_xdr+0xf2c [0xa0000002216bcd8c]
 3 svc_rdma_recvfrom+0x1e5c [0xa0000002216bed7c]
 4 svc_recv+0xc8c [0xa00000022169f0ac]
 5 nfsd+0x1ec [0xa000000221d7504c]
 6 __svc_create_thread_tramp+0x30c [0xa0000002216976ac]
 7 kernel_thread_helper+0xcc [0xa00000010001290c]
 8 start_kernel_thread+0x1c [0xa0000001000094bc]
                                                                                                    
That doesn't leave a lot of threads to do real work, like waiting for
the filesystem.  And every now and again something goes awry in
IB land and each thread ends up waiting for 6 seconds or more.

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
