Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504AbaJXNht (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2014 09:37:49 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9ODbnFd026339
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 09:37:49 -0400
Message-ID: <544A562C.3090204@RedHat.com>
Date: Fri, 24 Oct 2014 09:37:48 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Karel Zak <kzak@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] umount: make it sensitive to -v
References: <1414145000-16669-1-git-send-email-kzak@redhat.com>
In-Reply-To: <1414145000-16669-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/24/2014 06:03 AM, Karel Zak wrote:
> Let's print verbose messages like original non-libmount version.
> 
> Addresses: https://bugzilla.redhat.com/show_bug.cgi?id=923582
> Signed-off-by: Karel Zak <kzak@redhat.com>
Committed.... Thanks! 

steved.
> ---
>  utils/mount/mount_libmount.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index 6f85dc9..fa46d54 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -174,7 +174,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  {
>  	int rc, c;
>  	char *spec = NULL, *opts = NULL;
> -	int ret = EX_FAIL;
> +	int ret = EX_FAIL, verbose = 0;
>  
>  	static const struct option longopts[] = {
>  		{ "force", 0, 0, 'f' },
> @@ -201,6 +201,8 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  		return EX_USAGE;
>  	}
>  
> +	verbose = mnt_context_is_verbose(cxt);
> +
>  	if (optind < argc)
>  		spec = argv[optind++];
>  
> @@ -228,6 +230,10 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  		goto err;
>  	}
>  
> +	if (verbose)
> +		printf(_("%s: %s mount point detected\n"), spec,
> +					mnt_context_get_fstype(cxt));
> +
>  	opts = retrieve_mount_options(mnt_context_get_fs(cxt));
>  
>  	if (!mnt_context_is_lazy(cxt)) {
> @@ -263,6 +269,12 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  	}
>  	ret = EX_SUCCESS;
>  err:
> +	if (verbose) {
> +		if (ret == EX_SUCCESS)
> +			printf(_("%s: umounted\n"), spec);
> +		else
> +			printf(_("%s: umount failed\n"), spec);
> +	}
>  	free(opts);
>  	return ret;
>  }
> 
