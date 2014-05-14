Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:61020 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbaENOkE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 May 2014 10:40:04 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <53737D15.6020902@opengridcomputing.com>
Date: Wed, 14 May 2014 10:39:47 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Tom Tucker <tom@opengridcomputing.com>
Message-Id: <2AEECADA-4A40-4BF2-866E-7F178D016DDE@gmail.com>
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174632.18208.28160.stgit@build.ogc.int> <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com> <00f901cf6eeb$2ff1f630$8fd5e290$@opengridcomputing.com> <3DAF95F3-22D5-4FC5-8C98-5A440E54DC2F@gmail.com> <53737D15.6020902@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 14, 2014, at 10:26 AM, Steve Wise <swise@opengridcomputing.com> wrote:

> On 5/13/2014 4:44 PM, Chuck Lever wrote:
>> 
>>> I'm not sure what "segment count” you are talking about?
>> AFAICT a chunk is a list of segments. Thus one chunk can reference
>> many pages, one per segment.
> 
> Ok yes.  rdma_read_chunk_frmr()/rdma_read_chunk_lcl() walk the segments creating rdma read work requests to pull the data for this chunk.
> 
>> If you print ch_count, it is 2 for NFS WRITEs from a Linux client,
>> no matter how large the write payload is. Therefore I think the check
>> as it is written is not particularly useful.
> 
> Why are there 2?

The first chunk lists the pages the server is to read, and the second
chunk has the zero pad for XDR alignment.

If pad optimization is enabled on the client, there is just 1 chunk in
the RPC’s Read list.

> 
>> The returned ch_count here is not used beyond that check, after the
>> refactoring patch is applied. The returned byte_count includes all
>> chunks in the passed-in chunk list, whereas I think it should count
>> only the first chunk in the list.
> 
> So I'll investigate this more with the goal of only grabbing the first chunk.

[ . . . snipped . . . ]

>>>> 
>>>> What I'm asking is:
>>>> 
>>>> Do you agree the server should be changed to comply with section 4 of 5667?
>>>> 
>>> I think it is complying and you are misinterpreting.  But I could be misinterpreting it
>>> too :)
>>> 
>>> But we should fix the pad thing.
>> That may be enough to support a client that does not send the
>> pad bytes in a separate chunk. However, I wonder how such a
>> server would behave with the current client.
>> 
>> True, this isn’t a regression, per se. The server is already
>> behaving incorrectly without the refactoring patch.
>> 
>> However, Tom’s refactoring rewrites all this logic anyway, and
>> it wouldn’t be much of a stretch to make the server comply with
>> RFC 5667, at this point.
> 
> Can we defer this until the refactor patch is in, then I'll work on a new patch for the pad stuff.

Yes, we can defer it.

A bug has been filed to track this issue:

 https://bugzilla.linux-nfs.org/show_bug.cgi?id=246

--
Chuck Lever
chucklever@gmail.com



