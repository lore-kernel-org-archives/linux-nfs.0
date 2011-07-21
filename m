Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304Ab1GUTZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 15:25:00 -0400
Message-ID: <4E287D08.4080802@RedHat.com>
Date: Thu, 21 Jul 2011 15:24:56 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benjamin Coddington <bcodding@uvm.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: Fix typo in debug string
References: <20110720132306.A21B063D40BF@planck.uvm.edu>
In-Reply-To: <20110720132306.A21B063D40BF@planck.uvm.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/20/2011 09:20 AM, Benjamin Coddington wrote:
> ---
>  utils/gssd/context_lucid.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
> index b8d4734..3e695ab 100644
> --- a/utils/gssd/context_lucid.c
> +++ b/utils/gssd/context_lucid.c
> @@ -305,7 +305,7 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
>  
>  	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
>  	if (maj_stat != GSS_S_COMPLETE) {
> -		pgsserr("gss_export_lucid_sec_context",
> +		pgsserr("gss_free_lucid_sec_context",
>  			maj_stat, min_stat, &krb5oid);
>  		printerr(0, "WARN: failed to free lucid sec context\n");
>  	}
Committed...

steved.
