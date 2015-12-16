Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36212 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbbLPMLl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 07:11:41 -0500
Received: by mail-qk0-f173.google.com with SMTP id t125so59719194qkh.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2015 04:11:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56706BE0.7010609@Netapp.com>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net> <56706BE0.7010609@Netapp.com>
From: Devesh Sharma <devesh.sharma@avagotech.com>
Date: Wed, 16 Dec 2015 17:41:01 +0530
Message-ID: <CANjDDBie2igLpqSXiEbswtiO41BmvruVOfu9wXhLa8B6XVbWQg@mail.gmail.com>
Subject: Re: [PATCH v3 00/11] NFS/RDMA client patches for 4.5
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

iozone passed on ocrdma device. Link bounce fails to recover iozone
traffic, however failure is not related to this patch series. I am in
processes of finding out the patch which broke it.

Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>

On Wed, Dec 16, 2015 at 1:07 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Thanks, Chuck!
>
> Everything looks okay to me, so I'll apply these patches and send them to Trond before the holiday.
>
> On 12/14/2015 04:17 PM, Chuck Lever wrote:
>> For 4.5, I'd like to address the send queue accounting and
>> invalidation/unmap ordering issues Jason brought up a couple of
>> months ago.
>>
>> In preparation for Doug's final topic branch, Anna, I've rebased
>> these on Christoph's ib_device_attr branch, but there were no merge
>> conflicts or other changes needed. Could you begin preparing these
>> for linux-next and other final testing and review?
>
> No merge conflicts is nice, and we might not need to worry about ordering the pull request.
>
> Thanks,
> Anna
>
>>
>> Also available in the "nfs-rdma-for-4.5" topic branch of this git repo:
>>
>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>>
>> Or for browsing:
>>
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.5
>>
>>
>> Changes since v2:
>> - Rebased on Christoph's ib_device_attr branch
>>
>>
>> Changes since v1:
>>
>> - Rebased on v4.4-rc3
>> - Receive buffer safety margin patch dropped
>> - Backchannel pr_err and pr_info converted to dprintk
>> - Backchannel spin locks converted to work queue-safe locks
>> - Fixed premature release of backchannel request buffer
>> - NFSv4.1 callbacks tested with for-4.5 server
>>
>> ---
>>
>> Chuck Lever (11):
>>       xprtrdma: Fix additional uses of spin_lock_irqsave(rb_lock)
>>       xprtrdma: xprt_rdma_free() must not release backchannel reqs
>>       xprtrdma: Disable RPC/RDMA backchannel debugging messages
>>       xprtrdma: Move struct ib_send_wr off the stack
>>       xprtrdma: Introduce ro_unmap_sync method
>>       xprtrdma: Add ro_unmap_sync method for FRWR
>>       xprtrdma: Add ro_unmap_sync method for FMR
>>       xprtrdma: Add ro_unmap_sync method for all-physical registration
>>       SUNRPC: Introduce xprt_commit_rqst()
>>       xprtrdma: Invalidate in the RPC reply handler
>>       xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').
>>
>>
>>  include/linux/sunrpc/xprt.h        |    1
>>  net/sunrpc/xprt.c                  |   14 +++
>>  net/sunrpc/xprtrdma/backchannel.c  |   22 ++---
>>  net/sunrpc/xprtrdma/fmr_ops.c      |   64 +++++++++++++
>>  net/sunrpc/xprtrdma/frwr_ops.c     |  175 +++++++++++++++++++++++++++++++-----
>>  net/sunrpc/xprtrdma/physical_ops.c |   13 +++
>>  net/sunrpc/xprtrdma/rpc_rdma.c     |   14 +++
>>  net/sunrpc/xprtrdma/transport.c    |    3 +
>>  net/sunrpc/xprtrdma/verbs.c        |   13 +--
>>  net/sunrpc/xprtrdma/xprt_rdma.h    |   12 +-
>>  10 files changed, 283 insertions(+), 48 deletions(-)
>>
>> --
>> Chuck Lever
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
