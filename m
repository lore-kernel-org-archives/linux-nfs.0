Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305AbaFRUpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2014 16:45:00 -0400
Message-ID: <53A1FA42.5000000@RedHat.com>
Date: Wed, 18 Jun 2014 16:44:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH] xdr_rejected_reply: Don't crash with
 invalid server rejection
References: <1401976096-16802-1-git-send-email-steved@redhat.com>
In-Reply-To: <1401976096-16802-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/05/2014 09:48 AM, Steve Dickson wrote:
> It seems legacy servers like to return invalid
> rejection status when a RPC is rejected. This
> should not crash the app then it happens.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.... 

steved.

> ---
>  src/rpc_prot.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/src/rpc_prot.c b/src/rpc_prot.c
> index e562deb..5841e51 100644
> --- a/src/rpc_prot.c
> +++ b/src/rpc_prot.c
> @@ -150,7 +150,6 @@ xdr_rejected_reply(xdrs, rr)
>  		return (xdr_enum(xdrs, (enum_t *)&(rr->rj_why)));
>  	}
>  	/* NOTREACHED */
> -	assert(0);
>  	return (FALSE);
>  }
>  
> 
