Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40569 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbbEGSMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 14:12:08 -0400
Date: Thu, 7 May 2015 20:12:06 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507181206.GA7810@suse.de>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507115248.GA20243@suse.de>
 <554B86E2.8090908@RedHat.com>
 <20150507163326.GA6156@suse.de>
 <554B98E9.4040601@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <554B98E9.4040601@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 07, Steve Dickson wrote:

> On 05/07/2015 12:33 PM, Thorsten Kukuk wrote:
> >>> > > Else here is my patch:
> >> > Is this patch addition to Mike's patch?
> > No, replacing it except the struct part.
> So this is the complete patch..... 
> 
> Look reasonable??

Some corrections:

> diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
> index 44b38bf..4b9b0f1 100644
> --- a/tirpc/rpc/svc_auth.h
> +++ b/tirpc/rpc/svc_auth.h

> @@ -63,8 +69,10 @@ typedef struct SVCAUTH {
>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>  		} *svc_ah_ops;
>  	caddr_t svc_ah_private;
> +#ifdef HAVE_RPCSEC_GSS
>  	svc_rpc_gss_parms_t svc_gss_params;
>  	rpc_gss_rawcred_t raw_cred;
> +#endif
>  } SVCAUTH;
>  

This needs to be "#ifdef HAVE_GSSAPI", HAVE_RPCSEC_GSS
will never be defined if the header is used outside of
libtirpc sources

> diff --git a/tirpc/tirpc-features.h b/tirpc/tirpc-features.h
> new file mode 100644
> index 0000000..7aec775
> --- /dev/null
> +++ b/tirpc/tirpc-features.h


You should not tirpc/tirpc-features.h, only tirpc/tirpc-features.h.in
tirpc/tirpc-features.h will be created by configure, like libtirpc.pc
and config.h.

  Thorsten

-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
