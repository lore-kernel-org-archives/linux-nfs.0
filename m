Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:44667 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933141Ab1JaPJu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 11:09:50 -0400
Subject: Re: nfsd4_is_junction
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1319931380.11288.3.camel@lade.trondhjem.org>
Date: Mon, 31 Oct 2011 11:09:25 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Message-Id: <30D3D54C-7241-426B-B2AF-0D47471D2209@oracle.com>
References: <20111029101649.GA12345@infradead.org> <929DFFCE-F92B-4EF6-8C9E-E807AB4FFA9C@oracle.com> <20111029175548.GB12122@fieldses.org> <7A873A96-ED05-4904-8470-E169B233E951@oracle.com> <20111029180900.GD12122@fieldses.org> <5E06F04E-9F85-4358-BCC5-F8A118D2AD5E@oracle.com> <1319931380.11288.3.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 7:36 PM, Trond Myklebust wrote:

> On Sat, 2011-10-29 at 14:38 -0400, Chuck Lever wrote: 
>> On Oct 29, 2011, at 2:09 PM, J. Bruce Fields wrote:
>> 
>>> On Sat, Oct 29, 2011 at 01:58:02PM -0400, Chuck Lever wrote:
>>>> 
>>>> On Oct 29, 2011, at 1:55 PM, J. Bruce Fields wrote:
>>>> 
>>>>> On Sat, Oct 29, 2011 at 01:47:55PM -0400, Chuck Lever wrote:
>>>>>> 
>>>>>> On Oct 29, 2011, at 6:16 AM, Christoph Hellwig wrote:
>>>>>> 
>>>>>>> This function should probably grow a check for S_NOSEC instead of
>>>>>>> hitting the filesystems with an xattr read for every lookup.
>>>>>> 
>>>>>> It doesn't perform the xattr read on _every_ lookup, but only when the object has a special set of permission bits.
>>>>>> 
>>>>>> But actually, it probably doesn't need that 'type" attribute check at all.  It should delegate that check to mountd.  I assume many of those upcalls would hit in the export cache anyway?
>>>>> 
>>>>> You're suggesting doing an upcall on every path that passes the mode-bit
>>>>> checks?
>>>>> 
>>>>> You'd end up populating the export cache with every path that passes
>>>>> the mode-bit checks.  I don't think that's a good idea.
>>>> 
>>>> You just finished telling us that the mode bit checks would prevent doing an attribute read too often.  Again, how often do we think there will be directories with no execute bits set and the sticky bit set?  I think that's going to be exceptionally rare.
>>> 
>>> Yeah, probably so, but if there's a pathological case where we're wrong
>>> then I think excessive xattr reads will be less annoying than excessive
>>> upcalls and export cache entries.
>> 
>> If we find a pathological case, we should fix it.
>> 
>> Basically I'd like the kernel check to be as simple as possible not only because it should be fast, but also so that user space can implement junctions flexibly, especially in the early days when we are still unsure of how these need to work.  I think we are better off being flexible to start, and restricting only if we have to.
>> 
>> Or to put it another way, user space, and not the kernel, should arbitrate policy.  The semantics of junctions is a policy, at least for now.
>> 
>> And lastly, right now, I expect that nearly 100% of the time the mode bit test and the xattr test will either both succeed or both fail.  That suggests one of them is redundant.
> 
> They are almost redundant: If you do the xattr test, then you don't need
> to do the mode bit test. However if you do the mode bit test, then you
> still need to do the xattr test.
> 
> Basically, the mode bit test is supposed to be the speedup that avoids
> the need for another S_NOSEC-style bit...

OK, just to close this out:  I'm hearing that folks are not interested in getting rid of the "trusted.junction.type" extended attribute.  I don't agree, but I will accede and continue to support its use for junctions that NFSD has to pay attention to.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




