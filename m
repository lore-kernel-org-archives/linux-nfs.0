Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36373 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbbJGPs7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 11:48:59 -0400
Received: by wicgb1 with SMTP id gb1so217590105wic.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 08:48:58 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com> <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com> <560C42CE.6090000@sandisk.com>
 <560CDDBC.8000400@dev.mellanox.co.il> <560D730C.9000302@sandisk.com>
 <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com> <56138854.4040209@dev.mellanox.co.il>
 <561417B9.2080505@sandisk.com> <5614BECF.9030907@dev.mellanox.co.il>
 <56153E41.10607@sandisk.com>
Cc: Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56153EE6.80703@dev.mellanox.co.il>
Date: Wed, 7 Oct 2015 18:48:54 +0300
MIME-Version: 1.0
In-Reply-To: <56153E41.10607@sandisk.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/7/2015 6:46 PM, Bart Van Assche wrote:
> On 10/06/2015 11:42 PM, Sagi Grimberg wrote:
>> On 10/6/2015 9:49 PM, Bart Van Assche wrote:
>>> On 10/06/2015 01:37 AM, Sagi Grimberg wrote:
>>>> I see now the error you are referring to.
>>>>
>>>> The issue is that the device requires the MR page array to have
>>>> an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
>>>> page array allocation to be non-coherent I didn't take care of
>>>> alignment.
>>>>
>>>> Taking care of this alignment may result in a higher order allocation
>>>> as we'd need to add (alignment - 1) to the allocation size.
>>>>
>>>> e.g. a 512 pages on mlx4 will become:
>>>> 512 * 8 + 0x40 - 1 = 4159
>>>>
>>>> I'm leaning towards this approach. Any preference?
>>>>
>>>> I think this patch should take care of mlx4:
>>>> [ ... ]
>>>
>>> Hello Sagi,
>>>
>>> Thanks for the patch. But since the patch included in the previous
>>> e-mail mapped a memory range that could be outside the bounds of the
>>> allocated memory I have been testing the patch below:
>>
>> Thanks! I correct the patches.
>>
>> Can I take it as your Tested-by on srp?
>
> Sure :-) But please keep in mind that I currently only have access to
> ConnectX-3 HCA's for testing RDMA software and not to any other RDMA HCA
> model.

Thanks Bart. For what its worth, I've tested srp (and iser + nfs) on
both CX3 and CX4 with your config file.

Cheers,
Sagi.
