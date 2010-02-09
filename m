From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: make nfs_{nfs,mount}_proto set errno on error
Date: Tue, 09 Feb 2010 11:54:12 -0500
Message-ID: <4B719334.9050705@oracle.com>
References: <1265727888-4613-1-git-send-email-jlayton@redhat.com> <1265727888-4613-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:60757 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab0BIQyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 11:54:55 -0500
In-Reply-To: <1265727888-4613-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On 02/09/2010 10:04 AM, Jeff Layton wrote:
> Have nfs_nfs_proto and nfs_mount_proto set errno to EPROTONOSUPPORT on
> error. This helps default_value to display sane warning messages.
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   utils/mount/network.c |   24 ++++++++++++++++++------
>   1 files changed, 18 insertions(+), 6 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index a12fbe2..f020933 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1273,7 +1273,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
>
>   /*
>    * Returns TRUE if @protocol contains a valid value for this option,
> - * or FALSE if the option was specified with an invalid value.
> + * or FALSE if the option was specified with an invalid value. On
> + * error, errno is set.
>    */
>   int
>   nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
> @@ -1290,8 +1291,13 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
>   		return 1;
>   	case 2: /* proto */
>   		option = po_get(options, "proto");
> -		if (option != NULL)
> -			return nfs_get_proto(option,&family, protocol);
> +		if (option != NULL) {
> +			if (!nfs_get_proto(option,&family, protocol)) {
> +				errno = EPROTONOSUPPORT;
> +				return 0;
> +			}
> +			return 1;
> +		}
>   	}
>
>   	/*
> @@ -1449,7 +1455,8 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
>
>   /*
>    * Returns TRUE if @protocol contains a valid value for this option,
> - * or FALSE if the option was specified with an invalid value.
> + * or FALSE if the option was specified with an invalid value. On
> + * error, errno is set.
>    */
>   static int
>   nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
> @@ -1458,8 +1465,13 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
>   	char *option;
>
>   	option = po_get(options, "mountproto");
> -	if (option != NULL)
> -		return nfs_get_proto(option,&family, protocol);
> +	if (option != NULL) {
> +		if (!nfs_get_proto(option,&family, protocol)) {
> +			errno = EPROTONOSUPPORT;
> +			return 0;
> +		}
> +		return 1;
> +	}
>
>   	/*
>   	 * MNT transport protocol wasn't specified.  If the NFS


-- 
chuck[dot]lever[at]oracle[dot]com
