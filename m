Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab1DRUAS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Apr 2011 16:00:18 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p3IK0GLr024572
	for <linux-nfs@vger.kernel.org>; Mon, 18 Apr 2011 13:00:16 -0700 (PDT)
Subject: Re: [PATCH 1/2] Handle NFS4ERR_WRONGSEC outside of
 nfs4_handle_exception()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303156652-5929-1-git-send-email-bjschuma@netapp.com>
References: <1303156652-5929-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Apr 2011 16:00:15 -0400
Message-ID: <1303156815.9731.41.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-04-18 at 15:57 -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> I only want to try other secflavors during an initial mount if
> NFS4ERR_WRONGSEC is returned.  nfs4_handle_exception() could
> potentially map other errors to EPERM, so we should handle this
> error specially for correctness.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> 
> ---
>  fs/nfs/nfs4proc.c |   17 ++++++++++++-----
>  1 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b8e1ac6..152e0eb 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2186,9 +2186,14 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
>  	struct nfs4_exception exception = { };
>  	int err;
>  	do {
> -		err = nfs4_handle_exception(server,
> -				_nfs4_lookup_root(server, fhandle, info),
> -				&exception);
> +		err = _nfs4_lookup_root(server, fhandle, info);
> +		switch (err) {
> +		case 0:
> +		case -NFS4ERR_WRONGSEC:
> +			break;
> +		default:
> +			err = nfs4_handle_exception(server, err, &exception);
> +		}
>  	} while (exception.retry);
>  	return err;
>  }
> @@ -2221,10 +2226,12 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  
>  	for (i = 0; i < len; i++) {
>  		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> -		if (status == -EPERM || status == -EACCES)
> +		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
>  			continue;
>  		break;
>  	}
> +	if (status == -EACCES)
> +		status = -EPERM;

Won't this leak -NFS4ERR_WRONGSEC errors to the user? I think you need
to handle both errors above by mapping them into EPERM.

>  	return status;
>  }
>  
> @@ -2235,7 +2242,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
>  			      struct nfs_fsinfo *info)
>  {
>  	int status = nfs4_lookup_root(server, fhandle, info);
> -	if ((status == -EPERM) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
> +	if ((status == -NFS4ERR_WRONGSEC) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
>  		status = nfs4_find_root_sec(server, fhandle, info);
>  	if (status == 0)
>  		status = nfs4_server_capabilities(server, fhandle);

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

