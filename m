Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab3KYUIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 15:08:52 -0500
Message-ID: <5293AE90.30004@RedHat.com>
Date: Mon, 25 Nov 2013 15:09:52 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Susant Sahani <ssahani@redhat.com>,
        Libtirpc-devel Mailing List
	<libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH] __nc_error() does not check return value
 from malloc
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com> <1384966173-6229-2-git-send-email-ssahani@redhat.com>
In-Reply-To: <1384966173-6229-2-git-send-email-ssahani@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 20/11/13 11:49, Susant Sahani wrote:
> Signed-off-by: Susant Sahani <ssahani@redhat.com>
Committed.... 

steved.

> ---
>  src/getnetconfig.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/src/getnetconfig.c b/src/getnetconfig.c
> index af4a484..2460a6e 100644
> --- a/src/getnetconfig.c
> +++ b/src/getnetconfig.c
> @@ -146,7 +146,8 @@ __nc_error()
>  			return (&nc_error);
>  	}
>  	if ((nc_addr = (int *)thr_getspecific(nc_key)) == NULL) {
> -		nc_addr = (int *)malloc(sizeof (int));
> +		if((nc_addr = (int *)malloc(sizeof (int))) == NULL)
> +			return (&nc_error);
>  		if (thr_setspecific(nc_key, (void *) nc_addr) != 0) {
>  			if (nc_addr)
>  				free(nc_addr);
> 
