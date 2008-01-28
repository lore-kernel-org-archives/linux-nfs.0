From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in read_buf()
Date: Mon, 28 Jan 2008 16:46:06 -0500
Message-ID: <F228287C-EE5C-4274-9DBE-35F87D7DE030@oracle.com>
References: <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com> <20080128201507.GG16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14616 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbYA1Vqf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 16:46:35 -0500
In-Reply-To: <20080128201507.GG16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Jan 28, 2008, at 3:15 PM, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 01:00:47PM -0500, Chuck Lever wrote:
>> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>>> The length "nbytes" passed into read_buf should never be  
>>> negative, but
>>> we check only for too-large values of "nbytes", not for too-small
>>> values.  Make nbytes unsigned, so it's clear that the former  
>>> tests are
>>> sufficient.  (Despite this read_buf() currently correctly returns an
>>> xdr
>>> error in the case of a negative length, thanks to an unsigned
>>> comparison with size_of() and bounds-checking in kmalloc().  This
>>> seems
>>> very fragile, though.)
>>>
>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> ---
>>>  fs/nfsd/nfs4xdr.c |    7 ++++++-
>>>  1 files changed, 6 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>> index 5733394..25c7ae2 100644
>>> --- a/fs/nfsd/nfs4xdr.c
>>> +++ b/fs/nfsd/nfs4xdr.c
>>> @@ -148,7 +148,7 @@ xdr_error:					\
>>>  	}					\
>>>  } while (0)
>>>
>>> -static __be32 *read_buf(struct nfsd4_compoundargs *argp, int  
>>> nbytes)
>>> +static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32  
>>> nbytes)
>>>  {
>>>  	/* We want more bytes than seem to be available.
>>>  	 * Maybe we need a new page, maybe we have just run out
>>
>> Changing nbytes to an unsigned introduces a mixed-sign comparison:
>>
>>         int avail = (char*)argp->end - (char*)argp->p;
>>         __be32 *p;
>>         if (avail + argp->pagelen < nbytes)  <<<<<<
>>
>> "avail" and "argp->pagelen" are signed ints.
>
> OK.  Is the result incorrect?

Whether it is or it isn't, I'm not comfortable with introducing a  
mixed-sign comparison for no reason.  It's not a correctness issue,  
it's a maintainability issue.

> (Any objections to just making "avail" unsigned?)

If we can guarantee that argp->end is always larger than argp->p...  
then there's no need for "avail" to be a signed int.  However:

>>                 return NULL;
>>         if (avail + PAGE_SIZE < nbytes) /* need more than a  
>> page !! */
>>                 return NULL;
>>
>> PAGE_SIZE is unsigned long (defined as "1UL << PAGE_SHIFT"), so  
>> changing
>> nbytes may have additional unintended consequences.

...and since that wasn't noticed or addressed by this patch, it  
suggests that there may be other issues that the patch author didn't  
address and that reviewers didn't catch.

>> We need careful review of everywhere argp->pagelen is used throughout
>> this file.  But I think just this simple fix is inadequate.
>
> Sure, such a review would be welcomed.
>
> The patch still seems an obvious improvement to me (and you don't seem
> to be arguing the contrary?) so I'm inclined to apply it pending that
> further work.

I agree that nbytes should be unsigned, but I'm arguing that you will  
need more than just changing nbytes to a u32 to produce a truly clean  
fix; therefore, I'm suggesting you should hold off on this until we  
have a complete fix that is a result of a thorough review of that code.

My experience with the NFSv4 XDR routines is that there are scores of  
these little nuisances waiting to bite us (and a brief review of how  
argp->pagelen is used in nfs4xdr.c vindicates this experience).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
