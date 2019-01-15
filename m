Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7C41C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 20:27:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8BEE8204FD
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 20:27:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389821AbfAOU14 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 15:27:56 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732409AbfAOU1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Jan 2019 15:27:55 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 36E8E8831D;
        Tue, 15 Jan 2019 20:27:55 +0000 (UTC)
Received: from ovpn-117-66.phx2.redhat.com (ovpn-117-66.phx2.redhat.com [10.3.117.66])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id D93C619940;
        Tue, 15 Jan 2019 20:27:54 +0000 (UTC)
Message-ID: <1abacf26a87056d998575fbec8c517dff62e882a.camel@redhat.com>
Subject: Re: [PATCH RFC] SUNRPC: Add build option to disable support for
 insecure enctypes
From:   Simo Sorce <simo@redhat.com>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date:   Tue, 15 Jan 2019 15:27:53 -0500
In-Reply-To: <20190115201835.6381.19527.stgit@manet.1015granger.net>
References: <20190115201835.6381.19527.stgit@manet.1015granger.net>
Organization: Red Hat, Inc.
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 15 Jan 2019 20:27:55 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

LGTM

Acked-by: Simo Sorce <simo@redhat.com>

On Tue, 2019-01-15 at 15:18 -0500, Chuck Lever wrote:
> Enable distributions to enforce the rejection of ancient and
> insecure Kerberos enctypes in the kernel's RPCSEC_GSS
> implementation. These are the single-DES encryption types that
> were deprecated in 2012 by RFC 6649.
> 
> Enctypes that were deprecated more recently (by RFC 8429) remain
> fully supported for now because they are still likely to be widely
> used.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/gss_krb5_enctypes.h |   42 +++++++++++++++++++++++++++++-
>  net/sunrpc/Kconfig                       |   16 +++++++++++
>  net/sunrpc/auth_gss/gss_krb5_mech.c      |    2 +
>  3 files changed, 59 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h b/include/linux/sunrpc/gss_krb5_enctypes.h
> index ec6234e..788742d 100644
> --- a/include/linux/sunrpc/gss_krb5_enctypes.h
> +++ b/include/linux/sunrpc/gss_krb5_enctypes.h
> @@ -1,4 +1,44 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
>  /*
> - * Dumb way to share this static piece of information with nfsd
> + * Define the string that exports the set of kernel-supported
> + * Kerberos enctypes. This list is sent via upcall to gssd, and
> + * is also exposed via the nfsd /proc API. The consumers generally
> + * treat this as an ordered list, where the first item in the list
> + * is the most preferred.
> + */
> +
> +#ifndef _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H
> +#define _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H
> +
> +#ifdef CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
> +
> +/*
> + * NB: This list includes encryption types that were deprecated
> + * by RFC 8429 (DES3_CBC_SHA1 and ARCFOUR_HMAC).
> + *
> + * ENCTYPE_AES256_CTS_HMAC_SHA1_96
> + * ENCTYPE_AES128_CTS_HMAC_SHA1_96
> + * ENCTYPE_DES3_CBC_SHA1
> + * ENCTYPE_ARCFOUR_HMAC
> + */
> +#define KRB5_SUPPORTED_ENCTYPES "18,17,16,23"
> +
> +#else	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
> +
> +/*
> + * NB: This list includes encryption types that were deprecated
> + * by RFC 6649 and RFC 8429 (DES3_CBC_SHA1 and ARCFOUR_HMAC).
> + *
> + * ENCTYPE_AES256_CTS_HMAC_SHA1_96
> + * ENCTYPE_AES128_CTS_HMAC_SHA1_96
> + * ENCTYPE_DES3_CBC_SHA1
> + * ENCTYPE_ARCFOUR_HMAC
> + * ENCTYPE_DES_CBC_MD5
> + * ENCTYPE_DES_CBC_CRC
> + * ENCTYPE_DES_CBC_MD4
>   */
>  #define KRB5_SUPPORTED_ENCTYPES "18,17,16,23,3,1,2"
> +
> +#endif	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
> +
> +#endif	/* _LINUX_SUNRPC_GSS_KRB5_ENCTYPES_H */
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index ac09ca8..83f5617 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -34,6 +34,22 @@ config RPCSEC_GSS_KRB5
>  
>  	  If unsure, say Y.
>  
> +config CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
> +	bool "Secure RPC: Disable insecure Kerberos encryption types"
> +	depends on RPCSEC_GSS_KRB5
> +	default n
> +	help
> +	  Choose Y here to disable the use of deprecated encryption types
> +	  with the Kerberos version 5 GSS-API mechanism (RFC 1964). The
> +	  deprecated encryption types include DES-CBC-MD5, DES-CBC-CRC,
> +	  and DES-CBC-MD4. These types were deprecated by RFC 6649 because
> +	  they were found to be insecure.
> +
> +	  N is the default because many sites have deployed KDCs and
> +	  keytabs that contain only these deprecated encryption types.
> +	  Choosing Y prevents the use of known-insecure encryption types
> +	  but might result in compatibility problems.
> +
>  config SUNRPC_DEBUG
>  	bool "RPC: Enable dprintk debugging"
>  	depends on SUNRPC && SYSCTL
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> index eab71fc..be31a58 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -53,6 +53,7 @@
>  static struct gss_api_mech gss_kerberos_mech;	/* forward declaration */
>  
>  static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
> +#ifndef CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES
>  	/*
>  	 * DES (All DES enctypes are mapped to the same gss functionality)
>  	 */
> @@ -74,6 +75,7 @@
>  	  .cksumlength = 8,
>  	  .keyed_cksum = 0,
>  	},
> +#endif	/* CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES */
>  	/*
>  	 * RC4-HMAC
>  	 */
> 

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc


