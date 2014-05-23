Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58377 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbaEWOAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 10:00:43 -0400
Date: Fri, 23 May 2014 10:00:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Adds macro EX_UUID_LEN for exports uuid's
 length
Message-ID: <20140523140042.GM25423@fieldses.org>
References: <537F3853.3090109@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537F3853.3090109@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 08:00:19PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Applying with some minor fixups after xdr encoding stuff.

--b.

> ---
>  fs/nfsd/export.c  | 6 +++---
>  fs/nfsd/export.h  | 1 +
>  fs/nfsd/nfs4xdr.c | 2 +-
>  3 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 8771f41..90d37b6 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -487,10 +487,10 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
>  
>  	/* expect a 16 byte uuid encoded as \xXXXX... */
>  	len = qword_get(mesg, buf, PAGE_SIZE);
> -	if (len != 16)
> +	if (len != EX_UUID_LEN)
>  		return -EINVAL;
>  
> -	*puuid = kmemdup(buf, 16, GFP_KERNEL);
> +	*puuid = kmemdup(buf, EX_UUID_LEN, GFP_KERNEL);
>  	if (*puuid == NULL)
>  		return -ENOMEM;
>  
> @@ -663,7 +663,7 @@ static int svc_export_show(struct seq_file *m,
>  		if (exp->ex_uuid) {
>  			int i;
>  			seq_puts(m, ",uuid=");
> -			for (i=0; i<16; i++) {
> +			for (i = 0; i < EX_UUID_LEN; i++) {
>  				if ((i&3) == 0 && i)
>  					seq_putc(m, ':');
>  				seq_printf(m, "%02x", exp->ex_uuid[i]);
> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> index d7939a6..c7d4ed0 100644
> --- a/fs/nfsd/export.h
> +++ b/fs/nfsd/export.h
> @@ -37,6 +37,7 @@ struct nfsd4_fs_locations {
>   * spkm3i, and spkm3p (and using all 8 at once should be rare).
>   */
>  #define MAX_SECINFO_LIST	8
> +#define EX_UUID_LEN		16
>  
>  struct exp_flavor_info {
>  	u32	pseudoflavor;
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 18881f3..071b0be 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2250,7 +2250,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  			WRITE32(MINOR(stat.dev));
>  			break;
>  		case FSIDSOURCE_UUID:
> -			WRITEMEM(exp->ex_uuid, 16);
> +			WRITEMEM(exp->ex_uuid, EX_UUID_LEN);
>  			break;
>  		}
>  	}
> -- 
> 1.9.0
> 
