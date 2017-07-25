Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41412 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751747AbdGYUwP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 16:52:15 -0400
Date: Tue, 25 Jul 2017 16:52:14 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/11] network.c: removed some warnings
Message-ID: <20170725205214.GB15694@fieldses.org>
References: <20170721163806.15803-1-steved@redhat.com>
 <20170721163806.15803-9-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170721163806.15803-9-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 21, 2017 at 12:38:03PM -0400, Steve Dickson wrote:
> network.c:1234:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> network.c:1382:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> network.c:1477:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> network.c:1508:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> network.c:1574:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/network.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 281e935..e56a8d4 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1235,6 +1235,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
>  			*program = tmp;
>  			return 1;
>  		}
> +		/* FALLTHRU */
>  	case PO_BAD_VALUE:
>  		nfs_error(_("%s: invalid value for 'nfsprog=' option"),
>  				progname);
> @@ -1383,6 +1384,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>  			*port = tmp;
>  			return 1;
>  		}
> +		/* FALLTHRU */
>  	case PO_BAD_VALUE:
>  		nfs_error(_("%s: invalid value for 'port=' option"),
>  				progname);
> @@ -1478,6 +1480,7 @@ nfs_mount_program(struct mount_options *options, unsigned long *program)
>  			*program = tmp;
>  			return 1;
>  		}
> +	/* FALLTHRU */

Indentation nit.

--b.

>  	case PO_BAD_VALUE:
>  		nfs_error(_("%s: invalid value for 'mountprog=' option"),
>  				progname);
> @@ -1509,6 +1512,7 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
>  			*version = tmp;
>  			return 1;
>  		}
> +		/* FALLTHRU */
>  	case PO_BAD_VALUE:
>  		nfs_error(_("%s: invalid value for 'mountvers=' option"),
>  				progname);
> @@ -1575,6 +1579,7 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
>  			*port = tmp;
>  			return 1;
>  		}
> +		/* FALLTHRU */
>  	case PO_BAD_VALUE:
>  		nfs_error(_("%s: invalid value for 'mountport=' option"),
>  				progname);
> -- 
> 2.13.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
