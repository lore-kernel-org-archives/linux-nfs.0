From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/5] Remove blkmapd config file, which is no longer used.
Date: Thu, 02 Dec 2010 16:06:07 +0200
Message-ID: <4CF7A7CF.2020203@panasas.com>
References: <cover.1291142529.git.rees@umich.edu> <309616ffb6726328d0057891b606a3bc1c909f6c.1291142529.git.rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34468 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757620Ab0LBOGJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 09:06:09 -0500
In-Reply-To: <309616ffb6726328d0057891b606a3bc1c909f6c.1291142529.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged in pnfs-nfs-utils-1-2-4-rc3, thanks!

Benny

On 2010-11-30 21:13, Jim Rees wrote:
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
