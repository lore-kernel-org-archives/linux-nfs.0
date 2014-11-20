Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:36568 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbaKTSrL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 13:47:11 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFSoRDMA developers bi-weekly meeting minutes (11/20)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <546E31C0.1070400@oracle.com>
Date: Thu, 20 Nov 2014 13:46:38 -0500
Cc: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "Devesh.Sharma@emulex.com" <Devesh.Sharma@emulex.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "dominique.martinet@cea.fr" <dominique.martinet@cea.fr>,
        "jeffrey.c.becker@nasa.gov" <jeffrey.c.becker@nasa.gov>,
        "rsdance@soft-forge.com" <rsdance@soft-forge.com>,
        "skc@lanl.gov" <skc@lanl.gov>,
        "sprabhu@redhat.com" <sprabhu@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "wendy.cheng@intel.com" <wendy.cheng@intel.com>,
        "yanb@mellanox.com" <yanb@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2DA1028B-0EE0-415F-BA98-B9A50C87F820@oracle.com>
References: <546E31C0.1070400@oracle.com>
To: Shirley Ma <shirley.ma@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 20, 2014, at 1:24 PM, Shirley Ma <shirley.ma@oracle.com> wrote:

> Attendees:
> 
> Jeff Becker (NASA)
> Yan Burman (Mellanox)
> Wendy Cheng (Intel)
> Rupert Dance (Soft Forge)
> Steve Dickson (Red Hat)
> Chuck Lever (Oracle)
> Doug Ledford (RedHat)
> Shirley Ma (Oracle)
> Sachin Prabhu (RedHat)
> Devesh Sharma (Emulex)
> Anna Schumaker (Net App)
> Steve Wise (OpenGridComputing, Chelsio)
> 
> Moderator:
> Shirley Ma (Oracle)
> 
> NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested with a quorum of HW vendors.
> 
> Today's meeting notes:
> 
> NFSoRDMA performance:
> ---------------------
> Even though NFSoRDMA performance seems better than IPoIB-cm, the gap between what the IB protocol can provide and what NFS(RDMA,IPoIB-cm) can achieve is still big on small I/O block size (focused on 8K IO size for database workload). Even large I/O block size(128K above), NFS performance is not comparable to RDMA microbenchmark. We are focusing the effort to figure out the root cause. Several experimental methods have been used on how to improve NFSoRDMA performance.
> 
> Yan saw NFS server does RDMA send for small packet size, less than 100bytes, which should have used post_send instead.

This is an artifact of how NFS/RDMA works.

The client provides a registered area for the server to write
into if an RPC reply is larger than the small pre-posted
buffers that are normally used.

Most of the time, each RPC reply is small enough to use RDMA
SEND, and the server can convey the RPC/RDMA header and the
RPC reply in a single SEND operation.

If the reply is large, the server conveys the RPC/RDMA header
via RDMA send, and the RPC reply via an RDMA WRITE into the
client’s registered buffer.

Solaris server chooses RDMA SEND in nearly every case.

Linux server chooses RDMA SEND then RDMA WRITE whenever
the client offers that choice.

Originally, it was felt that doing the RDMA WRITE is better
for the client because the client doesn’t have to copy the
RPC header from the RDMA receive buffer back into rq_rcv_buf.
Note that the RPC header is generally just a few hundred
bytes.

Several people have claimed that RDMA WRITE for small I/O
is relatively expensive and should be avoided. It’s also
expensive for the client to register and deregister the
receive buffer for the RDMA WRITE if the server doesn’t
use it.

I’ve explored changing the client to offer no registered
buffer if it knows the RPC reply will be small, thus
forcing the server to use RDMA SEND where it’s safe.

Solaris server worked fine. Of course, it already works
this way.

Linux server showed some data and metadata corruption on
complex workloads like kernel builds. There’s a bug in
there somewhere that will need to be addressed before we
can change the client behavior.

The improvement was consistent, but under ten microseconds
per RPC with FRWR (more with FMR because deregistering the
buffer takes longer and is synchronous with RPC execution).

At this stage, there are bigger problems to be addressed,
so this is not a top priority.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



