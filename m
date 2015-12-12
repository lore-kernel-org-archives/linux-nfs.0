Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbbLLMOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:14:46 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id F23B4C0ABF29
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 12:14:45 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-47.rdu2.redhat.com [10.10.54.47])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tBCCEjhw003182
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 07:14:45 -0500
Subject: Re: [PATCH 1/2] rpc.idmapd: Added a usage routine
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1449676902-19575-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0FB5.6030902@RedHat.com>
Date: Sat, 12 Dec 2015 07:14:45 -0500
MIME-Version: 1.0
In-Reply-To: <1449676902-19575-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/09/2015 11:01 AM, Steve Dickson wrote:
> Show the correct arguments when invalid
> arguments are used.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/idmapd/idmapd.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 689608a..910b02e 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -199,6 +199,12 @@ flush_nfsd_idmap_cache(void)
>  	return ret;
>  }
>  
> +void usage(char *progname)
> +{
> +	fprintf(stderr, "Usage: %s [-fvCS] [-p path] [-c path]\n",
> +		basename(progname));
> +}
> +
>  int
>  main(int argc, char **argv)
>  {
> @@ -232,9 +238,11 @@ main(int argc, char **argv)
>  			conf_path = optarg;
>  		if (opt == '?') {
>  			if (strchr(GETOPTSTR, optopt))
> -				errx(1, "'-%c' option requires an argument.", optopt);
> +				warnx("'-%c' option requires an argument.", optopt);
>  			else
> -				errx(1, "'-%c' is an invalid argument.", optopt);
> +				warnx("'-%c' is an invalid argument.", optopt);
> +			usage(progname);
> +			exit(1);
>  		}
>  	}
>  	optind = 1;
> 
