Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:14373 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756834AbaGXNTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jul 2014 09:19:15 -0400
Message-ID: <53D107D0.1050407@Netapp.com>
Date: Thu, 24 Jul 2014 09:19:12 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 00/21] NFS/RDMA client patches for 3.17
References: <20140722144459.6010.99389.stgit@manet.1015granger.net> <53D004A0.7030803@Netapp.com> <37564E5B-5955-436B-88D2-888ADC3D7A00@oracle.com>
In-Reply-To: <37564E5B-5955-436B-88D2-888ADC3D7A00@oracle.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/23/2014 05:23 PM, Chuck Lever wrote:
> 
> 
>> On Jul 23, 2014, at 2:53 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> I've applied these changes and pushed them out in my nfs-rdma branch.  I'm planning to send a pull request to Trond on Friday so these changes can spend some time in linux-next before the next merge window opens.
> 
> Thank you! Did you resolve your question about who will merge the ib_dec_rkey patch, or do you want me to pursue that?

I don't have an answer yet (fingers crossed that it's not a problem!).  I think adding ib_dec_rkey() would need to go through Roland Dreier if it doesn't go through me.

Anna

> 
>>
>> Anna
>>
>>> On 07/22/2014 10:50 AM, Chuck Lever wrote:
>>> The main purpose of this series is to address connection drop
>>> recovery issues by fixing FRMR re-use to make it less likely the
>>> client will deadlock due to a memory management operation error.
>>> Some clean-ups and other fixes are present as well.
>>>
>>> Anna, v4 of this series should be ready for merging.
>>>
>>> See topic branch nfs-rdma-for-3.17 in
>>>
>>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>>>
>>> I tested with NFSv3 and NFSv4 on all three supported memory
>>> registration modes. Used cthon04, iozone, and dbench with both
>>> Solaris and Linux NFS/RDMA servers. Used xfstests with Linux.
>>>
>>> v4:
>>>
>>> - Rebased on v3.16-rc6
>>>
>>> - Add Tested-by: from Shirley Ma and Devesh Sharma
>>>
>>>
>>> v3:
>>> Only two substantive changes:
>>>
>>> - Patch 08/21 now uses generic IB helpers for managing FRMR
>>> rkeys
>>>
>>> - Add Tested-by: from Steve Wise
>>>
>>>
>>> v2:
>>> Many patches from v1 have been written or replaced.
>>>
>>> The MW ref counting approach in v1 is abandoned. Instead, I've
>>> eliminated signaling FAST_REG_MR and LOCAL_INV, and added
>>> appropriate recovery mechanisms after a transport reconnect that
>>> should prevent rkey dis-synchrony entirely.
>>>
>>> A couple of optimizations have been added, including:
>>>
>>> - Allocating each MW separately rather than carving each out of a
>>> large piece of contiguous memory
>>>
>>> - Now that the receive CQ upcall handler dequeues a bundle of CQEs
>>> at once, fire off the reply handler tasklet just once per upcall
>>> to reduce context switches and how often hard IRQs are disabled
>>>
>>> ---
>>>
>>> Chuck Lever (21):
>>>      xprtrdma: Fix panic in rpcrdma_register_frmr_external()
>>>      xprtrdma: Protect ia->ri_id when unmapping/invalidating MRs
>>>      xprtrdma: Limit data payload size for ALLPHYSICAL
>>>      xprtrdma: Update rkeys after transport reconnect
>>>      xprtrdma: On disconnect, don't ignore pending CQEs
>>>      xprtrdma: Don't invalidate FRMRs if registration fails
>>>      xprtrdma: Unclutter struct rpcrdma_mr_seg
>>>      xprtrdma: Back off rkey when FAST_REG_MR fails
>>>      xprtrdma: Chain together all MWs in same buffer pool
>>>      xprtrdma: Properly handle exhaustion of the rb_mws list
>>>      xprtrdma: Reset FRMRs when FAST_REG_MR is flushed by a disconnect
>>>      xprtrdma: Reset FRMRs after a flushed LOCAL_INV Work Request
>>>      xprtrdma: Don't post a LOCAL_INV in rpcrdma_register_frmr_external()
>>>      xprtrdma: Disable completions for FAST_REG_MR Work Requests
>>>      xprtrdma: Disable completions for LOCAL_INV Work Requests
>>>      xprtrdma: Rename frmr_wr
>>>      xprtrdma: Allocate each struct rpcrdma_mw separately
>>>      xprtrdma: Schedule reply tasklet once per upcall
>>>      xprtrdma: Make rpcrdma_ep_disconnect() return void
>>>      xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
>>>      xprtrdma: Handle additional connection events
>>>
>>>
>>> include/linux/sunrpc/xprtrdma.h |    2 
>>> include/rdma/ib_verbs.h         |   11 +
>>> net/sunrpc/xprtrdma/rpc_rdma.c  |   83 ++--
>>> net/sunrpc/xprtrdma/transport.c |   17 +
>>> net/sunrpc/xprtrdma/verbs.c     |  744 ++++++++++++++++++++++++++-------------
>>> net/sunrpc/xprtrdma/xprt_rdma.h |   61 +++
>>> 6 files changed, 615 insertions(+), 303 deletions(-)
>>>
>>> --
>>> Chuck Lever
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

