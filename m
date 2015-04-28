Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030931AbbD1VJ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 17:09:27 -0400
Message-ID: <1430255365.13607.165.camel@willson.usersys.redhat.com>
Subject: Re: [PATCH] svcrpc: fix potential GSSX_ACCEPT_SEC_CONTEXT decoding
 failures
From: Simo Sorce <simo@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Date: Tue, 28 Apr 2015 17:09:25 -0400
In-Reply-To: <1430252993-20091-1-git-send-email-smayhew@redhat.com>
References: <1430252993-20091-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Scott,
I think this will help with older GSS-Proxy versions, in the newer
versions we are simply suppressing the exported composite name as the
kernel has no use for it.

Simo.

On Tue, 2015-04-28 at 16:29 -0400, Scott Mayhew wrote:
> In an environment where the KDC is running Active Directory, the
> exported composite name field returned in the context could be large
> enough to span a page boundary.  Attaching a scratch buffer to the
> decoding xdr_stream helps deal with those cases.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  net/sunrpc/auth_gss/gss_rpc_xdr.c | 23 ++++++++++++++++-------
>  1 file changed, 16 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> index 1ec19f6..eeeba5a 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> @@ -793,20 +793,26 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  {
>  	u32 value_follows;
>  	int err;
> +	struct page *scratch;
> +
> +	scratch = alloc_page(GFP_KERNEL);
> +	if (!scratch)
> +		return -ENOMEM;
> +	xdr_set_scratch_buffer(xdr, page_address(scratch), PAGE_SIZE);
>  
>  	/* res->status */
>  	err = gssx_dec_status(xdr, &res->status);
>  	if (err)
> -		return err;
> +		goto out_free;
>  
>  	/* res->context_handle */
>  	err = gssx_dec_bool(xdr, &value_follows);
>  	if (err)
> -		return err;
> +		goto out_free;
>  	if (value_follows) {
>  		err = gssx_dec_ctx(xdr, res->context_handle);
>  		if (err)
> -			return err;
> +			goto out_free;
>  	} else {
>  		res->context_handle = NULL;
>  	}
> @@ -814,11 +820,11 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  	/* res->output_token */
>  	err = gssx_dec_bool(xdr, &value_follows);
>  	if (err)
> -		return err;
> +		goto out_free;
>  	if (value_follows) {
>  		err = gssx_dec_buffer(xdr, res->output_token);
>  		if (err)
> -			return err;
> +			goto out_free;
>  	} else {
>  		res->output_token = NULL;
>  	}
> @@ -826,14 +832,17 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  	/* res->delegated_cred_handle */
>  	err = gssx_dec_bool(xdr, &value_follows);
>  	if (err)
> -		return err;
> +		goto out_free;
>  	if (value_follows) {
>  		/* we do not support upcall servers sending this data. */
> -		return -EINVAL;
> +		err = -EINVAL;
> +		goto out_free;
>  	}
>  
>  	/* res->options */
>  	err = gssx_dec_option_array(xdr, &res->options);
>  
> +out_free:
> +	__free_page(scratch);
>  	return err;
>  }


-- 
Simo Sorce * Red Hat, Inc * New York

