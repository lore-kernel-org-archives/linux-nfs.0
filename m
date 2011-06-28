Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44144 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758237Ab1F1QCd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 12:02:33 -0400
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination args
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110628104138.GB6600@d6fc318.ibm.com>
Date: Tue, 28 Jun 2011 12:02:17 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <FA506314-750E-4E20-B80C-B507D032D962@oracle.com>
References: <20110628104138.GB6600@d6fc318.ibm.com>
To: Prem Karat <prem.karat@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 28, 2011, at 6:41 AM, Prem Karat wrote:

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

Yep, that's clear, but why is this desirable?  mount.nfs should be invoked only by the mount command.  It's not meant to be run by humans.

> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
> ---
> utils/mount/mount.c |   13 +++++++++----
> 1 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index f3f0a83..62115bb 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -374,7 +374,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
> int main(int argc, char *argv[])
> {
> 	int c, flags = 0, mnt_err = 1, fake = 0;
> -	char *spec, *mount_point, *fs_type = "nfs";
> +	char *spec = NULL, *mount_point = NULL, *fs_type = "nfs";
> 	char *extra_opts = NULL, *mount_opts = NULL;
> 	uid_t uid = getuid();
> 
> @@ -398,9 +398,6 @@ int main(int argc, char *argv[])
> 		exit(EX_USAGE);
> 	}
> 
> -	spec = argv[1];
> -	mount_point = argv[2];
> -
> 	mount_config_init(progname);
> 
> 	argv[2] = argv[0]; /* so that getopt error messages are correct */
> @@ -447,6 +444,14 @@ int main(int argc, char *argv[])
> 	if (optind != argc - 2) {
> 		mount_usage();
> 		goto out_usage;
> +	} else {
> +		while (optind < argc) {
> +			if (!spec)
> +				spec = argv[optind];
> +			else
> +				mount_point = argv[optind];
> +			optind++;
> +		}
> 	}
> 
> 	if (strcmp(progname, "mount.nfs4") == 0)
> -- 
> 1.7.4
> 
> -- 
> Cheers,
> Prem
> Linux Technology Center,
> IBM Systems & Technology Labs
> DID: 41776362
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




