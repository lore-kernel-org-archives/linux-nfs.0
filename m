Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26406 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753933Ab0BIIeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 03:34:24 -0500
Message-ID: <4B711E0B.6050705@panasas.com>
Date: Tue, 09 Feb 2010 10:34:19 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        pnfs mailing list <pnfs@linux-nfs.org>
Subject: Re: [pnfs] [PATCH 2/5] pnfsd: fix pnfs_export_operations layoutget
 valid errors
References: <1265389813-6823-1-git-send-email-andros@netapp.com>	<1265389813-6823-2-git-send-email-andros@netapp.com>	<1265389813-6823-3-git-send-email-andros@netapp.com>	<4B6E8266.3020502@panasas.com> <56F28E32-DE24-42C3-BDA1-B305704630FB@netapp.com>
In-Reply-To: <56F28E32-DE24-42C3-BDA1-B305704630FB@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/08/2010 10:41 PM, Andy Adamson wrote:
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
>>> @@ -870,6 +870,7 @@ nfs4_pnfs_get_layout(struct  
>>> nfsd4_pnfs_layoutget *lgp,
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
>          if (status) {
> +               /*
> +                * The allowable error codes for the layout_get pNFS  
> export
> +                * operations vector function can be expanded as needed
> +                * to include other errors defined for the LAYOUTGET  
> pNFS
> +                * operation.
> +                */
> +               case nfserr_badiomode:
> +               case nfserr_badlayout:
> +               case nfserr_layouttrylater:
> +               case nfserr_layoutunavailable:
> +               case nfserr_toosmall:
>                          break;
>                  default:
> +                       BUG();
>                  }
>                  goto out_freelayout;
> 
> -->Andy
> 

Perfect. it's all exofs needs.

I've prepared a SQUASHME for pnfsd-exofs to return these.
I'll send it as soon as you send the renewed patches.

Thanks Andy
Boaz

>>
>> Benny
>>
>>> 			status = nfserr_toosmall;
>>> 			break;
>>> 		case -ENOMEM:
>>> @@ -878,10 +879,7 @@ nfs4_pnfs_get_layout(struct  
>>> nfsd4_pnfs_layoutget *lgp,
>>
>> 		case nfserr_layouttrylater:
>>
>>> 			status = nfserr_layouttrylater;
>>> 			break;
>>> 		case -ENOENT:
>>> -			status = nfserr_badlayout;
>>> -			break;
>>> -		case -E2BIG:
>>> -			status = nfserr_toosmall;
>>> +			status = nfserr_stale;
>>> 			break;
>>> 		default:
>>> 			status = nfserr_layoutunavailable;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

