From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in
	read_buf()
Date: Mon, 28 Jan 2008 15:15:07 -0500
Message-ID: <20080128201507.GG16785@fieldses.org>
References: <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYA1UPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 15:15:08 -0500
In-Reply-To: <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 01:00:47PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>> The length "nbytes" passed into read_buf should never be negative, but
>> we check only for too-large values of "nbytes", not for too-small
>> values.  Make nbytes unsigned, so it's clear that the former tests are
>> sufficient.  (Despite this read_buf() currently correctly returns an 
>> xdr
>> error in the case of a negative length, thanks to an unsigned
>> comparison with size_of() and bounds-checking in kmalloc().  This  
>> seems
>> very fragile, though.)
>>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/nfsd/nfs4xdr.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 5733394..25c7ae2 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -148,7 +148,7 @@ xdr_error:					\
>>  	}					\
>>  } while (0)
>>
>> -static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
>> +static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>>  {
>>  	/* We want more bytes than seem to be available.
>>  	 * Maybe we need a new page, maybe we have just run out
>
> Changing nbytes to an unsigned introduces a mixed-sign comparison:
>
>         int avail = (char*)argp->end - (char*)argp->p;
>         __be32 *p;
>         if (avail + argp->pagelen < nbytes)  <<<<<<
>
> "avail" and "argp->pagelen" are signed ints.

OK.  Is the result incorrect?

(Any objections to just making "avail" unsigned?)

>
>                 return NULL;
>         if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
>                 return NULL;
>
> PAGE_SIZE is unsigned long (defined as "1UL << PAGE_SHIFT"), so changing 
> nbytes may have additional unintended consequences.
>
> We need careful review of everywhere argp->pagelen is used throughout  
> this file.  But I think just this simple fix is inadequate.

Sure, such a review would be welcomed.

The patch still seems an obvious improvement to me (and you don't seem
to be arguing the contrary?) so I'm inclined to apply it pending that
further work.

--b.
