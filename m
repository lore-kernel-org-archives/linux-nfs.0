From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 20/24] Removed warnings from svcgssd_proc.c
Date: Wed, 21 Jul 2010 13:23:04 -0400
Message-ID: <20100721172304.GC26418@fieldses.org>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
 <1279669057-17509-21-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51612 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab0GURXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 13:23:48 -0400
In-Reply-To: <1279669057-17509-21-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 07:37:33PM -0400, Steve Dickson wrote:
> svcgssd_proc.c: In function 'send_response':
> svcgssd_proc.c:135: warning: unused parameter 'f'
> svcgssd_proc.c: In function 'handle_nullreq':
> svcgssd_proc.c:434: warning: comparison of unsigned expression < 0 is always false
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/svcgssd_proc.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
> index f1bfbef..28336c2 100644
> --- a/utils/gssd/svcgssd_proc.c
> +++ b/utils/gssd/svcgssd_proc.c
> @@ -132,7 +132,7 @@ struct gss_verifier {
>  #define RPCSEC_GSS_SEQ_WIN	5
>  
>  static int
> -send_response(FILE *f, gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
> +send_response(gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
>  	      u_int32_t maj_stat, u_int32_t min_stat,
>  	      gss_buffer_desc *out_handle, gss_buffer_desc *out_token)
>  {
> @@ -431,7 +431,7 @@ handle_nullreq(FILE *f) {
>  	print_hexl("in_tok", in_tok.value, in_tok.length);
>  #endif
>  
> -	if (in_tok.length < 0) {
> +	if (in_tok.length == 0) {

Is a zero-length token really illegal?  I'd just ditch this check
entirely.

--b.

>  		printerr(0, "WARNING: handle_nullreq: "
>  			    "failed parsing request\n");
>  		goto out_err;
> @@ -498,7 +498,7 @@ handle_nullreq(FILE *f) {
>  	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
>  			hostbased_name);
>  continue_needed:
> -	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
> +	send_response(&in_handle, &in_tok, maj_stat, min_stat,
>  			&out_handle, &out_tok);
>  out:
>  	if (ctx_token.value != NULL)
> @@ -514,7 +514,7 @@ out:
>  out_err:
>  	if (ctx != GSS_C_NO_CONTEXT)
>  		gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
> -	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
> +	send_response(&in_handle, &in_tok, maj_stat, min_stat,
>  			&null_token, &null_token);
>  	goto out;
>  }
> -- 
> 1.7.0.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
