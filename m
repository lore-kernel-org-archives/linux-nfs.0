Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbaAXT2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 14:28:31 -0500
Date: Fri, 24 Jan 2014 14:28:31 -0500
To: Robert Schiele <rschiele@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] use NFS4_MAXMINOR instead of hard coded number
Message-ID: <20140124192830.GA16164@fieldses.org>
References: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 24, 2014 at 07:32:02AM +0100, Robert Schiele wrote:
> In utils/nfsd/nfsd.c we used hard coded number 2 in option parsing
> when referring to NFS4_MAXMINOR.  We should use the defined constant
> instead to honor changes to that constant.

While we're at it, is there any harm to letting NFS4_MAXMINOR be much
higher?  That would save the need to rebuild nfs-utils just because you
want to test a kernel with new minor version support.

It's using an int (should that be an unsigned int?), so we could make
this sizeof(int).

--b.

> 
> Signed-off-by: Robert Schiele <rschiele@gmail.com>
> ---
> 
> This is obviously a rather trivial patch but the hard coded number
> hit me when trying to support various kernels with different support
> levels.
> 
>  utils/nfsd/nfsd.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index a9d77ab..c129ee5 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -160,7 +160,7 @@ main(int argc, char **argv)
>  			case 4:
>  				if (*p == '.') {
>  					int i = atoi(p+1);
> -					if (i > 2) {
> +					if (i > NFS4_MAXMINOR) {
>  						fprintf(stderr, "%s: unsupported minor version\n", optarg);
>  						exit(1);
>  					}
> @@ -181,7 +181,7 @@ main(int argc, char **argv)
>  			case 4:
>  				if (*p == '.') {
>  					int i = atoi(p+1);
> -					if (i > 2) {
> +					if (i > NFS4_MAXMINOR) {
>  						fprintf(stderr, "%s: unsupported minor version\n", optarg);
>  						exit(1);
>  					}
> -- 
> 1.8.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
