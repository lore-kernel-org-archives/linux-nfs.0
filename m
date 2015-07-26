Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35358 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856AbbGZKXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 06:23:10 -0400
Received: by wibxm9 with SMTP id xm9so76625344wib.0
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 03:23:08 -0700 (PDT)
Subject: Re: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161904.25617.85015.stgit@build2.ogc.int>
 <20150724165721.GC25480@obsidianresearch.com>
 <00ce01d0c641$493ea300$dbbbe900$@opengridcomputing.com>
 <20150724192411.GC26225@obsidianresearch.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B4B510.8050106@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 13:23:12 +0300
MIME-Version: 1.0
In-Reply-To: <20150724192411.GC26225@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/24/2015 10:24 PM, Jason Gunthorpe wrote:
> On Fri, Jul 24, 2015 at 01:48:09PM -0500, Steve Wise wrote:
>>> The use of FRWR for RDMA READ should be iWarp specific, IB shouldn't
>>> pay that overhead. I am expecting to see a cap_rdma_read_rkey or
>>> something in here ?
>>
>> Ok.  But cap_rdma_read_rkey() doesn't really describe the
>> requirement.  The requirement is rkey + REMOTE_WRITE.  So it is more
>> like rdma_cap_read_requires_remote_write() which is ugly and too
>> long (but descriptive)...
>
> I don't care much what name you pick, just jam something like this in
> the description

I think we can just do if (signature || iwarp) use fastreg else
use local_dma_lkey.

>
>   If set then RDMA_READ must be performed by mapping the local
>   buffers through a rkey MR with ACCESS_REMOTE_WRITE enabled.
>   The rkey of this MR should be passed in as the sg_lists's lkey for
>   IB_WR_RDMA_READ_WITH_INV.

I think this would be an incremental patch and not as part of iwarp
support.

Question though, wouldn't it be better to do a single RDMA_READ to say
4 registered keys rather than RDMA_READ_WITH_INV for each?
