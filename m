From: Andy Adamson <andros@netapp.com>
Subject: Re: [pnfs] [PATCH 2/5] pnfsd: fix pnfs_export_operations layoutget valid errors
Date: Mon, 8 Feb 2010 15:41:44 -0500
Message-ID: <56F28E32-DE24-42C3-BDA1-B305704630FB@netapp.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>	<1265389813-6823-2-git-send-email-andros@netapp.com> <1265389813-6823-3-git-send-email-andros@netapp.com> <4B6E8266.3020502@panasas.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: pnfs mailing list <pnfs@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391Ab0BHUlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 15:41:46 -0500
In-Reply-To: <4B6E8266.3020502@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 7, 2010, at 4:05 AM, Benny Halevy wrote:

> On Feb. 05, 2010, 19:10 +0200, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfsd/nfs4pnfsd.c |    6 ++----
>> 1 files changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
>> index 816e2f0..3951e02 100644
>> --- a/fs/nfsd/nfs4pnfsd.c
>> +++ b/fs/nfsd/nfs4pnfsd.c
>> @@ -870,6 +870,7 @@ nfs4_pnfs_get_layout(struct  
>> nfsd4_pnfs_layoutget *lgp,
>> 	if (status) {
>> 		switch (status) {
>> 		case -ETOOSMALL:
>> +		case -E2BIG:
>
> Should we allow the filesystem to return nfs errors?
> Or even require it to do so?
>
> This can be done by adding cases for the
> valid error values for LAYOUTGET in this switch statement.

OK. From re-reading all the past mail and the comments on this latest  
patch set:

1) We want a limited number of well documented error returns -  
documented as part of the filesystem API not just the spec.

2) Start with just the errors that we know we need for gfs2 and exofs,  
and expand the list later as necessary.

3) Allow only nfserr_xxxx errors.


Does this address the comments? Do you want more documentation, if so,  
where?

         if (status) {
+               /*
+                * The allowable error codes for the layout_get pNFS  
export
+                * operations vector function can be expanded as needed
+                * to include other errors defined for the LAYOUTGET  
pNFS
+                * operation.
+                */
+               case nfserr_badiomode:
+               case nfserr_badlayout:
+               case nfserr_layouttrylater:
+               case nfserr_layoutunavailable:
+               case nfserr_toosmall:
                         break;
                 default:
+                       BUG();
                 }
                 goto out_freelayout;

-->Andy

>
> Benny
>
>> 			status = nfserr_toosmall;
>> 			break;
>> 		case -ENOMEM:
>> @@ -878,10 +879,7 @@ nfs4_pnfs_get_layout(struct  
>> nfsd4_pnfs_layoutget *lgp,
>
> 		case nfserr_layouttrylater:
>
>> 			status = nfserr_layouttrylater;
>> 			break;
>> 		case -ENOENT:
>> -			status = nfserr_badlayout;
>> -			break;
>> -		case -E2BIG:
>> -			status = nfserr_toosmall;
>> +			status = nfserr_stale;
>> 			break;
>> 		default:
>> 			status = nfserr_layoutunavailable;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

