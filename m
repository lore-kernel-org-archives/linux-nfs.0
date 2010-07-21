From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 21/24] Removed warnings from network.c
Date: Wed, 21 Jul 2010 13:17:55 -0400
Message-ID: <4C472BC3.5090107@oracle.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-22-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42779 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab0GURTc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 13:19:32 -0400
In-Reply-To: <1279669057-17509-22-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/20/10 07:37 PM, Steve Dickson wrote:
> network.c: In function 'nfs_verify_family':
> network.c:1366: warning: unused parameter 'family'

I thought that the preferred coding style is to keep "#ifdef" out of 
mainline code by having alternate definitions of functions, as was done 
here.

A cleaner solution would be to leave the alternate definition of 
nfs_verify_family() and use

   __attribute__((unused))

for the unused parameter.

> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   utils/mount/network.c |   19 +++++++++----------
>   1 files changed, 9 insertions(+), 10 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index ffb18ab..8d48ce0 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1362,11 +1362,6 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>   #ifdef IPV6_SUPPORTED
>   sa_family_t	config_default_family = AF_UNSPEC;
>
> -static int
> -nfs_verify_family(sa_family_t family)
> -{
> -	return 1;
> -}
>   #else /* IPV6_SUPPORTED */
>   sa_family_t	config_default_family = AF_INET;
>
> @@ -1410,13 +1405,15 @@ int nfs_nfs_proto_family(struct mount_options *options,
>   		}
>   	}
>
> -	if (!nfs_verify_family(tmp_family))
> -		goto out_err;
> +#ifndef IPV6_SUPPORTED
> +	if (!nfs_verify_family(tmp_family)) {
> +		errno = EAFNOSUPPORT;
> +		return 0;
> +	}
> +#endif
> +
>   	*family = tmp_family;
>   	return 1;
> -out_err:
> -	errno = EAFNOSUPPORT;
> -	return 0;
>   }
>
>   /*
> @@ -1566,8 +1563,10 @@ int nfs_mount_proto_family(struct mount_options *options,
>   			errno = EPROTONOSUPPORT;
>   			goto out_err;
>   		}
> +#ifndef IPV6_SUPPORTED
>   		if (!nfs_verify_family(tmp_family))
>   			goto out_err;
> +#endif
>   		*family = tmp_family;
>   		return 1;
>   	}

