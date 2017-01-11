Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753413AbdAKQJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 11:09:51 -0500
Subject: Re: [nfs-utils PATCH] nfsstats: fix some exit codes.
To: NeilBrown <neilb@suse.com>
References: <87zij6lddt.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55ad3197-ab8f-06e0-02d5-03de1adc65bd@RedHat.com>
Date: Wed, 11 Jan 2017 11:09:51 -0500
MIME-Version: 1.0
In-Reply-To: <87zij6lddt.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/04/2017 04:32 PM, NeilBrown wrote:
> "nfsstat -m" always exits with "1" (unless there is an error opening
> /proc/mounts).  It should exist "0".
>
> Also, a few usage errors cause an exit of "255" when it should probably
> be "1".
>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed....

steved.
> ---
>  utils/nfsstat/nfsstat.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 8376347d5af4..eddbe9a14f25 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -389,7 +389,7 @@ main(int argc, char **argv)
>  		switch (c) {
>  		case 'a':
>  			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
> -			return -1;
> +			return 1;
>  		case 'c':
>  			opt_clt = 1;
>  			break;
> @@ -455,7 +455,7 @@ main(int argc, char **argv)
>  					"not yet supported\n");
>  			return 2;
>  		case 'm':
> -			return mounts(MOUNTSFILE);
> +			return ! mounts(MOUNTSFILE);
>  		case '\1':
>  			usage(progname);
>  			return 0;
> @@ -464,7 +464,7 @@ main(int argc, char **argv)
>  			return 0;
>  		default:
>  			printf("Try `%s --help' for more information.\n", progname);
> -			return -1;
> +			return 1;
>  		}
>  	}
>  

