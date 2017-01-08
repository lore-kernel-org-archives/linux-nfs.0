Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28038 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdAHRUM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2017 12:20:12 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 00/22] convert NFS server to new rdma_rw API
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170108143402.GA2243@infradead.org>
Date: Sun, 8 Jan 2017 12:19:34 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <312B4362-D35D-4E14-9E30-7F85EF54EEEA@oracle.com>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net> <20170108143402.GA2243@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 8, 2017, at 9:34 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Sat, Jan 07, 2017 at 12:15:15PM -0500, Chuck Lever wrote:
>> This series converts the Linux NFS server RPC-over-RDMA
>> implementation to use the new core rdma_rw API and to poll its CQs
>> in workqueue mode.
>> 
>> Previously published work prototyped only the path that sends RPC
>> replies. This series converts both send and receive sides, and
>> includes significant clean ups that result from using the new API.
>> 
>> This series has been successfully tested with NFSv3, 4.0, and 4.1;
>> with clients that use FRWR and FMR; and with sec=sys, krb5, krb5i,
>> and krb5p.
> 
> Any performane improvements (or regressions) with it?

NFS WRITE throughput is slightly lower. The maximum is still in
the 25 to 30 Gbps range on FDR. We have previously discussed two
additional major improvements:

- allocating memory and posting RDMA Reads from the Receive
completion handler

- utilizing splice where possible in the NFS server's write path

I'm still thinking about how these should work. IMO it's not a
reason to hold up review and merging what has been done so far.

For NFS READ, I can reach fabric speed. However, the results vary
significantly due to congestion at the client HCA. This is not
a new issue with this patch series.

Some improvement noted in maximum 8KB IOPS.


>> 10 files changed, 1621 insertions(+), 1656 deletions(-)
> 
> Hmm, that's not much less code, especially compared to the
> other target side drivers where we remove a very substantial amount of
> code.  I guess I need to spend some time with the individual patches
> to understand why.

Some possible reasons:


RPC-over-RDMA is more complex than the other RDMA-enabled storage
protocols, allowing more than one RDMA segment (R_key) per RPC
transaction.

For example, a client that requests a 1MB NFS READ payload is
permitted to split the receive buffers among multiple RDMA segments
with unique R_keys. As I understand the rdma_rw API, each R_key
would need its own rdma_ctx.


Basic FRWR does not support discontiguous segments (one R_key with
a memory region that has gaps). The send path has to transmit xdr_bufs
where the head, page list, and tail are separate memory regions. This
is needed, for example, when sending a whole RPC Reply via RDMA (a
Reply chunk).

Therefore for full generality RDMA segments have to be broken up
across the RPC Reply's xdr_buf, requiring multiple rdma_ctx's. The
RDMA Read logic does not have this constraint: it always reads into a
list of pages, which is straightforward to convert into a single
scatterlist.


There is some clean-up of the use of C structures to access received
messages before they are XDR decoded, and to marshal messages before
they are sent. This has been replaced with the more portable style
of using __be32 pointers, and accounts for a significant amount of
churn.


The new code has more documenting comments that explain the memory
allocation and DMA mapping architecture, and preface each public
function. I estimate this accounts for at least two to three hundred
lines of insertions, maybe more.


--
Chuck Lever



