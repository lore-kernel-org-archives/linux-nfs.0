Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:58876 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbaKKStc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 13:49:32 -0500
Received: by mail-wi0-f178.google.com with SMTP id bs8so2553690wib.11
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 10:49:31 -0800 (PST)
Message-ID: <54625A33.6000506@dev.mellanox.co.il>
Date: Tue, 11 Nov 2014 20:49:23 +0200
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chucklever@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 07/10] xprtrdma: Display async errors
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011501.8806.23478.stgit@manet.1015granger.net> <54621D8D.7050508@dev.mellanox.co.il> <1D304B95-D745-42B2-9324-143A5002FB35@gmail.com>
In-Reply-To: <1D304B95-D745-42B2-9324-143A5002FB35@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/11/2014 6:52 PM, Chuck Lever wrote:
>
>> On Nov 11, 2014, at 8:30 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>>
>>> On 11/9/2014 3:15 AM, Chuck Lever wrote:
>>> An async error upcall is a hard error, and should be reported in
>>> the system log.
>>>
>>
>> Could be useful to others... Any chance you put this in ib_core for all
>> of us?
>
> Eventually. We certainly wouldn't want copies of this array of strings
> to appear many times in the kernel. That would be a waste of space.
>
> I have a similar patch that adds an array for CQ status codes, and
> xprtrdma has a string array already for connection status. Are those
> also interesting?
>

Yep, also RDMA_CM events. Would certainly help people avoid source
code navigation to understand what is going on...
