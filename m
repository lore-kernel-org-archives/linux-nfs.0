From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] mount.nfs: silently fails when the network protocol
 is not found
Date: Wed, 02 Jun 2010 17:34:53 -0400
Message-ID: <4C06CE7D.40206@oracle.com>
References: <1275486084-23899-1-git-send-email-steved@redhat.com> <1275486084-23899-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:36595 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab0FBVfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 17:35:20 -0400
In-Reply-To: <1275486084-23899-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 2/10 09:41 AM, Steve Dickson wrote:
> mount.nfs should display some type of error diagnostics when
> the network protocol can not be determined.
>
> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   utils/mount/network.c |   17 +++++++++++++++--
>   utils/mount/stropts.c |   16 +++++++++++-----
>   2 files changed, 26 insertions(+), 7 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index de1014d..74f9cb2 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1307,6 +1307,8 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
>   		if (option != NULL) {
>   			if (!nfs_get_proto(option,&family, protocol)) {
>   				errno = EPROTONOSUPPORT;
> +				nfs_error(_("%s: Failed to find '%s' protocol"),
> +					progname, option);
>   				return 0;
>   			}
>   			return 1;
> @@ -1393,8 +1395,13 @@ int nfs_nfs_proto_family(struct mount_options *options,
>   	case 2: /* proto */
>   		option = po_get(options, "proto");
>   		if (option != NULL&&
> -		    !nfs_get_proto(option,&tmp_family,&protocol))
> +		    !nfs_get_proto(option,&tmp_family,&protocol)) {
> +
> +			nfs_error(_("%s: Failed to find '%s' protocol"),
> +				progname, option);
> +			errno = EPROTONOSUPPORT;
>   			goto out_err;

Code at the out_err label will clobber the errno value you just set here.

> +		}
>   	}
>
>   	if (!nfs_verify_family(tmp_family))
> @@ -1482,6 +1489,8 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
>   	if (option != NULL) {
>   		if (!nfs_get_proto(option,&family, protocol)) {
>   			errno = EPROTONOSUPPORT;
> +			nfs_error(_("%s: Failed to find '%s' protocol"),
> +				progname, option);
>   			return 0;
>   		}
>   		return 1;
> @@ -1539,8 +1548,12 @@ int nfs_mount_proto_family(struct mount_options *options,
>
>   	option = po_get(options, "mountproto");
>   	if (option != NULL) {
> -		if (!nfs_get_proto(option,&tmp_family,&protocol))
> +		if (!nfs_get_proto(option,&tmp_family,&protocol)) {
> +			nfs_error(_("%s: Failed to find '%s' protocol"),
> +				progname, option);
> +			errno = EPROTONOSUPPORT;
>   			goto out_err;
> +		}
>   		if (!nfs_verify_family(tmp_family))
>   			goto out_err;
>   		*family = tmp_family;
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 98557d2..0241400 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -538,7 +538,10 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>
>   	if (!nfs_construct_new_options(options, nfs_saddr,&nfs_pmap,
>   					mnt_saddr,&mnt_pmap)) {
> -		errno = EINVAL;
> +		if (rpc_createerr.cf_stat == RPC_UNKNOWNPROTO)
> +			errno = EPROTONOSUPPORT;
> +		else
> +			errno = EINVAL;

It would be more clear if specific errnos were set in 
nfs_construct_new_options() or the functions it calls.

>   		return 0;
>   	}
>
> @@ -586,18 +589,21 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>   		errno = ENOMEM;
>   		return result;
>   	}
> -
> +	errno = 0;
>   	if (!nfs_append_addr_option(sap, salen, options)) {
> -		errno = EINVAL;
> +		if (errno == 0)
> +			errno = EINVAL;

It might be more clear if nfs_append_addr_option() set the right errno. 
  Likewise for nfs_fix_mounthost_option() and nfs_verify_lock_option().

>   		goto out_fail;
>   	}
>
>   	if (!nfs_fix_mounthost_option(options, mi->hostname)) {
> -		errno = EINVAL;
> +		if (errno == 0)
> +			errno = EINVAL;
>   		goto out_fail;
>   	}
>   	if (!mi->fake&&  !nfs_verify_lock_option(options)) {
> -		errno = EINVAL;
> +		if (errno == 0)
> +			errno = EINVAL;
>   		goto out_fail;
>   	}
>

