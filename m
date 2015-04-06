Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbbDFVOh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Apr 2015 17:14:37 -0400
Message-ID: <5522F73B.2020909@RedHat.com>
Date: Mon, 06 Apr 2015 17:14:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs-utils: add missing comma for exports ent
References: <5521422A.7080005@gmail.com>
In-Reply-To: <5521422A.7080005@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/05/2015 10:09 AM, Kinglong Mee wrote:
> When using pnfs with "fsid=0", exportfs prints error as, 
> 
> # exportfs -a
> exportfs: /var/lib/nfs/etab:1: unknown keyword "no_pnfsfsid=0"
> 
> Commit cdd16bef98 ("nfs-utils: add support for the "pnfs" export option")
> miss the comma after "pnfs"/"on_pnfs" operation.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved.

> ---
>  support/nfs/exports.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 9b325b9..761a046 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -275,7 +275,7 @@ putexportent(struct exportent *ep)
>  		"no_" : "");
>  	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
>  		fprintf(fp, "nordirplus,");
> -	fprintf(fp, "%spnfs", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
> +	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> 
