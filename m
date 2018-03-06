Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39330 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932537AbeCFPfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Mar 2018 10:35:03 -0500
Date: Tue, 6 Mar 2018 10:35:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kenneth Dsouza <kdsouza@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Switch to getopt instead of parsing the flags by hand.
Message-ID: <20180306153502.GB7099@fieldses.org>
References: <20180305171806.9576-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180305171806.9576-1-kdsouza@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied, thanks.--b.

On Mon, Mar 05, 2018 at 10:48:06PM +0530, Kenneth Dsouza wrote:
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> ---
>  nfs4_getfacl/nfs4_getfacl.c | 62 ++++++++++++++++++++++++++++++---------------
>  1 file changed, 41 insertions(+), 21 deletions(-)
> 
> diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
> index 1705d35..5a9c911 100644
> --- a/nfs4_getfacl/nfs4_getfacl.c
> +++ b/nfs4_getfacl/nfs4_getfacl.c
> @@ -40,6 +40,7 @@
>  #include <libgen.h>
>  #include "libacl_nfs4.h"
>  #include <ftw.h>
> +#include <getopt.h>
>  
>  static void usage(int);
>  static void more_help();
> @@ -52,10 +53,17 @@ static int recursive(const char *fpath, const struct stat *sb, int tflag, struct
>  	return 0;
>  }
>  
> +static struct option long_options[] = {
> +        {"more-help",    0, 0, 'H' },
> +        {"help",         0, 0, 'h' },
> +        {"recursive",     0, 0, 'R' },
> +        { NULL,          0, 0, 0,  },
> +};
> +
>  int main(int argc, char **argv)
>  {
> -	int res = 1;
> -	int counter = 1;
> +	int opt, res = 1;
> +        int do_recursive = 0;
>  	
>  	execname = basename(argv[0]);
>  
> @@ -63,27 +71,39 @@ int main(int argc, char **argv)
>  		fprintf(stderr, "%s: you must specify a path.\n", execname);
>  		usage(0);
>  		goto out;
> -	} else if (!strcmp(argv[1], "-?") || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
> -		usage(1);
> -		res = 0;
> -		goto out;
> -	} else if (!strcmp(argv[1], "-H") || !strcmp(argv[1], "--more-help")) {
> -		more_help();
> -		res = 0;
> -		goto out;
> -	} else if (!strcmp(argv[1], "-R") || !strcmp(argv[1], "--recursive")) {
> -		if (argc < 3)
> -			usage(1);
> -		for(counter = 2; counter < argc; counter++) {
> -			if (nftw(argv[counter], recursive, 20, 0) == -1) {
> -				printf("Invalid filename: %s\n", argv[counter]);
> -			}
> +	}
> +
> +	while ((opt = getopt_long(argc, argv, "HR?h", long_options, NULL)) != -1) {
> +		switch(opt) {
> +			case 'H':
> +				more_help();
> +				res = 0;
> +				goto out;
> +
> +			case 'R':
> +				do_recursive = 1;
> +				break;
> +
> +			default:
> +				usage(1);
> +				res = 0;
> +				goto out;
>  		}
> -		res = 0;
> +	}
> +
> +	if (optind >= argc) {
> +		fprintf(stderr, "%s: you must specify a path after options.\n", execname);
> +		usage(0);
>  		goto out;
>  	}
> -	for (counter = 1; counter < argc; counter++) {
> -		print_acl_from_path(argv[counter]);
> +
> +	for(; optind < argc; optind++) {
> +		if(do_recursive) {
> +			if (nftw(argv[optind], recursive, 20, 0) == -1)
> +				printf("Invalid filename: %s\n", argv[optind]);
> +		}
> +		else
> +			print_acl_from_path(argv[optind]);
>  		res = 0;
>  	}
>  out:
> @@ -105,7 +125,7 @@ static void usage(int label)
>  {
>  	if (label)
>  		fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> -	fprintf(stderr, "Usage: %s file\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> +	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
>  }
>  
>  static void more_help()
> -- 
> 2.9.5
