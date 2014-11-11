Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f179.google.com ([209.85.214.179]:55323 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbaKKUaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 15:30:09 -0500
MIME-Version: 1.0
In-Reply-To: <54625A33.6000506@dev.mellanox.co.il>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
	<20141109011501.8806.23478.stgit@manet.1015granger.net>
	<54621D8D.7050508@dev.mellanox.co.il>
	<1D304B95-D745-42B2-9324-143A5002FB35@gmail.com>
	<54625A33.6000506@dev.mellanox.co.il>
Date: Tue, 11 Nov 2014 22:30:08 +0200
Message-ID: <CAJ3xEMjE3AFEVAYwL-awgmFVACuDHmTPvh8qXeGXh+LkeCnxtg@mail.gmail.com>
Subject: Re: [PATCH v2 07/10] xprtrdma: Display async errors
From: Or Gerlitz <gerlitz.or@gmail.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Chuck Lever <chucklever@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 8:49 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> On 11/11/2014 6:52 PM, Chuck Lever wrote:
>>
>>
>>> On Nov 11, 2014, at 8:30 AM, Sagi Grimberg <sagig@dev.mellanox.co.il>
>>> wrote:
>>>
>>>> On 11/9/2014 3:15 AM, Chuck Lever wrote:
>>>> An async error upcall is a hard error, and should be reported in
>>>> the system log.
>>>>
>>>
>>> Could be useful to others... Any chance you put this in ib_core for all
>>> of us?
>>
>>
>> Eventually. We certainly wouldn't want copies of this array of strings
>> to appear many times in the kernel. That would be a waste of space.
>>
>> I have a similar patch that adds an array for CQ status codes, and
>> xprtrdma has a string array already for connection status. Are those
>> also interesting?
>>
>
> Yep, also RDMA_CM events. Would certainly help people avoid source
> code navigation to understand what is going on...

Oh yes, Chuck, good if you can pick  this up, AFAIRemeber most of the
strings are already in the RDS code (net/rds) - please re-factor them
from there into some IB core helpers, thanks alot!!
