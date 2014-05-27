Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50937 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbaE0PrC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 11:47:02 -0400
Date: Tue, 27 May 2014 11:47:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Using type of uint32_t for ex_nflavors instead of
 int
Message-ID: <20140527154700.GB21989@fieldses.org>
References: <53801179.8080502@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53801179.8080502@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 24, 2014 at 11:26:49AM +0800, Kinglong Mee wrote:
> ex_nflavors can't be negative number, just defined by uint32_t.

OK, applying for 3.16.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 7 ++++---
>  fs/nfsd/export.h | 2 +-
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 8513c59..9343ae2 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -437,13 +437,14 @@ out_free_all:
>  
>  static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
>  {
> -	int listsize, err;
>  	struct exp_flavor_info *f;
> +	u32 listsize;
> +	int err;
>  
> -	err = get_int(mesg, &listsize);
> +	err = get_uint(mesg, &listsize);
>  	if (err)
>  		return err;
> -	if (listsize < 0 || listsize > MAX_SECINFO_LIST)
> +	if (listsize > MAX_SECINFO_LIST)
>  		return -EINVAL;
>  
>  	for (f = exp->ex_flavors; f < exp->ex_flavors + listsize; f++) {
> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> index d7939a6..11d03b9 100644
> --- a/fs/nfsd/export.h
> +++ b/fs/nfsd/export.h
> @@ -53,7 +53,7 @@ struct svc_export {
>  	int			ex_fsid;
>  	unsigned char *		ex_uuid; /* 16 byte fsid */
>  	struct nfsd4_fs_locations ex_fslocs;
> -	int			ex_nflavors;
> +	uint32_t		ex_nflavors;
>  	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
>  	struct cache_detail	*cd;
>  };
> -- 
> 1.9.3
> 
