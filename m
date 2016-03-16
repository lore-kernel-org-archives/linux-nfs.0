Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935125AbcCPPYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 11:24:39 -0400
Subject: Re: [PATCH 2/2] NFS add multiaddr mount option
To: andros@netapp.com
References: <1456336559-17334-1-git-send-email-andros@netapp.com>
 <1456336559-17334-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E97AB6.6030209@RedHat.com>
Date: Wed, 16 Mar 2016 11:24:38 -0400
MIME-Version: 1.0
In-Reply-To: <1456336559-17334-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Andy,

Sorry for the delay.... 

On 02/24/2016 12:55 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
Should there be an manpage update as well?

steved.

> ---
>  utils/mount/stropts.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 59 insertions(+)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 75646f6..041bbcd 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -365,6 +365,60 @@ static int nfs_set_version(struct nfsmount_info *mi)
>  	return 1;
>  }
>  
> +/**
> + * Returns 1 if multiaddr= opttion appended successfully
> + * otherwise zero
> + */
> +static int
> +nfs_append_multiaddr_option(char *multinames, struct mount_options *options,
> +				int family)
> +{
> +	struct addrinfo hint = {
> +		.ai_protocol    = (int)IPPROTO_UDP,
> +		.ai_family = family,
> +	};
> +	char *comma, *name;
> +	struct addrinfo *temp;
> +	int error, failed = 1;
> +
> +	if (!multinames)
> +		return 0;
> +
> +	name = multinames;
> +	comma = strchr(name, ',');
> +	while (name != NULL) {
> +		if (comma != NULL)
> +			*comma = '\0';
> +
> +		error = getaddrinfo(name, NULL, &hint, &temp);	
> +		if (error != 0) {
> +			nfs_error(_("%s: Failed to resolve server %s: %s"),
> +				progname, name, gai_strerror(error));
> +			continue;
> +		}
> +
> +		if (!nfs_append_generic_address_option(temp->ai_addr,
> +							temp->ai_addrlen,
> +							"multiaddr", options)) {
> +			nfs_error(_("%s: Failed to append multiaddr %s"),
> +				progname, name);
> +			continue;
> +		}
> +		failed = 0;
> +		if (comma == NULL)
> +			name = NULL;
> +		else {
> +			name = comma +1;
> +			comma = strchr(name, ',');
> +		}
> +	}
> +
> +	if (failed == 1)
> +		return 0;
> +	else
> +		return 1;
> +}
> +
>  /*
>   * Set up mandatory non-version specific NFS mount options.
>   *
> @@ -403,6 +457,11 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>  					mi->address->ai_addrlen, mi->options))
>  		return 0;
>  
> +	if ((mi->version.major == 4 && mi->version.minor > 0))
> +		if (!nfs_append_multiaddr_option(mi->multinames, mi->options,
> +						family))
> +			return 0;
> +
>  	return 1;
>  }
>  
> 
