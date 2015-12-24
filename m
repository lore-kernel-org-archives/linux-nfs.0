Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26997 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbLXJ5K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Dec 2015 04:57:10 -0500
References: <20151214211951.12932.99017.stgit@klimt.1015granger.net> <CANjDDBjypu0jX22fZ-Nf-bNNeam2MM0MADaZY9C-o9ihJPiseg@mail.gmail.com> <20151223210015.GA29650@fieldses.org>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20151223210015.GA29650@fieldses.org>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <5A2D6A9F-5A7C-43DB-ACEC-7D7EEE793FE6@oracle.com>
Cc: Devesh Sharma <devesh.sharma@avagotech.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v4 00/11] NFS/RDMA server patches for v4.5
Date: Thu, 24 Dec 2015 09:57:01 +0000
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My functional test suite includes Cthon, iozone, dbench, fio,
multi-threaded builds of git and the Linux kernel, and xfstests.

This patch series passes with NFSv3, NFSv4.0, and now NFSv4.1.

--
Chuck Lever

> On Dec 23, 2015, at 21:00, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Wed, Dec 16, 2015 at 05:40:09PM +0530, Devesh Sharma wrote:
>> iozone passed on ocrdma device.
> 
> What other testing has there been of this patchset?
> 
> Connectathon, xfstests, and pynfs make more of an effort to test corner
> cases, iozone isn't much of a test of correctness.
> 
> --b.
> 
>> Link bounce fails to recover iozone
>> traffic, however failure is not related to this patch series. I am in
>> processes of finding out the patch which broke it.
>> 
>> Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
>> 
>>> On Tue, Dec 15, 2015 at 3:00 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Here are patches to support server-side bi-directional RPC/RDMA
>>> operation (to enable NFSv4.1 on RPC/RDMA transports). Thanks to
>>> all who reviewed v1, v2, and v3. This version has some significant
>>> changes since the previous one.
>>> 
>>> In preparation for Doug's final topic branch, Bruce, I've rebased
>>> these on Christoph's ib_device_attr branch. There were some merge
>>> conflicts which I've fixed and tested. These are ready for your
>>> review.
>>> 
>>> Also available in the "nfsd-rdma-for-4.5" topic branch of this git repo:
>>> 
>>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>>> 
>>> Or for browsing:
>>> 
>>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.5
>>> 
>>> 
>>> Changes since v3:
>>> - Rebased on Christoph's ib_device_attr branch
>>> - Backchannel patches have been squashed together
>>> - Memory allocation overhaul to prevent blocking allocation
>>>  when sending backchannel calls
>>> 
>>> 
>>> Changes since v2:
>>> - Rebased on v4.4-rc4
>>> - Backchannel code in new source file to address dprintk issues
>>> - svc_rdma_get_context() now uses a pre-allocated cache
>>> - Dropped svc_rdma_send clean up
>>> 
>>> 
>>> Changes since v1:
>>> 
>>> - Rebased on v4.4-rc3
>>> - Removed the use of CONFIG_SUNRPC_BACKCHANNEL
>>> - Fixed computation of forward and backward max_requests
>>> - Updated some comments and patch descriptions
>>> - pr_err and pr_info converted to dprintk
>>> - Simplified svc_rdma_get_context()
>>> - Dropped patch removing access_flags field
>>> - NFSv4.1 callbacks tested with for-4.5 client
>>> 
>>> ---
>>> 
>>> Chuck Lever (11):
>>>      svcrdma: Do not send XDR roundup bytes for a write chunk
>>>      svcrdma: Clean up rdma_create_xprt()
>>>      svcrdma: Clean up process_context()
>>>      svcrdma: Improve allocation of struct svc_rdma_op_ctxt
>>>      svcrdma: Improve allocation of struct svc_rdma_req_map
>>>      svcrdma: Remove unused req_map and ctxt kmem_caches
>>>      svcrdma: Add gfp flags to svc_rdma_post_recv()
>>>      svcrdma: Remove last two __GFP_NOFAIL call sites
>>>      svcrdma: Make map_xdr non-static
>>>      svcrdma: Define maximum number of backchannel requests
>>>      svcrdma: Add class for RDMA backwards direction transport
>>> 
>>> 
>>> include/linux/sunrpc/svc_rdma.h            |   37 ++-
>>> net/sunrpc/xprt.c                          |    1
>>> net/sunrpc/xprtrdma/Makefile               |    2
>>> net/sunrpc/xprtrdma/svc_rdma.c             |   41 ---
>>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  371 ++++++++++++++++++++++++++++
>>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   52 ++++
>>> net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   34 ++-
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c   |  284 ++++++++++++++++-----
>>> net/sunrpc/xprtrdma/transport.c            |   30 +-
>>> net/sunrpc/xprtrdma/xprt_rdma.h            |   20 +-
>>> 10 files changed, 730 insertions(+), 142 deletions(-)
>>> create mode 100644 net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>>> 
>>> --
>>> Signature
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
