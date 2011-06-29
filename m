Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971Ab1F2O2Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2011 10:28:25 -0400
Message-ID: <4E0B3687.6060209@RedHat.com>
Date: Wed, 29 Jun 2011 10:28:23 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Prem Karat <prem.karat@linux.vnet.ibm.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com>
In-Reply-To: <20110628104138.GB6600@d6fc318.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/28/2011 06:41 AM, Prem Karat wrote:
> 
> Currently souce and destination parameters should be passed as first and 
> second paramter while using mount.nfs. This patch allows them to be passed 
> anywhere while mounting.
> 
> Current functionality is
> 	mount.nfs source destn -o <options>
> This patch will allow to do this
> 	mount.nfs -o <options> source destn
> 		or
> 	mount.nfs -o <options> source -o <options> destn
> 
> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
Committed...

steved.

> ---
>  utils/mount/mount.c |   13 +++++++++----
>  1 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index f3f0a83..62115bb 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -374,7 +374,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
>  int main(int argc, char *argv[])
>  {
>  	int c, flags = 0, mnt_err = 1, fake = 0;
> -	char *spec, *mount_point, *fs_type = "nfs";
> +	char *spec = NULL, *mount_point = NULL, *fs_type = "nfs";
>  	char *extra_opts = NULL, *mount_opts = NULL;
>  	uid_t uid = getuid();
>  
> @@ -398,9 +398,6 @@ int main(int argc, char *argv[])
>  		exit(EX_USAGE);
>  	}
>  
> -	spec = argv[1];
> -	mount_point = argv[2];
> -
>  	mount_config_init(progname);
>  
>  	argv[2] = argv[0]; /* so that getopt error messages are correct */
> @@ -447,6 +444,14 @@ int main(int argc, char *argv[])
>  	if (optind != argc - 2) {
>  		mount_usage();
>  		goto out_usage;
> +	} else {
> +		while (optind < argc) {
> +			if (!spec)
> +				spec = argv[optind];
> +			else
> +				mount_point = argv[optind];
> +			optind++;
> +		}
>  	}
>  
>  	if (strcmp(progname, "mount.nfs4") == 0)
