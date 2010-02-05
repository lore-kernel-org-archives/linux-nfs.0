From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: set the default family for lookups based on
 Defaultproto= setting
Date: Fri, 05 Feb 2010 10:31:28 -0500
Message-ID: <4B6C39D0.3030704@oracle.com>
References: <1265380055-5650-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43491 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0BEPcp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2010 10:32:45 -0500
In-Reply-To: <1265380055-5650-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2010 09:27 AM, Jeff Layton wrote:
> When IPv6 is enabled, the Proto= config file option is treated as a
> netid, and the address family for lookups is selected based on that
> setting. The Defaultproto= option however still only affects the
> protocol setting for the sockets (IPPROTO_*) and not the address family.
>
> This patch makes it so that if someone sets the "Defaultproto=" option
> in the nfsmount.conf, it's used to determine the default address family
> for lookups as well as the protocol type.
>
> This gives users a way to force a particular address family to be used
> universally for mounts and brings the behavior of the Defaultproto=
> option in line with the Proto= option.
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   utils/mount/configfile.c |    8 ++++++++
>   utils/mount/network.c    |   18 ++++++++----------
>   2 files changed, 16 insertions(+), 10 deletions(-)
>
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 6843098..71d3627 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -221,6 +221,8 @@ int inline check_vers(char *mopt, char *field)
>
>   unsigned long config_default_vers;
>   unsigned long config_default_proto;
> +extern sa_family_t config_default_family;
> +
>   /*
>    * Check to see if a default value is being set.
>    * If so, set the appropriate global value which will
> @@ -242,6 +244,12 @@ int inline default_value(char *mopt)
>   				xlog_warn("Unable to set default protocol : %s",
>   					strerror(errno));
>   			}
> +#ifdef IPV6_SUPPORTED
> +			if (!nfs_nfs_proto_family(options,&config_default_family)) {
> +				xlog_warn("Unable to set default family : %s",
> +					strerror(errno));
> +			}
> +#endif

Maybe you don't need the #ifdef here?

Aside from making the code more readable, removing the #ifdef would also 
make it so the same code path is followed whether IPv6 is supported or 
not, which makes testing easier.

Just a thought.

>   		} else {
>   			xlog_warn("Unable to alloc memory for default protocol");
>   		}
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 92bba2d..0ab3bb1 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1331,6 +1331,12 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>   	return 1;
>   }
>
> +#ifdef IPV6_SUPPORTED
> +sa_family_t	config_default_family = AF_UNSPEC;
> +#else
> +sa_family_t	config_default_family = AF_INET;
> +#endif
> +
>   /*
>    * Returns TRUE and fills in @family if a valid NFS protocol option
>    * is found, or FALSE if the option was specified with an invalid value.
> @@ -1341,11 +1347,7 @@ int nfs_nfs_proto_family(struct mount_options *options,
>   	unsigned long protocol;
>   	char *option;
>
> -#ifdef IPV6_SUPPORTED
> -	*family = AF_UNSPEC;
> -#else
> -	*family = AF_INET;
> -#endif
> +	*family = config_default_family;
>
>   	switch (po_rightmost(options, nfs_transport_opttbl)) {
>   	case 0:	/* udp */
> @@ -1488,11 +1490,7 @@ int nfs_mount_proto_family(struct mount_options *options,
>   	unsigned long protocol;
>   	char *option;
>
> -#ifdef HAVE_LIBTIRPC
> -	*family = AF_UNSPEC;
> -#else
> -	*family = AF_INET;
> -#endif
> +	*family = config_default_family;
>
>   	option = po_get(options, "mountproto");
>   	if (option != NULL)


-- 
chuck[dot]lever[at]oracle[dot]com
