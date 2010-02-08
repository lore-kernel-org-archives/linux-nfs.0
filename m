From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 2/5] pnfsd: fix pnfs_export_operations layoutget
	valid errors
Date: Mon, 8 Feb 2010 16:01:22 -0500
Message-ID: <20100208210122.GI12101@fieldses.org>
References: <1265389813-6823-1-git-send-email-andros@netapp.com> <1265389813-6823-2-git-send-email-andros@netapp.com> <1265389813-6823-3-git-send-email-andros@netapp.com> <4B6E8266.3020502@panasas.com> <56F28E32-DE24-42C3-BDA1-B305704630FB@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	pnfs mailing list <pnfs@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48542 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992Ab0BHVBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 16:01:03 -0500
In-Reply-To: <56F28E32-DE24-42C3-BDA1-B305704630FB@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 08, 2010 at 03:41:44PM -0500, Andy Adamson wrote:
>
> On Feb 7, 2010, at 4:05 AM, Benny Halevy wrote:
>
>> On Feb. 05, 2010, 19:10 +0200, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> fs/nfsd/nfs4pnfsd.c |    6 ++----
>>> 1 files changed, 2 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
>>> index 816e2f0..3951e02 100644
>>> --- a/fs/nfsd/nfs4pnfsd.c
>>> +++ b/fs/nfsd/nfs4pnfsd.c
>>> @@ -870,6 +870,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget 
>>> *lgp,
>>> 	if (status) {
>>> 		switch (status) {
>>> 		case -ETOOSMALL:
>>> +		case -E2BIG:
>>
>> Should we allow the filesystem to return nfs errors?
>> Or even require it to do so?
>>
>> This can be done by adding cases for the
>> valid error values for LAYOUTGET in this switch statement.
>
> OK. From re-reading all the past mail and the comments on this latest  
> patch set:
>
> 1) We want a limited number of well documented error returns -  
> documented as part of the filesystem API not just the spec.
>
> 2) Start with just the errors that we know we need for gfs2 and exofs,  
> and expand the list later as necessary.
>
> 3) Allow only nfserr_xxxx errors.
>
>
> Does this address the comments? Do you want more documentation, if so,  
> where?
>
>         if (status) {
> +               /*
> +                * The allowable error codes for the layout_get pNFS  
> export
> +                * operations vector function can be expanded as needed
> +                * to include other errors defined for the LAYOUTGET  
> pNFS
> +                * operation.
> +                */

Could you dump some description of the cases into the error numbers, if
it's not obvious?  E.g.:

> +               case nfserr_badiomode:
			/*
			 * filesystem doesn't want to give out a
			 * writeable layout in this case.
			 */
> +               case nfserr_badlayout:
> +               case nfserr_layouttrylater:
> +               case nfserr_layoutunavailable:
> +               case nfserr_toosmall:

just to summarize what the various filesystems are doing.

And don't worry about it being a little messy or verbose; we can clean
it up later.

--b.
