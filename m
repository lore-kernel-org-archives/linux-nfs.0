Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:47542 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138Ab0KRF1C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 00:27:02 -0500
Message-ID: <4CE4B923.6030102@opengridcomputing.com>
Date: Wed, 17 Nov 2010 23:26:59 -0600
From: Tom Tucker <tom@opengridcomputing.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
CC: Tom Tucker <tom@ogc.us>, bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 1/2] svcrdma: Change DMA mapping logic to avoid the page_address
 kernel API
References: <20101012203332.22154.37230.stgit@build.ogc.int>	<20101012203351.22154.42528.stgit@build.ogc.int> <AANLkTik0LkdD-Gm0FAZ-KDS605ZGTewbfejC3GEOK=2x@mail.gmail.com>
In-Reply-To: <AANLkTik0LkdD-Gm0FAZ-KDS605ZGTewbfejC3GEOK=2x@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/16/10 1:39 PM, Or Gerlitz wrote:
>   Tom Tucker<tom@ogc.us>  wrote:
>
>> This patch changes the bus mapping logic to avoid page_address() where necessary
> Hi Tom,
>
> Does "when necessary" comes to say that invocations of page_address
> which remained in the code after this patch was applied are safe and
> no kmap call is needed?

That's the premise. Please let me know if something looks suspicious.

Thanks,
Tom

> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

