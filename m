From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 11/85] nfs41: nfs_client.cl_minorversion
Date: Mon, 17 Nov 2008 15:37:15 +0200
Message-ID: <4921738B.9070605@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348384-7372-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:14747 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752169AbYKQNhS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:37:18 -0500
In-Reply-To: <1226348384-7372-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:19 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> This field is set to the nfsv4 minor version for this mount.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-14: directly set cl_minorversion to data->minorversion in 
callers of nfs4_set_client.

we want to differentiate between autodetect minorersion (-1) and 
one that's explictly set by the mount option. and remember that
for referrals.  keep that as a flag in nfs_client.cl_res_state

On autodetect reclaimer should try with the highest minorversion
and possibly fallback if needed, otherwise try only given
minorversion.  On clone (referral) follow the same algorithm
using the master copy's minorversion configuration.

> ---
>  fs/nfs/client.c           |    1 +
>  include/linux/nfs_fs_sb.h |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index fe0bac9..c6e9b4e 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1030,6 +1030,7 @@ static int nfs4_set_client(struct nfs_server *server,
>  		error = PTR_ERR(clp);
>  		goto error;
>  	}
> +	clp->cl_minorversion = server->minorversion;
>  	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour);
>  	if (error < 0)
>  		goto error_put;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index bfc83cc..8379dd5 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -69,7 +69,8 @@ struct nfs_client {
>  	 */
>  	char			cl_ipaddr[48];
>  	unsigned char		cl_id_uniquifier;
> -#endif
> +	u32			cl_minorversion;
> +#endif /* CONFIG_NFS_V4 */
>  };
>  
>  /*
