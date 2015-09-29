Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0070.outbound.protection.outlook.com ([157.56.112.70]:39168
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755304AbbI2G7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 02:59:03 -0400
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com> <5603A841.70509@dev.mellanox.co.il>
 <5609A9D0.8030607@sandisk.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@mellanox.com>
Message-ID: <560A32DC.4040808@mellanox.com>
Date: Tue, 29 Sep 2015 09:42:36 +0300
MIME-Version: 1.0
In-Reply-To: <5609A9D0.8030607@sandisk.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/28/2015 11:57 PM, Bart Van Assche wrote:
> On 09/24/2015 12:37 AM, Sagi Grimberg wrote:
>> On 9/23/2015 12:21 AM, Bart Van Assche wrote:
>>> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>>>> +            } else if (last_page_off + dma_len < mr->page_size) {
>>>> +                /* chunk this fragment with the last */
>>>> +                last_end_dma_addr += dma_len;
>>>> +                last_page_off += dma_len;
>>>> +                mr->length += dma_len;
>>>> +                continue;
>>>
>>> Shouldn't this code update last_page_addr ?
>>
>> Actually I think it doesn't since it is only relevant for the else
>> statement where we are passing the page_size boundary.
>
> Hello Sagi,
>
> Suppose that the following sg-list is passed to this function as {
> offset, length } pairs and that this list has not been coalesced by the
> DMA mapping code: [ { 0, page_size / 4 }, { page_size / 4, page_size / 4
> }, { 2 * page_size / 4, page_size / 2 } ]. I think the algorithm in
> patch 01/24 will map the above sample sg-list onto two pages. Shouldn't
> that sg-list be mapped onto one page instead ?

It seems to... In order to get that correct we'd need to change the
condition to (last_page_off + dma_len <= mr->page_size)

I'll change for v2.

Thanks.

Sagi.
