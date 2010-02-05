From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: Fix the mapping of the NFSERR_SERVERFAULT error
Date: Fri, 05 Feb 2010 18:12:46 -0500
Message-ID: <4B6CA5EE.8080104@oracle.com>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com> <1265409793-18314-2-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53995 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757666Ab0BEXOY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2010 18:14:24 -0500
In-Reply-To: <1265409793-18314-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2010 05:43 PM, Trond Myklebust wrote:
> It was recently pointed out that the NFSERR_SERVERFAULT error, which is
> designed to inform the user of a serious internal error on the server, was
> being mapped to an error value that is internal to the kernel.
>
> This patch maps it to the error EREMOTEIO, which is exported to userland
> through errno.h.
>
> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> Cc: stable@kernel.org
> ---
>   fs/nfs/mount_clnt.c |    2 +-
>   fs/nfs/nfs2xdr.c    |    2 +-
>   fs/nfs/nfs4xdr.c    |    6 +++---
>   3 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index 0adefc4..59047f8 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -120,7 +120,7 @@ static struct {
>   	{ .status = MNT3ERR_INVAL,		.errno = -EINVAL,	},
>   	{ .status = MNT3ERR_NAMETOOLONG,	.errno = -ENAMETOOLONG,	},
>   	{ .status = MNT3ERR_NOTSUPP,		.errno = -ENOTSUPP,	},
> -	{ .status = MNT3ERR_SERVERFAULT,	.errno = -ESERVERFAULT,	},
> +	{ .status = MNT3ERR_SERVERFAULT,	.errno = -EREMOTEIO,	},
>   };
>
>   struct mountres {

The decode_status() and decode_fhs_status() functions return -EACCES if 
they don't recognize the server's error code.  Should they return 
-EREMOTEIO instead?

Otherwise, looks good.

> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> index 5e078b2..7bc2da8 100644
> --- a/fs/nfs/nfs2xdr.c
> +++ b/fs/nfs/nfs2xdr.c
> @@ -699,7 +699,7 @@ static struct {
>   	{ NFSERR_BAD_COOKIE,	-EBADCOOKIE	},
>   	{ NFSERR_NOTSUPP,	-ENOTSUPP	},
>   	{ NFSERR_TOOSMALL,	-ETOOSMALL	},
> -	{ NFSERR_SERVERFAULT,	-ESERVERFAULT	},
> +	{ NFSERR_SERVERFAULT,	-EREMOTEIO	},
>   	{ NFSERR_BADTYPE,	-EBADTYPE	},
>   	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
>   	{ -1,			-EIO		}
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index e437fd6..5cd5184 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4631,7 +4631,7 @@ static int decode_sequence(struct xdr_stream *xdr,
>   	 * If the server returns different values for sessionID, slotID or
>   	 * sequence number, the server is looney tunes.
>   	 */
> -	status = -ESERVERFAULT;
> +	status = -EREMOTEIO;
>
>   	if (memcmp(id.data, res->sr_session->sess_id.data,
>   		   NFS4_MAX_SESSIONID_LEN)) {
> @@ -5774,7 +5774,7 @@ static struct {
>   	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
>   	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
>   	{ NFS4ERR_TOOSMALL,	-ETOOSMALL	},
> -	{ NFS4ERR_SERVERFAULT,	-ESERVERFAULT	},
> +	{ NFS4ERR_SERVERFAULT,	-EREMOTEIO	},
>   	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
>   	{ NFS4ERR_LOCKED,	-EAGAIN		},
>   	{ NFS4ERR_SYMLINK,	-ELOOP		},
> @@ -5801,7 +5801,7 @@ nfs4_stat_to_errno(int stat)
>   	}
>   	if (stat<= 10000 || stat>  10100) {
>   		/* The server is looney tunes. */
> -		return -ESERVERFAULT;
> +		return -EREMOTEIO;
>   	}
>   	/* If we cannot translate the error, the recovery routines should
>   	 * handle it.


-- 
chuck[dot]lever[at]oracle[dot]com
