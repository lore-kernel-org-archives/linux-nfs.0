Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39659 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756691AbaICVgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 17:36:09 -0400
Date: Wed, 3 Sep 2014 17:36:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/6] NFSD: Put export if prepare_creds() fail
Message-ID: <20140903213608.GD25363@fieldses.org>
References: <5405D0FE.70008@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5405D0FE.70008@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying all 6 for 3.18.

--b.

On Tue, Sep 02, 2014 at 10:15:26PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfsfh.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index e883a58..88026fc 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -209,8 +209,10 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
>  		 * fix that case easily.
>  		 */
>  		struct cred *new = prepare_creds();
> -		if (!new)
> -			return nfserrno(-ENOMEM);
> +		if (!new) {
> +			error =  nfserrno(-ENOMEM);
> +			goto out;
> +		}
>  		new->cap_effective =
>  			cap_raise_nfsd_set(new->cap_effective,
>  					   new->cap_permitted);
> -- 
> 1.9.3
> 
