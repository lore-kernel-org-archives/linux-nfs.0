Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f178.google.com ([74.125.82.178]:41243 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbAMKHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 05:07:12 -0500
Received: by mail-we0-f178.google.com with SMTP id p10so1887137wes.9
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 02:07:10 -0800 (PST)
Message-ID: <54B4EE4B.9050500@dev.mellanox.co.il>
Date: Tue, 13 Jan 2015 12:07:07 +0200
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 05/10] svcrdma: Find rmsgp more reliably
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109192237.4901.92644.stgit@klimt.1015granger.net> <54B2B4E0.5060901@dev.mellanox.co.il> <3C09A798-2BA9-46A1-AA60-122C2274974C@oracle.com>
In-Reply-To: <3C09A798-2BA9-46A1-AA60-122C2274974C@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/12/2015 2:30 AM, Chuck Lever wrote:
> Hi Sagi-
>
> Thanks for the review.
>
> On Jan 11, 2015, at 12:37 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>
>> On 1/9/2015 9:22 PM, Chuck Lever wrote:
>>> xdr_start() can return the wrong rmsgp address if an assumption
>>> about how the xdr_buf was constructed changes.  When it gets it
>>> wrong, the client receives a reply that has gibberish in the
>>> RPC/RDMA header, preventing it from matching a waiting RPC request.
>>>
>>> Instead, make (and document) just one assumption: that the RDMA
>>> header for the client's RPC call is at the start of the first page
>>> in rq_pages.
>>
>> Would it make more sense to add another pointer assigned at req
>> initialization (maybe in the RDMA request context) instead of hard
>> coding this assumption? I may be completely wrong here though...
>
> I considered this. I couldn’t find an appropriate place to add
> such a pointer.
>
> I think that’s why xdr_start() was there in the first place: there
> is no convenient place to save a pointer to the request’s RDMA
> header.
>
> Bruce might have other thoughts about this.

Yep, I didn't find any nice place to put that also, thought you might
have an idea...

Sagi.
