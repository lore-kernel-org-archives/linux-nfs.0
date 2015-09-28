Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0060.outbound.protection.outlook.com ([65.55.169.60]:18512
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750895AbbI1U57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 16:57:59 -0400
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com> <5603A841.70509@dev.mellanox.co.il>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5609A9D0.8030607@sandisk.com>
Date: Mon, 28 Sep 2015 13:57:52 -0700
MIME-Version: 1.0
In-Reply-To: <5603A841.70509@dev.mellanox.co.il>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/24/2015 12:37 AM, Sagi Grimberg wrote:
> On 9/23/2015 12:21 AM, Bart Van Assche wrote:
>> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>>> +            } else if (last_page_off + dma_len < mr->page_size) {
>>> +                /* chunk this fragment with the last */
>>> +                last_end_dma_addr += dma_len;
>>> +                last_page_off += dma_len;
>>> +                mr->length += dma_len;
>>> +                continue;
>>
>> Shouldn't this code update last_page_addr ?
>
> Actually I think it doesn't since it is only relevant for the else
> statement where we are passing the page_size boundary.

Hello Sagi,

Suppose that the following sg-list is passed to this function as { 
offset, length } pairs and that this list has not been coalesced by the 
DMA mapping code: [ { 0, page_size / 4 }, { page_size / 4, page_size / 4 
}, { 2 * page_size / 4, page_size / 2 } ]. I think the algorithm in 
patch 01/24 will map the above sample sg-list onto two pages. Shouldn't 
that sg-list be mapped onto one page instead ?

Thanks,

Bart.
