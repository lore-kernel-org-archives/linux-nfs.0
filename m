Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437AbaE2NnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 09:43:18 -0400
Message-ID: <5387396E.20507@RedHat.com>
Date: Thu, 29 May 2014 09:43:10 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH v3] Avoid buffer overruns by allocating
 buffer in svcauth_gss_validate()
References: <1401304171-12231-1-git-send-email-steved@redhat.com>
In-Reply-To: <1401304171-12231-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/28/2014 03:09 PM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  src/svc_auth_gss.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
> index 601a691..26c1065 100644
> --- a/src/svc_auth_gss.c
> +++ b/src/svc_auth_gss.c
> @@ -286,21 +286,19 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>  	struct opaque_auth	*oa;
>  	gss_buffer_desc		 rpcbuf, checksum;
>  	OM_uint32		 maj_stat, min_stat, qop_state;
> -	u_char			 rpchdr[128];
> +	u_char			 *rpchdr;
>  	int32_t			*buf;
>  
>  	gss_log_debug("in svcauth_gss_validate()");
>  
> -	memset(rpchdr, 0, sizeof(rpchdr));
> -
>  	/* XXX - Reconstruct RPC header for signing (from xdr_callmsg). */
>  	oa = &msg->rm_call.cb_cred;
>  	if (oa->oa_length > MAX_AUTH_BYTES)
>  		return (FALSE);
> -	
> -	/* 8 XDR units from the IXDR macro calls. */
> -	if (sizeof(rpchdr) < (8 * BYTES_PER_XDR_UNIT +
> -			RNDUP(oa->oa_length)))
> +
> +	rpchdr = (u_char *)calloc(((8 * BYTES_PER_XDR_UNIT) + 
> +			RNDUP(oa->oa_length)), 1);
> +	if (rpchdr == NULL)
>  		return (FALSE);
>  
>  	buf = (int32_t *)rpchdr;
> @@ -325,6 +323,8 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>  	maj_stat = gss_verify_mic(&min_stat, gd->ctx, &rpcbuf, &checksum,
>  				  &qop_state);
>  
> +	free(rpchdr);
> +
>  	if (maj_stat != GSS_S_COMPLETE) {
>  		gss_log_status("gss_verify_mic", maj_stat, min_stat);
>  		return (FALSE);
> 
