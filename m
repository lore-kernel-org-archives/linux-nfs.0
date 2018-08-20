Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726293AbeHTWVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 18:21:49 -0400
Date: Mon, 20 Aug 2018 15:05:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, simo@redhat.com
Subject: Re: [PATCH] sunrpc: Add comment defining gssd upcall API keywords
Message-ID: <20180820190501.GC5468@fieldses.org>
References: <20180820143801.10060.61177.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180820143801.10060.61177.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2018 at 10:39:16AM -0400, Chuck Lever wrote:
> During review, it was found that the target, service, and srchost
> keywords are easily conflated. Add an explainer.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> Hi Bruce-
> 
> I've received no objections to this patch. Can you include it in
> v4.19 with the other patches I've already submitted?

Will do, it'll probably just be another week or so before I publish a
4.19 branch.

--b.

> 
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 1943e11..2460759 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -461,12 +461,28 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
>  	buflen -= len;
>  	p += len;
>  	gss_msg->msg.len = len;
> +
> +	/*
> +	 * target= is a full service principal that names the remote
> +	 * identity that we are authenticating to.
> +	 */
>  	if (target_name) {
>  		len = scnprintf(p, buflen, "target=%s ", target_name);
>  		buflen -= len;
>  		p += len;
>  		gss_msg->msg.len += len;
>  	}
> +
> +	/*
> +	 * gssd uses service= and srchost= to select a matching key from
> +	 * the system's keytab to use as the source principal.
> +	 *
> +	 * service= is the service name part of the source principal,
> +	 * or "*" (meaning choose any).
> +	 *
> +	 * srchost= is the hostname part of the source principal. When
> +	 * not provided, gssd uses the local hostname.
> +	 */
>  	if (service_name) {
>  		char *c = strchr(service_name, '@');
>  
> @@ -482,6 +498,7 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
>  		p += len;
>  		gss_msg->msg.len += len;
>  	}
> +
>  	if (mech->gm_upcall_enctypes) {
>  		len = scnprintf(p, buflen, "enctypes=%s ",
>  				mech->gm_upcall_enctypes);
