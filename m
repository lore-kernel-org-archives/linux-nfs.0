From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/5] add blkmapd and spnfsd to list of build targets to
 ignore
Date: Thu, 02 Dec 2010 16:05:57 +0200
Message-ID: <4CF7A7C5.4060904@panasas.com>
References: <cover.1291142529.git.rees@umich.edu> <97564ca3227815598cc59491ad0d6dab59d4d5f5.1291142529.git.rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34458 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757568Ab0LBOGA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 09:06:00 -0500
In-Reply-To: <97564ca3227815598cc59491ad0d6dab59d4d5f5.1291142529.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged in pnfs-nfs-utils-1-2-4-rc3, thanks!

Benny

On 2010-11-30 21:13, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  .gitignore |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/.gitignore b/.gitignore
> index 4bff9e3..6530ae0 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -36,6 +36,7 @@ support/include/stamp-h1
>  lib*.a
>  tools/rpcgen/rpcgen
>  tools/rpcdebug/rpcdebug
> +utils/blkmapd/blkmapd
>  utils/exportfs/exportfs
>  utils/idmapd/idmapd
>  utils/lockd/lockd
> @@ -48,6 +49,7 @@ utils/rquotad/rquotad
>  utils/rquotad/rquota.h
>  utils/rquotad/rquota_xdr.c
>  utils/showmount/showmount
> +utils/spnfsd/spnfsd
>  utils/statd/statd
>  tools/locktest/testlk
>  tools/getiversion/getiversion
