Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:39301 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbaFEPAy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 11:00:54 -0400
Message-ID: <5390862B.3050007@opengridcomputing.com>
Date: Thu, 05 Jun 2014 10:00:59 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: "'Bart Van Assche'" <bvanassche@acm.org>, bfields@fieldses.org
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH] svcrdma: Fence LOCAL_INV work requests
References: <20140602171433.31076.5634.stgit@build.ogc.int> <53901ADB.9020405@acm.org> <002901cf80c5$d0b577e0$722067a0$@opengridcomputing.com>
In-Reply-To: <002901cf80c5$d0b577e0$722067a0$@opengridcomputing.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/5/2014 8:55 AM, Steve Wise wrote
>> -----Original Message-----
>> From: Bart Van Assche [mailto:bvanassche@acm.org]
>> Sent: Thursday, June 05, 2014 2:23 AM
>> To: Steve Wise; bfields@fieldses.org
>> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org; tom@opengridcomputing.com
>> Subject: Re: [PATCH] svcrdma: Fence LOCAL_INV work requests
>>
>> On 06/02/14 19:14, Steve Wise wrote:
>>> Fencing forces the invalidate to only happen after all subsequent send
>>> work requests have been completed.
>> Shouldn't that read "prior" instead of "subsequent" ?
>>
> Yes.
>   

I posted V2 of the patch to fix the comment.

Thanks,

Steve.
