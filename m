Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42336 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbbJNPet convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 11:34:49 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v2 00/16] NFS/RDMA patches for merging into v4.4
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBj5vyu3cG5fGe_w0pJxAxPUSwyBFFha5sNOCvfcwidc0A@mail.gmail.com>
Date: Wed, 14 Oct 2015 11:34:48 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E7CD827E-53F6-4313-93F8-B85E63865A10@oracle.com>
References: <20151006142430.11788.42604.stgit@manet.1015granger.net> <CANjDDBj5vyu3cG5fGe_w0pJxAxPUSwyBFFha5sNOCvfcwidc0A@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 14, 2015, at 9:32 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:
> 
> Hi Chuck,
> 
> With the server crash fix in place, ocrdma is passing iozone on this series.
> 
> Series Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>

Thanks to you and Sagi. A v3 is coming soon, which should be more
or less ready to merge.


> 
> On Tue, Oct 6, 2015 at 8:28 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Introduce client-side support for bi-directional RPC/RDMA.
>> Bi-directional RPC/RDMA is a pre-requisite for NFSv4.1 on RDMA
>> transports.
>> 
>> Also available in the "nfs-rdma-for-4.4" topic branch of this git repo:
>> 
>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>> 
>> Or for browsing:
>> 
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.4
>> 
>> Changes since v1:
>> - Dropped "RFC" in Subject: line
>> - Rebased on v4.3-rc4 + Steve W's recent fixes
>> - NFS Server-side backchannel support postponed
>> - "xprtrdma: Replace global lkey" dropped, already merged
>> - Addressed Sagi's comments on "Replace send and receive arrays"
>> - Addressed Jason's comment regarding ib_req_notify_cq return code
>> - Moved RPC/RDMA reply handling into a work queue
>> 
>> I'm assuming recent list discussion has addressed Devesh's and
>> Sagi's concerns with "Prevent loss of completion signals". Let me
>> know if there is still a problem.
>> 
>> ---
>> 
>> Chuck Lever (16):
>>      xprtrdma: Enable swap-on-NFS/RDMA
>>      xprtrdma: Re-arm after missed events
>>      xprtrdma: Prevent loss of completion signals
>>      xprtrdma: Refactor reply handler error handling
>>      xprtrdma: Replace send and receive arrays
>>      xprtrdma: Use workqueue to process RPC/RDMA replies
>>      xprtrdma: Remove reply tasklet
>>      xprtrdma: Saving IRQs no longer needed for rb_lock
>>      SUNRPC: Abstract backchannel operations
>>      xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
>>      xprtrdma: Pre-allocate Work Requests for backchannel
>>      xprtrdma: Add support for sending backward direction RPC replies
>>      xprtrdma: Handle incoming backward direction RPC calls
>>      svcrdma: Add backward direction service for RPC/RDMA transport
>>      SUNRPC: Remove the TCP-only restriction in bc_svc_process()
>>      NFS: Enable client side NFSv4.1 backchannel to use other transports
>> 
>> 
>> fs/nfs/callback.c                        |   33 +-
>> include/linux/sunrpc/bc_xprt.h           |    5
>> include/linux/sunrpc/svc_rdma.h          |    6
>> include/linux/sunrpc/xprt.h              |    7
>> net/sunrpc/backchannel_rqst.c            |   24 +-
>> net/sunrpc/svc.c                         |    5
>> net/sunrpc/xprtrdma/Makefile             |    1
>> net/sunrpc/xprtrdma/backchannel.c        |  373 +++++++++++++++++++++++
>> net/sunrpc/xprtrdma/rpc_rdma.c           |  148 ++++++---
>> net/sunrpc/xprtrdma/svc_rdma.c           |    6
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   58 ++++
>> net/sunrpc/xprtrdma/transport.c          |   18 +
>> net/sunrpc/xprtrdma/verbs.c              |  479 +++++++++++++++---------------
>> net/sunrpc/xprtrdma/xprt_rdma.h          |   53 +++
>> net/sunrpc/xprtsock.c                    |   16 +
>> 15 files changed, 916 insertions(+), 316 deletions(-)
>> create mode 100644 net/sunrpc/xprtrdma/backchannel.c
>> 
>> --
>> Chuck Lever
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



