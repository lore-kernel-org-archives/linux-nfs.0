Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755772Ab2GETji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 15:39:38 -0400
Message-ID: <4FF5ED2A.1070209@RedHat.com>
Date: Thu, 05 Jul 2012 15:38:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Namjae Jeon <linkinjeon@gmail.com>
CC: bfields@fieldses.org, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Amit Sahrawat <amit.sahrawat83@gmail.com>
Subject: Re: [PATCH] nfs-util: Update exportfs flush option list in usage
 message.
References: <1341037381-24218-1-git-send-email-linkinjeon@gmail.com>
In-Reply-To: <1341037381-24218-1-git-send-email-linkinjeon@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2012 02:23 AM, Namjae Jeon wrote:
> Update exportfs flush option list in usage message.
> And I sort these cases in alphabetical order.
> 
> Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
> Signed-off-by: Amit Sahrawat <amit.sahrawat83@gmail.com>
Committed...

steved.

> ---
>  utils/exportfs/exportfs.c |   21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index a3323d7..9f79541 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -40,7 +40,7 @@ static void	unexportfs(char *arg, int verbose);
>  static void	exports_update(int verbose);
>  static void	dump(int verbose);
>  static void	error(nfs_export *exp, int err);
> -static void	usage(const char *progname);
> +static void	usage(const char *progname, int n);
>  static void	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
>  static void	export_d_read(const char *dname);
> @@ -105,11 +105,17 @@ main(int argc, char **argv)
>  
>  	export_errno = 0;
>  
> -	while ((c = getopt(argc, argv, "aio:ruvf")) != EOF) {
> +	while ((c = getopt(argc, argv, "afhio:ruv")) != EOF) {
>  		switch(c) {
>  		case 'a':
>  			f_all = 1;
>  			break;
> +		case 'f':
> +			force_flush = 1;
> +			break;
> +		case 'h':
> +			usage(progname, 0);
> +			break;
>  		case 'i':
>  			f_ignore = 1;
>  			break;
> @@ -126,11 +132,8 @@ main(int argc, char **argv)
>  		case 'v':
>  			f_verbose = 1;
>  			break;
> -		case 'f':
> -			force_flush = 1;
> -			break;
>  		default:
> -			usage(progname);
> +			usage(progname, 1);
>  			break;
>  		}
>  	}
> @@ -723,8 +726,8 @@ error(nfs_export *exp, int err)
>  }
>  
>  static void
> -usage(const char *progname)
> +usage(const char *progname, int n)
>  {
> -	fprintf(stderr, "usage: %s [-aruv] [host:/path]\n", progname);
> -	exit(1);
> +	fprintf(stderr, "usage: %s [-afhioruv] [host:/path]\n", progname);
> +	exit(n);
>  }
