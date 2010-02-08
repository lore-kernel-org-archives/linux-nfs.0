From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: return error if proto= option specified IPv6
 when IPv6 isn't supported
Date: Mon, 08 Feb 2010 12:27:24 -0500
Message-ID: <4B70497C.909@oracle.com>
References: <1265649242-5063-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29608 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab0BHR2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 12:28:01 -0500
In-Reply-To: <1265649242-5063-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/2010 12:14 PM, Jeff Layton wrote:
> Right now, there's nothing that expressly forbids someone from
> specifying proto=tcp6 for instance, even when nfs-utils it built without
> IPv6 support. This may not work well if (for instance) they are using
> NFSv3, since statd won't support IPv6. Explicitly return an error if
> someone specifies an IPv6 proto= or mountproto= option and IPv6 isn't
> supported.
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   utils/mount/network.c |   34 +++++++++++++++++++++++++++-------
>   1 files changed, 27 insertions(+), 7 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index c400dd8..ad165f4 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1334,9 +1334,26 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>
>   #ifdef IPV6_SUPPORTED
>   sa_family_t	config_default_family = AF_UNSPEC;
> -#else
> +
> +static int
> +nfs_verify_family(sa_family_t family)
> +{
> +	return 1;
> +}
> +#else /* IPV6_SUPPORTED */
>   sa_family_t	config_default_family = AF_INET;
> -#endif
> +
> +static int
> +nfs_verify_family(sa_family_t family)
> +{
> +	if (family != AF_INET) {
> +		errno = EAFNOSUPPORT;
> +		return 0;

I assume you do this so that mount.nfs emits a proper error message in 
this case.  What about below where nfs_get_proto() returns false?

> +	}
> +
> +	return 1;
> +}
> +#endif /* IPV6_SUPPORTED */
>
>   /*
>    * Returns TRUE and fills in @family if a valid NFS protocol option
> @@ -1357,15 +1374,15 @@ int nfs_nfs_proto_family(struct mount_options *options,
>   		return 1;
>   	case 2: /* proto */
>   		option = po_get(options, "proto");
> -		if (option != NULL)
> -			return nfs_get_proto(option, family,&protocol);
> +		if (option != NULL&&  !nfs_get_proto(option, family,&protocol))
> +			return 0;
>   	}
>
>   	/*
>   	 * NFS transport protocol wasn't specified.  Return the
>   	 * default address family.
>   	 */

It would help if this comment mentioned why you need to verify *family 
in the default case.

> -	return 1;
> +	return nfs_verify_family(*family);
>   }
>
>   /*
> @@ -1494,8 +1511,11 @@ int nfs_mount_proto_family(struct mount_options *options,
>   	*family = config_default_family;
>
>   	option = po_get(options, "mountproto");
> -	if (option != NULL)
> -		return nfs_get_proto(option, family,&protocol);
> +	if (option != NULL) {
> +		if (!nfs_get_proto(option, family,&protocol))
> +			return 0;
> +		return nfs_verify_family(*family);
> +	}
>
>   	/*
>   	 * MNT transport protocol wasn't specified.  If the NFS

-- 
chuck[dot]lever[at]oracle[dot]com
