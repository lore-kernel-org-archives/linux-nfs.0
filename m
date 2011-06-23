Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35287 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759229Ab1FWP7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jun 2011 11:59:48 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QZmJo-0002YN-2I
	for linux-nfs@vger.kernel.org; Thu, 23 Jun 2011 11:59:48 -0400
Date: Thu, 23 Jun 2011 11:59:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: autoload rpcsec_gss_krb5
Message-ID: <20110623155947.GC8911@fieldses.org>
References: <20110622213209.GA3010@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110622213209.GA3010@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

By the way:

On Wed, Jun 22, 2011 at 05:32:09PM -0400, J. Bruce Fields wrote:
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> index 0a9a2ec..5c33926 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -743,6 +743,13 @@ static struct pf_desc gss_kerberos_pfs[] = {
>  	},
>  };
>  
> +MODULE_ALIAS("rpc-auth-gss-krb5");
> +MODULE_ALIAS("rpc-auth-gss-krb5i");
> +MODULE_ALIAS("rpc-auth-gss-krb5p");
> +MODULE_ALIAS("rpc-auth-gss-390003");
> +MODULE_ALIAS("rpc-auth-gss-390004");
> +MODULE_ALIAS("rpc-auth-gss-390005");

Is there any reason we don't do this for the auth modules, and the pnfs
layout modules?  Seems silly to wait for distro's to add it to
modprobe.conf if we don't need to.

--b.
