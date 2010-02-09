From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: return error if proto= option specified IPv6
 when IPv6 isn't supported (try #2)
Date: Tue, 09 Feb 2010 11:53:23 -0500
Message-ID: <4B719303.3050309@oracle.com>
References: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:65246 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972Ab0BIQyu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 11:54:50 -0500
In-Reply-To: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On 02/09/2010 10:04 AM, Jeff Layton wrote:
> Right now, there's nothing that expressly forbids someone from
> specifying proto=tcp6 for instance, even when nfs-utils it built without
> IPv6 support. This may not work well if (for instance) they are using
> NFSv3, since statd won't support IPv6. Explicitly return an error if
> someone specifies an IPv6 proto= or mountproto= option and IPv6 isn't
> supported.
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   utils/mount/network.c |   59 +++++++++++++++++++++++++++++++++++-------------
>   1 files changed, 43 insertions(+), 16 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index c400dd8..a12fbe2 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1334,21 +1334,36 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
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
> +	if (family != AF_INET)
> +		return 0;
> +
> +	return 1;
> +}
> +#endif /* IPV6_SUPPORTED */
>
>   /*
>    * Returns TRUE and fills in @family if a valid NFS protocol option
> - * is found, or FALSE if the option was specified with an invalid value.
> + * is found, or FALSE if the option was specified with an invalid value
> + * or if the protocol family isn't supported. On error, errno is set.
>    */
>   int nfs_nfs_proto_family(struct mount_options *options,
>   				sa_family_t *family)
>   {
>   	unsigned long protocol;
>   	char *option;
> -
> -	*family = config_default_family;
> +	sa_family_t tmp_family = config_default_family;
>
>   	switch (po_rightmost(options, nfs_transport_opttbl)) {
>   	case 0:	/* udp */
> @@ -1357,15 +1372,18 @@ int nfs_nfs_proto_family(struct mount_options *options,
>   		return 1;
>   	case 2: /* proto */
>   		option = po_get(options, "proto");
> -		if (option != NULL)
> -			return nfs_get_proto(option, family,&protocol);
> +		if (option != NULL&&
> +		    !nfs_get_proto(option,&tmp_family,&protocol))
> +			goto out_err;
>   	}
>
> -	/*
> -	 * NFS transport protocol wasn't specified.  Return the
> -	 * default address family.
> -	 */
> +	if (!nfs_verify_family(tmp_family))
> +		goto out_err;
> +	*family = tmp_family;
>   	return 1;
> +out_err:
> +	errno = EAFNOSUPPORT;
> +	return 0;
>   }
>
>   /*
> @@ -1483,19 +1501,25 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
>
>   /*
>    * Returns TRUE and fills in @family if a valid MNT protocol option
> - * is found, or FALSE if the option was specified with an invalid value.
> + * is found, or FALSE if the option was specified with an invalid value
> + * or if the protocol family isn't supported. On error, errno is set.
>    */
>   int nfs_mount_proto_family(struct mount_options *options,
>   				sa_family_t *family)
>   {
>   	unsigned long protocol;
>   	char *option;
> -
> -	*family = config_default_family;
> +	sa_family_t tmp_family = config_default_family;
>
>   	option = po_get(options, "mountproto");
> -	if (option != NULL)
> -		return nfs_get_proto(option, family,&protocol);
> +	if (option != NULL) {
> +		if (!nfs_get_proto(option,&tmp_family,&protocol))
> +			goto out_err;
> +		if (!nfs_verify_family(tmp_family))
> +			goto out_err;
> +		*family = tmp_family;
> +		return 1;
> +	}
>
>   	/*
>   	 * MNT transport protocol wasn't specified.  If the NFS
> @@ -1504,6 +1528,9 @@ int nfs_mount_proto_family(struct mount_options *options,
>   	 * NFS.
>   	 */
>   	return nfs_nfs_proto_family(options, family);
> +out_err:
> +	errno = EAFNOSUPPORT;
> +	return 0;
>   }
>
>   /**


-- 
chuck[dot]lever[at]oracle[dot]com
