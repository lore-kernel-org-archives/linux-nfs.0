Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45944 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751906Ab0JTQFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 12:05:07 -0400
Message-ID: <4CBF1331.70107@opengridcomputing.com>
Date: Wed, 20 Oct 2010 11:05:05 -0500
From: Tom Tucker <tom@opengridcomputing.com>
To: Tejun Heo <tj@kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Tom Tucker <tom@ogc.us>
Subject: Re: [PATCH linux-2.6.36-rc7] sunrpc/xprtrdma: clean up workqueue
 usage
References: <4CB87807.7050108@kernel.org> <20101015171132.GA18869@fieldses.org> <4CB89393.6000207@opengridcomputing.com> <4CB8A745.5020206@kernel.org>
In-Reply-To: <4CB8A745.5020206@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 10/15/10 2:11 PM, Tejun Heo wrote:
> On 10/15/2010 07:46 PM, Tom Tucker wrote:
>>   On 10/15/10 12:11 PM, J. Bruce Fields wrote:
>>> Tom, could you take a look?
>>>
>> This looks reasonable to me.
>>
>> My bet is that it wasn't tested though due to hardware
>> availability. I'll test it this weekend and let you know how it
>> goes.
> Yeap, only compile tested.  Testing would be much appreciated.
>
Tejun,

I've tested this now with iozone etc... works like a charm ;-)

Tom

> Thanks.
>

