Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35727 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbbEJKRn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 May 2015 06:17:43 -0400
Received: by widdi4 with SMTP id di4so74323152wid.0
        for <linux-nfs@vger.kernel.org>; Sun, 10 May 2015 03:17:42 -0700 (PDT)
Message-ID: <554F3043.4090303@dev.mellanox.co.il>
Date: Sun, 10 May 2015 13:17:39 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Devesh Sharma <devesh.sharma@avagotech.com>
CC: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 08/14] xprtrdma: Acquire MRs in rpcrdma_register_external()
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175758.3483.44890.stgit@manet.1015granger.net> <554B3EEB.7070302@dev.mellanox.co.il> <CANjDDBiGLcaAofGwz6OGEXUUE_b2rcZepv0ebvTc-XNVEBq5Mw@mail.gmail.com> <6FBAAAF3-3E70-418F-A887-C022525D6C4F@oracle.com>
In-Reply-To: <6FBAAAF3-3E70-418F-A887-C022525D6C4F@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/8/2015 6:40 PM, Chuck Lever wrote:

>>>
>>> Don't you need a call to flush_workqueue(frwr_recovery_wq) when you're
>>> about to destroy the endpoint (and the buffers and the MRs...)?
>>
>> I agree with Sagi here, in xprt_rdma_destroy() before calling
>> rpcrdma_destroy_buffer(), flush_workqueue and cancelling any pending
>> work seems required.
>
> The buffer list is destroyed only when all work has completed on the
> transport (no RPCs are outstanding, and the upper layer is shutting
> down). It’s pretty unlikely that there will be ongoing recovery work
> at this point.

It may be that there aren't any outstanding RPCs, but it is possible
that those that finished queued a frwr recovery work if the QP flushed
inflight frwr's.

>
> That said, would it be enough to add a defensive call to flush_workqueue()
> at the top of frwr_op_destroy() ?

If at this point you can guarantee that no one will queue another frwr
work (i.e. all flushe errors were consumed), then yes, I think
flush_workqueue() would do the job.

Sagi.
