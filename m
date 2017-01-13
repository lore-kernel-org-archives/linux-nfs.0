Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24492 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdAMQyG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 11:54:06 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 00/22] convert NFS server to new rdma_rw API
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170113164208.GD24709@fieldses.org>
Date: Fri, 13 Jan 2017 11:54:01 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <33FF9D08-075A-4153-ADDA-C460C1A4D93B@oracle.com>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net> <20170113164208.GD24709@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-


> On Jan 13, 2017, at 11:42 AM, bfields@fieldses.org wrote:
> 
> Can you summarize the motivation for the change, for someone (like me)
> that doesn't know much about RDMA?  Or does "significant cleanups" cover
> it?

Last year, Sagi and Christoph introduced a new set of APIs to the
RDMA core that enable ULPs like iSER and NFS/RDMA to leave the details
of certain aspects of operation to the core, instead of all the ULPs
having to implement the details themselves. Kind of a code refactoring /
de-duplication.

Then, going forward, fixes and improvements made to the logic behind
this new API will be available to all ULPs that use the new API.

This series converts the server-side RPC-over-RDMA implementation
to use the new API.


> Are there any regressions?  For example, will it still support all the
> same hardware?  Is there any change that will be noticeable to NFS/RDMA
> users?

All the same hardware is supported. The standing policy for ULPs is
that they must work with all in-tree HCA drivers and devices.

The goal of this work is that there is no user-visible change in
functionality or performance.

I know it's a lot to consider, and I'm happy to split up the series
or individual patches to help review.


> --b.
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
>> 
>> Available in the "nfsd-rdma-rw-api" topic branch of this git repo:
>> 
>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>> 
>> And for online review:
>> 
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfsd-rdma-rw-api
>> 
>> ---
>> 
>> Chuck Lever (22):
>>      svcrdma: Another sendto chunk list parsing update
>>      svcrdma: Replace RPCRDMA_SQ_DEPTH_MULT
>>      svcrdma: Remove unused sc_dto_q field
>>      svcrdma: Combine list fields in struct svc_rdma_op_ctxt
>>      svcrdma: Poll CQs in "workqueue" mode
>>      svcrdma: Clean up RPC-over-RDMA Reply header encoder
>>      svcrdma: Clean up RPC-over-RDMA Call header decoder
>>      svcrdma: Introduce local rdma_rw API helpers
>>      svcrdma: Use rdma_rw API in RPC reply path
>>      svcrdma: Backchannel sendto clean up
>>      svcrdma: Clean up RDMA_ERROR path
>>      svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
>>      svcrdma: Remove old RDMA Write completion handlers
>>      svcrdma: Remove the req_map cache
>>      svcrdma: Clean up RPC-over-RDMA backchannel reply processing
>>      svcrdma: Use generic RDMA R/W API in RPC Call path
>>      svcrdma: Remove unused Read completion handlers
>>      svcrdma: Remove frmr cache
>>      svcrdma: Clean up after converting svc_rdma_recvfrom to rdma_rw API
>>      svcrdma: Clean-up in svc_rdma_post_recv
>>      svcrdma: Clean-up svc_rdma_unmap_dma
>>      svcrdma: Re-order fields in svc_rdma_op_ctxt
>> 
>> 
>> include/linux/sunrpc/rpc_rdma.h            |   12 
>> include/linux/sunrpc/svc_rdma.h            |  147 ++---
>> net/sunrpc/xprtrdma/Makefile               |    2 
>> net/sunrpc/xprtrdma/svc_rdma.c             |    8 
>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   73 +--
>> net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  478 +++++++++--------
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  518 +++---------------
>> net/sunrpc/xprtrdma/svc_rdma_rw.c          |  731 ++++++++++++++++++++++++++
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  802 +++++++++++-----------------
>> net/sunrpc/xprtrdma/svc_rdma_transport.c   |  506 +++++-------------
>> 10 files changed, 1621 insertions(+), 1656 deletions(-)
>> create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c
>> 
>> --
>> Chuck Lever
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



