From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: svcrdma/xprtrdma fast memory registration questions
Date: Fri, 26 Sep 2008 09:14:03 -0400
Message-ID: <RTPCLUEXC2-PRDFRaqb00000032@RTPMVEXC1-PRD.hq.netapp.com>
References: <1222357183.32577.34.camel@sale659>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Tom Tucker" <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "Jim Schutt" <jaschut@sandia.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39821 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbYIZNPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 09:15:14 -0400
In-Reply-To: <1222357183.32577.34.camel@sale659>
References: <1222357183.32577.34.camel@sale659>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 11:39 AM 9/25/2008, Jim Schutt wrote:
>Hi,
>
>I've been giving the fast memory registration NFS RDMA
>patches a spin, and I've got a couple questions.

Your questions are mainly about the client, so I'll jump in here too...

>
>AFAICS the default xprtrdma memory registration model 
>is still RPCRDMA_ALLPHYSICAL; I had to 
>  "echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy"
>prior to a mount to get fast registration.  Given that fast 
>registration has better security properties for iWARP, and 
>the fallback is RPCRDMA_ALLPHYSICAL if fast registration is 
>not supported, is it more appropriate to have RPCRDMA_FASTREG 
>be the default?

Possibly. At this point we don't have enough experience with FASTREG
to know whether it's better. For large-footprint memory on the server
with a Chelsio interconnect, it's required, but on Infiniband adapters,
there are more degrees of freedom and historically ALLPHYS works best.

Also, at this point we don't know that FASTREG is really FASTer. :-)
Frankly, I hate calling things "fast" or "new", there's always something
"faster" or "newer". But the OFA code uses this name. In any case,
the codepath still needs testing and performance evaluation before
we make it a default.


>Second, it seems that the number of pages in a client fast 
>memory registration is still limited to RPCRDMA_MAX_DATA_SEGS.
>So on a client write, without fast registration I get 
>RPCRDMA_MAX_DATA_SEGS RDMA reads of 1 page each, whereas with 
>fast registration I get 1 RDMA read of RPCRDMA_MAX_DATA_SEGS 
>pages.

Yes, the client is currently limited to this many segments. You can raise
the number by recompiling, but I don't recommend it, the client gets rather
greedy with per-mount memory. I do plan to remedy this.

In the meantime, let me offer the observation that multiple RDMA Reads
are not a penalty, since they are able to stream up to the IRD max offered
by the client, which is in turn more than sufficient to maintain bandwidth
usage. Are you seeing a bottleneck? If so, I'd like to see the output from
the client with RPCDBG_TRANS turned on, it prints the IRD at connect time.

>In either case my maximum rsize, wsize for an RDMA mount
>is still 32 KiB.

Yes. But here's the deal - write throughput is almost never a network
problem. Instead, it's either a server ordering problem, or a congestion/
latency issue. The rub is, large I/O's help the former (by cramming lots
of writes together in a single request), but they hurt the latter (by
cramming large chunks into the pipe).

In other words, small I/Os on low-latency networks can be good.

However, the Linux NFS server has a rather clumsy interface to the
backing filesystem, and if you're using ext, its ability to handle many
32KB sized writes in arbitrary order is somewhat poor. What type
of storage are you exporting? Are you using async on the server?

>
>My understanding is that, e.g., a Chelsio T3 with the 
>2.6.27-rc driver can support 24 pages in a fast registration
>request.  So, what I was hoping to see with a T3 were RPCs with 
>RPCRDMA_MAX_DATA_SEGS  chunks, each for a fast registration of 
>24 pages each, making possible an RDMA mount with 768 KiB for
>rsize, wsize.

You can certainly try raising MAX_DATA_SEGS to this value and building
a new sunrpc module. I do not recommend such a large write size however;
you won't be able to do many mounts, due to resource issues on both client
and server.

If you're seeing throughput problems, I would suggest trying a 64KB write
size first (MAX_DATA_SEGS==16), and if that improves then maybe 128KB (32).
128KB is generally more than enough to make ext happy (well, happi*er*).

>
>Is something like that possible?  If so, do you have any
>work in progress along those lines?

I do. But I'd be very interested to see more data before committing to
the large-io approach. Can you help?

Tom.

