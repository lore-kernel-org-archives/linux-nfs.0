Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbaE0PrO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 11:47:14 -0400
Date: Tue, 27 May 2014 11:47:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSD: Error out when getting more than one
 fsloc/secinfo/uuid
Message-ID: <20140527154713.GC21989@fieldses.org>
References: <537F38AB.10102@gmail.com>
 <20140523135435.GK25423@fieldses.org>
 <537F5A1A.9000005@gmail.com>
 <20140523144128.GO25423@fieldses.org>
 <53800FDD.7030001@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53800FDD.7030001@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 24, 2014 at 11:19:57AM +0800, Kinglong Mee wrote:
> v2:
> remove WARN_ON_ONCE(1) and return -EINVAL instead of ignoring it. 

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 7884051..13b85f9 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -389,6 +389,10 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
>  	int len;
>  	int migrated, i, err;
>  
> +	/* more than one fsloc */
> +	if (fsloc->locations)
> +		return -EINVAL;
> +
>  	/* listsize */
>  	err = get_uint(mesg, &fsloc->locations_count);
>  	if (err)
> @@ -442,6 +446,10 @@ static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
>  	u32 listsize;
>  	int err;
>  
> +	/* more than one secinfo */
> +	if (exp->ex_nflavors)
> +		return -EINVAL;
> +
>  	err = get_uint(mesg, &listsize);
>  	if (err)
>  		return err;
> @@ -481,6 +489,10 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
>  {
>  	int len;
>  
> +	/* more than one uuid */
> +	if (*puuid)
> +		return -EINVAL;
> +
>  	/* expect a 16 byte uuid encoded as \xXXXX... */
>  	len = qword_get(mesg, buf, PAGE_SIZE);
>  	if (len != EX_UUID_LEN)
> -- 
> 1.9.3
> 
