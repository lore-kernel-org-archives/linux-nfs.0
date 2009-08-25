From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcgss: reply AUTH_BADCRED to RPCSEC_GSS with unkown
	services
Date: Tue, 25 Aug 2009 17:40:02 -0400
Message-ID: <20090825214002.GD32708@fieldses.org>
References: <4A77FF18.4040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbZHYVkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 17:40:04 -0400
In-Reply-To: <4A77FF18.4040804@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 04, 2009 at 05:27:52PM +0800, Wei Yongjun wrote:
> When RPC messages is received with RPCSEC_GSS, and if the RPCSEC_GSS
> include unkown services (not RPC_GSS_SVC_NONE, RPC_GSS_SVC_INTEGRITY
> and RPC_GSS_SVC_PRIVACY), the response is considered as AUTH_BADCRED
> in svcauth_gss_accept(), but the response be drop by
> svcauth_gss_release(). I think response with AUTH_BADCRED is correct
> one. So this patch fixed it.

Thanks!  How did you find this?  (And how did you test the result?)

> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 2278a50..6dce327 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1370,7 +1370,7 @@ svcauth_gss_release(struct svc_rqst *rqstp)
>  			goto out_err;
>  		break;
>  	default:
> -		goto out_err;
> +		goto out;
>  	}
>  
>  out:

The goto seems redundant.  How about just leaving out the default case
and providing a comment?  (See below.)

--b.

commit ab3654a05aaf367b23bbb3d9229ff72a11999719
Author: Wei Yongjun <yjwei@cn.fujitsu.com>
Date:   Tue Aug 4 17:27:52 2009 +0800

    svcgss: reply AUTH_BADCRED to RPCSEC_GSS with unknown service
    
    When an RPC message is received with RPCSEC_GSS with an unknown service
    (not RPC_GSS_SVC_NONE, RPC_GSS_SVC_INTEGRITY, or RPC_GSS_SVC_PRIVACY),
    svcauth_gss_accept() returns AUTH_BADCRED, but svcauth_gss_release()
    subsequently drops the response entirely, discarding the error.
    
    Fix that so the AUTH_BADCRED error is returned to the client.
    
    Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 2e6a148..f6c51e5 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1374,8 +1374,10 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 		if (stat)
 			goto out_err;
 		break;
-	default:
-		goto out_err;
+	/*
+	 * For any other gc_svc value, svcauth_gss_accept() already set
+	 * the auth_error appropriately; just fall through:
+	 */
 	}
 
 out:
