From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [pnfs] [PATCH] SQUASHME: pnfsd-exofs: Change layoutget return codes
Date: Wed, 10 Feb 2010 08:06:11 -0500
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C8EC@daytona.int.panasas.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com><4B726D4E.1000601@panasas.com> <4B728E38.4060008@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: "Boaz Harrosh" <bharrosh@panasas.com>, <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38323 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752322Ab0BJNGS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 08:06:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfserr_xxx constants are already encoded in network order.
This is the internal convention de-facto in nfsd.
We can either leave them in the internal header and translate
the canonical constants to their net-order representation
or define them in a public header and have the filesystem
use them.  The former seems cleaner with regards to layering.

Benny

-----Original Message-----
From: pnfs-bounces@linux-nfs.org on behalf of Boaz Harrosh
Sent: Wed 2010-02-10 12:45
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org; J. Bruce Fields
Subject: Re: [pnfs] [PATCH] SQUASHME: pnfsd-exofs: Change layoutget return codes
 
On 02/10/2010 10:24 AM, Boaz Harrosh wrote:
> 
> Dependent on patch from Andy:
> 	[PATCH 1/6] pnfsd: fix file system API layout_get error codes
> 
> Change codes to nfs4.1 codes
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Rrrr I spoke to soon.

Andy, Benny
This will not work, currently. All the nfserr_xxx constants are defined
if fs/nfsd/nfsd.h. 
(Why do they exist at all, why can't we use the client's definitions for these?)

At the minimum they need to move to include/linux/nfsd/export.h. But I say kill them
and use these from include/linux/nfs4.h. Added bonus these are enums, so prototype
of .layout_get() can change to return enum nfsstat4 and the compiler fixes all our
bugs.

I'm posting a second patch that uses "enum nfsstat4" constants in exofs which will
work just fine, but is really ugly on the documentation aspect of Andy's patch.

Bruce may I submit a patch that globally gets rid of all nfserr_* defines and uses
NFS4ERR_* in their place?

Cheers
Boaz

> ---
>  fs/exofs/export.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/exofs/export.c b/fs/exofs/export.c
> index be3d54e..7a59614 100644
> --- a/fs/exofs/export.c
> +++ b/fs/exofs/export.c
> @@ -95,13 +95,13 @@ static int exofs_layout_get(
>  	/* skip opaque size, will be filled-in later */
>  	start = exp_xdr_reserve_qwords(xdr, 1);
>  	if (!start) {
> -		err = -E2BIG;
> +		err = nfserr_toosmall;
>  		goto err;
>  	}
>  
>  	creds = kcalloc(el->s_numdevs, sizeof(*creds), GFP_KERNEL);
>  	if (!creds) {
> -		err = -ENOMEM;
> +		err = nfserr_layouttrylater;
>  		goto err;
>  	}
>  
> @@ -134,8 +134,10 @@ static int exofs_layout_get(
>  	layout.olo_comps = creds;
>  
>  	err = pnfs_osd_xdr_encode_layout(xdr, &layout);
> -	if (err)
> +	if (err) {
> +		err = nfserr_toosmall; /*FIXME: Change osd_xdr error codes */
>  		goto err;
> +	}
>  
>  	exp_xdr_encode_opaque_len(start, xdr->p);
>  
> @@ -146,7 +148,7 @@ static int exofs_layout_get(
>  	spin_unlock(&oi->i_layout_lock);
>  
>  	if (in_recall)
> -		err = -EAGAIN;
> +		err = nfserr_layouttrylater;
>  
>  err:
>  	kfree(creds);

_______________________________________________
pNFS mailing list
pNFS@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

