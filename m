From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs-utils: Remove blkmapd config file, which is no longer
 used.
Date: Wed, 10 Nov 2010 11:46:31 +0200
Message-ID: <4CDA69F7.4020706@panasas.com>
References: <20101109203949.GA8466@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:60164 "HELO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753196Ab0KJJqe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 04:46:34 -0500
In-Reply-To: <20101109203949.GA8466-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-nfs-utils-1-2-4-rc1-2010-11-04

On 2010-11-09 22:39, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/etc/blkmapd.conf |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)
>  delete mode 100644 utils/blkmapd/etc/blkmapd.conf
> 
> diff --git a/utils/blkmapd/etc/blkmapd.conf b/utils/blkmapd/etc/blkmapd.conf
> deleted file mode 100644
> index da70d94..0000000
> --- a/utils/blkmapd/etc/blkmapd.conf
> +++ /dev/null
> @@ -1,10 +0,0 @@
> -# This is an example config file
> -
> -# Look at all /dev/sd* devices
> -# /dev/sd or /dev/sd*
> -/dev/sd*
> -
> -# Look at all /dev/mapper/* devices
> -# /dev/mapper/* or
> -# /dev/mapper/
> -/dev/mapper/*
