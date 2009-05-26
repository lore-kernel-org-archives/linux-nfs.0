From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] svcrdma: dma unmap the correct length for the
 RPCRDMA header page.
Date: Tue, 26 May 2009 17:09:15 -0500
Message-ID: <4A1C688B.8080307@opengridcomputing.com>
References: <20090514213428.19282.27658.stgit@build.ogc.int> <4A1C53F4.1080701@opengridcomputing.com> <20090526220050.GO1432@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40298 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754709AbZEZWIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2009 18:08:12 -0400
In-Reply-To: <20090526220050.GO1432@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, May 26, 2009 at 03:41:24PM -0500, Steve Wise wrote:
>   
>> Hey Bruce,
>>
>> Do you think this can make 2.6.30?
>>     
>
> I was going to save it for 2.6.31; vague mental scorecard:
>
> 	- 2.6.30 is close to release
> 	- I think of rdma (correctly or not?) as a little young, so
> 	  don't prioritize bug-fixes to it quite as highly
> 	- A resource leak (even as large as this) isn't the worst
> 	  category of bug.
>
> But I may be wrong.
>
>   
Ok.

As a data point: this bug will exhaust the iommu address space on a IBM 
Power system within 10 cthon iterations...

Steve.

