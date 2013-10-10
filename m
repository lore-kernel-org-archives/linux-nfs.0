Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755827Ab3JJPfZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:35:25 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9AFZOKY008228
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 11:35:25 -0400
Subject: Re: [PATCH 1/4] svcrpc: fix gss-proxy NULL dereference in some
 error cases
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1381418103-3852-2-git-send-email-bfields@redhat.com>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
	 <1381418103-3852-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Oct 2013 11:35:23 -0400
Message-ID: <1381419323.2684.13.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-10 at 11:15 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We depend on the xdr decoder to set this pointer, but if we error out
> before we decode this piece it could be left NULL.
> 
> I think this is probably tough to hit without a buggy gss-proxy.
> 
> Reported-by: Andi Kleen <andi@firstfloor.org>
> Cc: Simo Sorce <simo@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> index f1eb0d1..458f85e 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> @@ -298,7 +298,8 @@ int gssp_accept_sec_context_upcall(struct net *net,
>  	if (res.context_handle) {
>  		data->out_handle = rctxh.exported_context_token;
>  		data->mech_oid.len = rctxh.mech.len;
> -		memcpy(data->mech_oid.data, rctxh.mech.data,
> +		if (rctxh.mech.data)
> +			memcpy(data->mech_oid.data, rctxh.mech.data,
>  						data->mech_oid.len);
>  		client_name = rctxh.src_name.display_name;
>  	}

Reviewed-by: Simo Sorce <simo@redhat.com>

-- 
Simo Sorce * Red Hat, Inc * New York

