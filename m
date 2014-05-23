Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58373 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527AbaEWN6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 09:58:10 -0400
Date: Fri, 23 May 2014 09:58:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] NFS4: Avoid NULL reference or double free in
 nfsd4_fslocs_free()
Message-ID: <20140523135809.GL25423@fieldses.org>
References: <537F37BD.9070005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537F37BD.9070005@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 07:57:49PM +0800, Kinglong Mee wrote:
> If fsloc_parse() failed at kzalloc(), fs/nfsd/export.c
>  411
>  412         fsloc->locations = kzalloc(fsloc->locations_count
>  413                         * sizeof(struct nfsd4_fs_location), GFP_KERNEL);
>  414         if (!fsloc->locations)
>  415                 return -ENOMEM;
> 
> svc_export_parse() will call nfsd4_fslocs_free() with fsloc->locations = NULL,
> so that, "kfree(fsloc->locations[i].path);" will cause a crash.
> 
> If fsloc_parse() failed after that, fsloc_parse() will call nfsd4_fslocs_free(),
> and svc_export_parse() will call it again, so that, a double free is caused.
> 
> This patch checks the fsloc->locations, and set to NULL after it be freed.

Applying this and 2/4.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 8513c59..9a41d3d 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -295,13 +295,19 @@ svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
>  
>  static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
>  {
> +	struct nfsd4_fs_location *locations = fsloc->locations;
>  	int i;
>  
> +	if (!locations)
> +		return;
> +
>  	for (i = 0; i < fsloc->locations_count; i++) {
> -		kfree(fsloc->locations[i].path);
> -		kfree(fsloc->locations[i].hosts);
> +		kfree(locations[i].path);
> +		kfree(locations[i].hosts);
>  	}
> -	kfree(fsloc->locations);
> +
> +	kfree(locations);
> +	fsloc->locations = NULL;
>  }
>  
>  static void svc_export_put(struct kref *ref)
> -- 
> 1.9.0
> 
