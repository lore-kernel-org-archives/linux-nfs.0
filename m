Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36043 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139AbbGZJ6X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 05:58:23 -0400
Received: by wicgb10 with SMTP id gb10so75917829wic.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 02:58:22 -0700 (PDT)
Subject: Re: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to
 device fastreg max depth
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, sagig@mellanox.com,
        Steve Wise <swise@opengridcomputing.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161820.25617.63886.stgit@build2.ogc.int>
 <20150724164123.GA25480@obsidianresearch.com>
 <00ca01d0c640$2f813d70$8e83b850$@opengridcomputing.com>
 <20150724191402.GB26225@obsidianresearch.com>
Cc: dledford@redhat.com, infinipath@intel.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B4AF41.5070503@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 12:58:26 +0300
MIME-Version: 1.0
In-Reply-To: <20150724191402.GB26225@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/24/2015 10:14 PM, Jason Gunthorpe wrote:
> On Fri, Jul 24, 2015 at 01:40:17PM -0500, Steve Wise wrote:
>>> Huh. How does this relate to the max_page_list_len argument:
>>>
>>>   struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
>>>
>>> Shouldn't max_fast_reg_page_list_len be checked during the above?
>>>
>>> Ie does this still make sense:
>>>
>>> drivers/infiniband/ulp/iser/iser_verbs.c:       desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE + 1);
>>>
>>> ?
>>>
>>> The only ULP that checks this is SRP, so basically, all our ULPs are
>>> probably quietly broken? cxgb3 has a limit of 10 (!?!?!!)
>>>
>>
>> Yea seems like some drivers need to enforce this in ib_alloc_fast_reg_mr() as well as ib_alloc_fast_reg_page_list(), and ULPs need
>> to not exceed the device max.
>
> Great, Sagi, can you incorporate that in your series so that
> ib_alloc_mr's max_entires is checked against
> max_fast_reg_page_list_len and EINVAL's if it is too great?

Yes. I'll take care of that.
