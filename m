Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37004 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbbIXHhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 03:37:41 -0400
Received: by wicfx3 with SMTP id fx3so100463215wic.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 00:37:40 -0700 (PDT)
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5603A841.70509@dev.mellanox.co.il>
Date: Thu, 24 Sep 2015 10:37:37 +0300
MIME-Version: 1.0
In-Reply-To: <5601C65F.8060403@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/23/2015 12:21 AM, Bart Van Assche wrote:
> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>> The new fast registration  verg ib_map_mr_sg receives a scatterlist
>
>                               ^ verb ?

Will fix. Thanks.

>
>> +/**
>> + * ib_map_mr_sg() - Map a memory region with the largest prefix of
>> + *     a dma mapped SG list
>
> This description could be made more clear. How about the following:
>
> Register the largest possible prefix of a DMA-mapped SG-list
>
>> +            } else if (last_page_off + dma_len < mr->page_size) {
>> +                /* chunk this fragment with the last */
>> +                last_end_dma_addr += dma_len;
>> +                last_page_off += dma_len;
>> +                mr->length += dma_len;
>> +                continue;
>
> Shouldn't this code update last_page_addr ?

Actually I think it doesn't since it is only relevant for the else
statement where we are passing the page_size boundary.
