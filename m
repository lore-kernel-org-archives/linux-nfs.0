Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33436 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbbGZJ5o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 05:57:44 -0400
Received: by wicmv11 with SMTP id mv11so106444616wic.0
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 02:57:43 -0700 (PDT)
Subject: Re: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to
 device fastreg max depth
To: Steve Wise <swise@opengridcomputing.com>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161820.25617.63886.stgit@build2.ogc.int>
 <20150724164123.GA25480@obsidianresearch.com>
 <00ca01d0c640$2f813d70$8e83b850$@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B4AF1A.2050406@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 12:57:46 +0300
MIME-Version: 1.0
In-Reply-To: <00ca01d0c640$2f813d70$8e83b850$@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/24/2015 9:40 PM, Steve Wise wrote:
>
>
>> -----Original Message-----
>> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
>> Sent: Friday, July 24, 2015 11:41 AM
>> To: Steve Wise
>> Cc: dledford@redhat.com; infinipath@intel.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-
>> rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; bfields@fieldses.org
>> Subject: Re: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to device fastreg max depth
>>
>> On Fri, Jul 24, 2015 at 11:18:21AM -0500, Steve Wise wrote:
>>> Currently the sg tablesize, which dictates fast register page list
>>> depth to use, does not take into account the limits of the rdma device.
>>> So adjust it once we discover the device fastreg max depth limit.  Also
>>> adjust the max_sectors based on the resulting sg tablesize.
>>
>> Huh. How does this relate to the max_page_list_len argument:
>>
>>   struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
>>
>> Shouldn't max_fast_reg_page_list_len be checked during the above?
>>
>> Ie does this still make sense:
>>
>> drivers/infiniband/ulp/iser/iser_verbs.c:       desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE + 1);
>>
>> ?
>>
>> The only ULP that checks this is SRP, so basically, all our ULPs are
>> probably quietly broken? cxgb3 has a limit of 10 (!?!?!!)
>>
>
> Yea seems like some drivers need to enforce this in ib_alloc_fast_reg_mr() as well as ib_alloc_fast_reg_page_list(), and ULPs need
> to not exceed the device max.
>
> I will fix iser to limit the mr and page_list allocation based on the device max.

Steve, I have a patch that addresses this in the pipe.
The patch is support for up to 8MB transfer size for 4.3 (hopefully).
So no need for you to tackle this.
