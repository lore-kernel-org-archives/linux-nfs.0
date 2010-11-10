Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og101.obsmtp.com ([64.18.0.141]:34183 "HELO
	exprod5og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753290Ab0KJJh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 04:37:59 -0500
Message-ID: <4CDA67F5.6040207@panasas.com>
Date: Wed, 10 Nov 2010 11:37:57 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] add blkmapd and spnfsd to list of build targets to ignore
References: <20101104173233.GA1681@merit.edu>
In-Reply-To: <20101104173233.GA1681@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I split this patch for spnfs and for blkmapd and
released at pnfs-nfs-utils-1-2-4-rc1-2010-11-04.

Benny
On 2010-11-04 19:32, Jim Rees wrote:
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
