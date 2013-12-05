Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755324Ab3LEO4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 09:56:08 -0500
Date: Thu, 5 Dec 2013 09:56:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Define op_iattr for nfsd4_open instead using macro
Message-ID: <20131205145606.GA30113@fieldses.org>
References: <529FE7E4.9010000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529FE7E4.9010000@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Thu, Dec 05, 2013 at 10:41:40AM +0800, Kinglong Mee wrote:
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/xdr4.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index b3ed644..e603cdd 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -228,7 +228,7 @@ struct nfsd4_open {
>  	u32		op_create;     	    /* request */
>  	u32		op_createmode;      /* request */
>  	u32		op_bmval[3];        /* request */
> -	struct iattr	iattr;              /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
> +	struct iattr	op_iattr;           /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
>  	nfs4_verifier	op_verf __attribute__((aligned(32)));
>  					    /* EXCLUSIVE4 */
>  	clientid_t	op_clientid;        /* request */
> @@ -250,7 +250,6 @@ struct nfsd4_open {
>  	struct nfs4_acl *op_acl;
>  	struct xdr_netobj op_label;
>  };
> -#define op_iattr	iattr
>  
>  struct nfsd4_open_confirm {
>  	stateid_t	oc_req_stateid		/* request */;
> -- 
> 1.8.4.2
