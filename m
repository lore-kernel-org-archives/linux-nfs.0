Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60568 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935863AbdGTS2Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 14:28:24 -0400
Date: Thu, 20 Jul 2017 14:28:24 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/11] nfsd.c: removed a few warnings
Message-ID: <20170720182824.GB19909@fieldses.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-6-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170719205354.10006-6-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 19, 2017 at 04:53:48PM -0400, Steve Dickson wrote:
> nfsd.c:187:8: warning: this statement may fall through [-Wimplicit-fallthrough=]
> nfsd.c:213:8: warning: this statement may fall through [-Wimplicit-fallthrough=]nfsd.c:263:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

Are you sure about this?  It looks to me like the fall through was
intended in the -N4 and -V4 cases.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/nfsd/nfsd.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 2b38249..1d35658 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -198,6 +198,7 @@ main(int argc, char **argv)
>  					minorvers = 0;
>  					minorversset = minormask;
>  				}
> +				break;
>  			case 3:
>  			case 2:
>  				NFSCTL_VERUNSET(versbits, c);
> @@ -220,6 +221,7 @@ main(int argc, char **argv)
>  					NFSCTL_MINORSET(minorvers, i);
>  				} else
>  					minorvers = minorversset = minormask;
> +				break;
>  			case 3:
>  			case 2:
>  				NFSCTL_VERSET(versbits, c);
> @@ -261,8 +263,9 @@ main(int argc, char **argv)
>  			break;
>  		default:
>  			fprintf(stderr, "Invalid argument: '%c'\n", c);
> +			/* FALLTHRU */
>  		case 'h':
> -			usage(progname);
> +			usage(progname); /* usage does not return */
>  		}
>  	}
>  
> -- 
> 2.13.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
