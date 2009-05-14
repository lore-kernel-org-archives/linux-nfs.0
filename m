From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Thu, 14 May 2009 10:33:40 -0400
Message-ID: <1242311620.6560.14.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	 <1242258338.5407.244.camel@heimdal.trondhjem.org>
	 <x49octv7qr8.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47940 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920AbZENOdq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 May 2009 10:33:46 -0400
In-Reply-To: <x49octv7qr8.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-14 at 09:34 -0400, Jeff Moyer wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
> >> Hi, netdev folks.  The summary here is:
> >> 
> >> A patch added in the 2.6.30 development cycle caused a performance
> >> regression in my NFS iozone testing.  The patch in question is the
> >> following:
> >> 
> >> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> >> Author: Olga Kornievskaia <aglo@citi.umich.edu>
> >> Date:   Tue Oct 21 14:13:47 2008 -0400
> >> 
> >>     svcrpc: take advantage of tcp autotuning
> >>  
> >> which is also quoted below.  Using 8 nfsd threads, a single client doing
> >> 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
> >> KB/s under 2.6.30-rc4.  I also see more run to run variation under
> >> 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
> >> variation disappears (as does the performance regression) when reverting
> >> the above commit.
> >
> > It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
> > function. I can see no reason why we should stop processing new incoming
> > RPC requests just because the send buffer happens to be 2/3 full. If we
> > see that we have space for another reply, then we should just go for it.
> > OTOH, we do want to ensure that the SOCK_NOSPACE flag remains set, so
> > that the TCP layer knows that we're congested, and that we'd like it to
> > increase the send window size, please.
> >
> > Could you therefore please see if the following (untested) patch helps?
> 
> I'm seeing slightly better results with the patch:
> 
> 71548
> 75987
> 71557
> 87432
> 83538
> 
> But that's still not up to the speeds we saw under 2.6.29.  The packet
> capture for one run can be found here:
>   http://people.redhat.com/jmoyer/trond.pcap.bz2
> 
> Cheers,
> Jeff

Yes. Something is very wrong there...

See for instance frame 1195, where the client finishes sending a whole
series of READ requests, and we go into a flurry of ACKs passing
backwards and forwards, but no data. It looks as if the NFS server isn't
processing anything, probably because the window size falls afoul of the
svc_tcp_has_wspace()...

Does something like this help?

Cheers
  Trond
---------------------------------------------------------------------
>From 85e3f5860a9063d193bdb45516b3d3d347b87301 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 14 May 2009 10:33:07 -0400
Subject: [PATCH] SUNRPC: Always allow the NFS server to process at least one request

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/svcsock.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8962355..4837442 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -972,9 +972,16 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	int reserved;
 	int required;
 
-	required = (atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg) * 2;
+	reserved = atomic_read(&xprt->xpt_reserved);
+	/* Always allow the server to process at least one request, whether
+	 * or not the TCP window is large enough
+	 */
+	if (reserved == 0)
+		return 1;
+	required = (reserved + serv->sv_max_mesg) << 1;
 	if (sk_stream_wspace(svsk->sk_sk) < required)
 		goto out_nospace;
 	return 1;
-- 
1.6.0.4



