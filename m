Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27757 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbBFREl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2015 12:04:41 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <067E5610-290A-4AA7-9A19-F2EF9AB4163E@oracle.com>
Date: Fri, 6 Feb 2015 12:04:13 -0500
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8B871365-A241-4BA8-BD95-0946AEA55E38@oracle.com>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com> <20150205141325.GC4522@infradead.org> <54D394EC.9030902@Netapp.com> <20150205162326.GA18977@infradead.org> <54D39DC2.9060808@Netapp.com> <20150206115456.GA28915@infradead.org> <20150206160848.GA29783@fieldses.org> <067E5610-290A-4AA7-9A19-F2EF9AB4163E@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 6, 2015, at 11:46 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 6, 2015, at 11:08 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Fri, Feb 06, 2015 at 03:54:56AM -0800, Christoph Hellwig wrote:
>>> On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
>>>>> The problem is that the typical case of all data won't use splice
>>>>> every with your patches as the 4.2 client will always send a READ_PLUS.
>>>>> 
>>>>> So we'll have to find a way to use it where it helps.  While we might be
>>>>> able to add some hacks to only use splice for the first segment I guess
>>>>> we just need to make the splice support generic enough in the long run.
>>>>> 
>>>> 
>>>> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
>>> 
>>> You could also elect to never return more than one data segment as a
>>> start:
>>> 
>>>  In all situations, the
>>>  server may choose to return fewer bytes than specified by the client.
>>>  The client needs to check for this condition and handle the
>>>  condition appropriately.
>> 
>> Yeah, I think that was more-or-less what Anna's first attempt did and I
>> said "what if that means more round trips"?  The client can't anticipate
>> the short reads so it can't make up for this with parallelism.
>> 
>>> But doing any of these for a call that's really just an optimization
>>> soudns odd.  I'd really like to see an evaluation of the READ_PLUS
>>> impact on various workloads before offering it.
>> 
>> Yes, unfortunately I don't see a way to make this just an obvious win.
> 
> I don’t think a “win” is necessary. It simply needs to be no worse than
> READ for current use cases.
> 
> READ_PLUS should be a win for the particular use cases it was
> designed for (large sparsely-populated datasets). Without a
> demonstrated benefit I think there’s no point in keeping it.
> 
>> (Is there any way we could make it so with better protocol?  Maybe RDMA
>> could help get the alignment right in multiple-segment cases?  But then
>> I think there needs to be some sort of language about RDMA, or else
>> we're stuck with:
>> 
>> 	https://tools.ietf.org/html/rfc5667#section-5
>> 
>> which I think forces us to return READ_PLUS data inline, another
>> possible READ_PLUS regression.)

Btw, if I understand this correctly:

Without a spec update, a large NFS READ_PLUS reply would be returned
in a reply list, which is moved via RDMA WRITE, just like READ
replies.

The difference is NFS READ payload is placed directly into the
client’s page cache by the adapter. With a reply list, the client
transport would need to copy the returned data into the page cache.
And a large reply buffer would be needed.

So, slower, yes. But not inline.

> NFSv4.2 currently does not have a binding to RPC/RDMA.

Right, this means a spec update is needed. I agree with you, and
it’s on our list.

> It’s hard to
> say at this point what a READ_PLUS on RPC/RDMA might look like.
> 
> RDMA clearly provides no advantage for moving a pattern that a
> client must re-inflate into data itself. I can guess that only the
> CONTENT_DATA case is interesting for RDMA bulk transfers.
> 
> But don’t forget that NFSv4.1 and later don’t yet work over RDMA,
> thanks to missing support for bi-directional RPC/RDMA. I wouldn’t
> worry about special cases for it at this point.
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



