Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774AbbCZPaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 11:30:20 -0400
Message-ID: <5514260B.30508@RedHat.com>
Date: Thu, 26 Mar 2015 11:30:19 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - nfs-utils] mount: improve error message when statd cannot
 be started.
References: <20150323164414.7eca921f@notabene.brown>
In-Reply-To: <20150323164414.7eca921f@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/23/2015 01:44 AM, NeilBrown wrote:
> 
> 
> If you try to mount and NFSv3 filesystem, and statd is not running
> and cannot be started (maybe rpcbind isn't running either), the
> error message is:
> 
>   mount.nfs: rpc.statd is not running but is required for remote locking.
>   mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>   mount.nfs: an incorrect mount option was specified
> 
> That last line is incorrect and misleading: no incorret mount option was
> specified.
> 
> This line comes from mount_error() in error.c.  In this case that
> function doesn't really need to provide any more information.
> 
> So introduce a concention that EALREADY means an error message has
> already been printed, and use it to suppress that message.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.

> 
> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index e06f598e96e3..c9797fc380c4 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -247,6 +247,9 @@ void mount_error(const char *spec, const char *mount_point, int error)
>  		nfs_error(_("%s: please report the error to" PACKAGE_BUGREPORT),
>  				progname);
>  		break;
> +	case EALREADY:
> +		/* Error message has already been provided */
> +		break;
>  	default:
>  		nfs_error(_("%s: %s"),
>  			progname, strerror(error));
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 76ecb3292860..df67facdd9d1 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -298,6 +298,7 @@ static int nfs_verify_lock_option(struct mount_options *options)
>  			    "required for remote locking."), progname);
>  		nfs_error(_("%s: Either use '-o nolock' to keep "
>  			    "locks local, or start statd."), progname);
> +		errno = EALREADY; /* Don't print further error message */
>  		return 0;
>  	}
>  
> 
