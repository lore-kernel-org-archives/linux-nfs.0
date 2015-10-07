Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn1bon0087.outbound.protection.outlook.com ([157.56.111.87]:31040
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751357AbbJGQBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 12:01:25 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <560AE099.2080004@sandisk.com> <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com> <560C42CE.6090000@sandisk.com>
 <560CDDBC.8000400@dev.mellanox.co.il> <560D730C.9000302@sandisk.com>
 <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com> <56138854.4040209@dev.mellanox.co.il>
 <561417B9.2080505@sandisk.com> <5614BECF.9030907@dev.mellanox.co.il>
CC: Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <56153E41.10607@sandisk.com>
Date: Wed, 7 Oct 2015 08:46:09 -0700
MIME-Version: 1.0
In-Reply-To: <5614BECF.9030907@dev.mellanox.co.il>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/06/2015 11:42 PM, Sagi Grimberg wrote:
> On 10/6/2015 9:49 PM, Bart Van Assche wrote:
>> On 10/06/2015 01:37 AM, Sagi Grimberg wrote:
>>> I see now the error you are referring to.
>>>
>>> The issue is that the device requires the MR page array to have
>>> an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
>>> page array allocation to be non-coherent I didn't take care of
>>> alignment.
>>>
>>> Taking care of this alignment may result in a higher order allocation
>>> as we'd need to add (alignment - 1) to the allocation size.
>>>
>>> e.g. a 512 pages on mlx4 will become:
>>> 512 * 8 + 0x40 - 1 = 4159
>>>
>>> I'm leaning towards this approach. Any preference?
>>>
>>> I think this patch should take care of mlx4:
>>> [ ... ]
>>
>> Hello Sagi,
>>
>> Thanks for the patch. But since the patch included in the previous
>> e-mail mapped a memory range that could be outside the bounds of the
>> allocated memory I have been testing the patch below:
>
> Thanks! I correct the patches.
>
> Can I take it as your Tested-by on srp?

Sure :-) But please keep in mind that I currently only have access to 
ConnectX-3 HCA's for testing RDMA software and not to any other RDMA HCA 
model.

Bart.
