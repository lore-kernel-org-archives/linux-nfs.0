Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59788 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab0LILD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 06:03:57 -0500
Message-ID: <4D00B79A.3020505@panasas.com>
Date: Thu, 09 Dec 2010 13:03:54 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 2/2] silence compiler warnings
References: <20101203204103.GA9834@merit.edu>
In-Reply-To: <20101203204103.GA9834@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Merged both at pnfs-nfs-utils-1-2-4-rc3-2010-12-03

Thanks!

Benny

On 2010-12-03 22:41, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/device-process.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index 0d8705f..91b0afc 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -53,14 +53,13 @@ static char *pretty_sig(char *sig, uint32_t siglen)
>  {
>  	static char rs[100];
>  	uint64_t sigval;
> +	unsigned int i;
>  
>  	if (siglen <= sizeof(sigval)) {
> -		int i;
> -
>  		sigval = 0;
>  		for (i = 0; i < siglen; i++)
>  			sigval |= ((unsigned char *)sig)[i] << (i * 8);
> -		sprintf(rs, "0x%0llx", sigval);
> +		sprintf(rs, "0x%0llx", (unsigned long long) sigval);
>  	} else {
>  		if (siglen > sizeof rs - 4) {
>  			siglen = sizeof rs - 4;
