From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 2/5] pnfsd: fix pnfs_export_operations layoutget
 valid errors
Date: Sun, 07 Feb 2010 11:05:42 +0200
Message-ID: <4B6E8266.3020502@panasas.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>	<1265389813-6823-2-git-send-email-andros@netapp.com> <1265389813-6823-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23736 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751176Ab0BGJFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2010 04:05:45 -0500
In-Reply-To: <1265389813-6823-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb. 05, 2010, 19:10 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4pnfsd.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 816e2f0..3951e02 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -870,6 +870,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
>  	if (status) {
>  		switch (status) {
>  		case -ETOOSMALL:
> +		case -E2BIG:

Should we allow the filesystem to return nfs errors?
Or even require it to do so?

This can be done by adding cases for the
valid error values for LAYOUTGET in this switch statement.

Benny

>  			status = nfserr_toosmall;
>  			break;
>  		case -ENOMEM:
> @@ -878,10 +879,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,

		case nfserr_layouttrylater:

>  			status = nfserr_layouttrylater;
>  			break;
>  		case -ENOENT:
> -			status = nfserr_badlayout;
> -			break;
> -		case -E2BIG:
> -			status = nfserr_toosmall;
> +			status = nfserr_stale;
>  			break;
>  		default:
>  			status = nfserr_layoutunavailable;
