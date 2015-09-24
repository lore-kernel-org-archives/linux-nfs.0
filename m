Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35396 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989AbbIXHjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 03:39:43 -0400
Received: by wicge5 with SMTP id ge5so239436514wic.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 00:39:42 -0700 (PDT)
Subject: Re: [PATCH v1 03/24] IB/mlx5: Support the new memory registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-4-git-send-email-sagig@mellanox.com>
 <5601C7A4.5030302@sandisk.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5603A8BB.9080706@dev.mellanox.co.il>
Date: Thu, 24 Sep 2015 10:39:39 +0300
MIME-Version: 1.0
In-Reply-To: <5601C7A4.5030302@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/23/2015 12:27 AM, Bart Van Assche wrote:
> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>> +static int
>> +mlx5_alloc_priv_descs(struct ib_device *device,
>> +              struct mlx5_ib_mr *mr,
>> +              int ndescs,
>> +              int desc_size)
>> +{
>> +    int size = ndescs * desc_size;
>> +
>> +    mr->descs = dma_alloc_coherent(device->dma_device, size,
>> +                       &mr->desc_map, GFP_KERNEL);
>> +    if (!mr->descs)
>> +        return -ENOMEM;
>> +
>> +    return 0;
>> +}
>
> Would it be possible to clarify the choice for coherent memory ?

No specific reason. I was just copying  alloc_fastreg_page_list logic.

> Would performance be better if non-coherent memory would be used and if memory
> would be synced after initialization of desc_map has finished ?

It probably would I assume. I'll change that.

Thanks!
