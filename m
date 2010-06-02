From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] mount.nfs: silently fails with bad version arguments
Date: Wed, 02 Jun 2010 17:34:41 -0400
Message-ID: <4C06CE71.1020404@oracle.com>
References: <1275486084-23899-1-git-send-email-steved@redhat.com> <1275486084-23899-2-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38157 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697Ab0FBVgQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 17:36:16 -0400
In-Reply-To: <1275486084-23899-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 2/10 09:41 AM, Steve Dickson wrote:
> mount.nfs should not only fail when an invalid protocol
> option is used (as it does), it should also print a
> diagnostic identifying the problem.
>
> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   utils/mount/network.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index c541257..de1014d 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1254,6 +1254,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
>   			nfs_error(_("%s: option parsing error\n"),
>   					progname);

Watch out for case fall-through.  You need to add:

			return 0;

here.

>   		case PO_BAD_VALUE:
> +			nfs_error(_("%s: invalid value for 'vers=' option"),
> +					progname);
>   			return 0;
>   		}
>   	case 4: /* nfsvers */
> @@ -1268,6 +1270,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
>   			nfs_error(_("%s: option parsing error\n"),
>   					progname);

Case fall-through here as well.

>   		case PO_BAD_VALUE:
> +			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
> +					progname);

Why wouldn't you also print a diagnostic if a numeric value was used, 
but the value was out of range?

And, what about similar cases in nfs_nfs_port(), nfs_nfs_program(), 
nfs_mount_program(), nfs_mount_version(), and nfs_mount_port() ?

>   			return 0;
>   		}
>   	}

