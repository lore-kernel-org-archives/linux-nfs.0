Return-Path: <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils] mount.nfs: skip server address resolution on
 remount
To: Benjamin Coddington <bcodding@redhat.com>
References: <83c9ef2c8e6c5ece11791e5c39609a1db9f716de.1459967426.git.bcodding@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5721FF10.2050208@RedHat.com>
Date: Thu, 28 Apr 2016 08:16:16 -0400
MIME-Version: 1.0
In-Reply-To: <83c9ef2c8e6c5ece11791e5c39609a1db9f716de.1459967426.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>



On 04/06/2016 02:30 PM, Benjamin Coddington wrote:
> A remount might fail if name resolution returns a different server address,
> as might occur if there are multiple name records for the server.  Since we
> cannot change the server's address on a remount anyway, skip the lookup and
> remove any set addresses in the options.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Committed... 

steved.
> ---
>  utils/mount/stropts.c |   31 ++++++++++++++++++++-----------
>  1 files changed, 20 insertions(+), 11 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 86829a9..634b58c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -383,13 +383,26 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>  	if (!nfs_nfs_proto_family(mi->options, &family))
>  		return 0;
>  
> -	hint.ai_family = (int)family;
> -	error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
> -	if (error != 0) {
> -		nfs_error(_("%s: Failed to resolve server %s: %s"),
> -			progname, mi->hostname, gai_strerror(error));
> -		mi->address = NULL;
> -		return 0;
> +	/*
> +	 * A remount is not going to be able to change the server's address,
> +	 * nor should we try to resolve another address for the server as we
> +	 * may end up with a different address.
> +	 */
> +	if (mi->flags & MS_REMOUNT) {
> +		po_remove_all(mi->options, "addr");
> +	} else {
> +		hint.ai_family = (int)family;
> +		error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
> +		if (error != 0) {
> +			nfs_error(_("%s: Failed to resolve server %s: %s"),
> +				progname, mi->hostname, gai_strerror(error));
> +			mi->address = NULL;
> +			return 0;
> +		}
> +
> +		if (!nfs_append_addr_option(mi->address->ai_addr,
> +						mi->address->ai_addrlen, mi->options))
> +			return 0;
>  	}
>  
>  	if (!nfs_set_version(mi))
> @@ -398,10 +411,6 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>  	if (!nfs_append_sloppy_option(mi->options))
>  		return 0;
>  
> -	if (!nfs_append_addr_option(mi->address->ai_addr,
> -					mi->address->ai_addrlen, mi->options))
> -		return 0;
> -
>  	return 1;
>  }
>  
> 
