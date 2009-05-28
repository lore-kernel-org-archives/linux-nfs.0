From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2.6.30] svcrdma: dma unmap the correct length for the
	RPCRDMA header page.
Date: Thu, 28 May 2009 14:19:49 -0400
Message-ID: <20090528181949.GB13860@fieldses.org>
References: <20090514213428.19282.27658.stgit@build.ogc.int> <4A1C53F4.1080701@opengridcomputing.com> <20090526220050.GO1432@fieldses.org> <4A1C688B.8080307@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38936 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbZE1STs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 14:19:48 -0400
In-Reply-To: <4A1C688B.8080307@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 26, 2009 at 05:09:15PM -0500, Steve Wise wrote:
> J. Bruce Fields wrote:
>> On Tue, May 26, 2009 at 03:41:24PM -0500, Steve Wise wrote:
>>   
>>> Hey Bruce,
>>>
>>> Do you think this can make 2.6.30?
>>>     
>>
>> I was going to save it for 2.6.31; vague mental scorecard:
>>
>> 	- 2.6.30 is close to release
>> 	- I think of rdma (correctly or not?) as a little young, so
>> 	  don't prioritize bug-fixes to it quite as highly
>> 	- A resource leak (even as large as this) isn't the worst
>> 	  category of bug.
>>
>> But I may be wrong.
>>
>>   
> Ok.
>
> As a data point: this bug will exhaust the iommu address space on a IBM  
> Power system within 10 cthon iterations...

OK.  I may get this in for 2.6.30.

--b.
