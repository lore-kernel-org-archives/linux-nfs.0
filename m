From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 04/46] nfs41: nfs_client.cl_minorversion
Date: Sun, 29 Mar 2009 12:02:42 -0400
Message-ID: <1238342562.10999.0.camel@heimdal.trondhjem.org>
References: <49ADBD04.2090002@panasas.com>
	 <1236124341-3091-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757807AbZC2QD3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Mar 2009 12:03:29 -0400
In-Reply-To: <1236124341-3091-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:52 -0700, Benny Halevy wrote:
> This field is set to the nfsv4 minor version for this mount.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> 
> Note: This patch sets the referral to the same minorversion as the
> current mount. Revisit in future patch.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [removed cl_minorversion assignment in nfs_set_client]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/client.c           |    9 ++++++---
>  include/linux/nfs_fs_sb.h |    3 ++-
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..2555e48 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1036,7 +1036,8 @@ static int nfs4_set_client(struct nfs_server
> *server,
>                 const size_t addrlen,
>                 const char *ip_addr,
>                 rpc_authflavor_t authflavour,
> -               int proto, const struct rpc_timeout *timeparms)
> +               int proto, const struct rpc_timeout *timeparms,
> +               u32 minorversion)
>  {
>         struct nfs_client_initdata cl_init = {
>                 .hostname = hostname,
> @@ -1098,7 +1099,8 @@ static int nfs4_init_server(struct nfs_server
> *server,
>                         data->client_address,
>                         data->auth_flavors[0],
>                         data->nfs_server.protocol,
> -                       &timeparms);
> +                       &timeparms,
> +                       data->minorversion);

This can't compile. There is no minor version field in the mount
structure yet.

>         if (error < 0)
>                 goto error;
> 
> @@ -1216,7 +1218,8 @@ struct nfs_server
> *nfs4_create_referral_server(struct nfs_clone_mount *data,
>                                 parent_client->cl_ipaddr,
>                                 data->authflavor,
>                                 parent_server->client->cl_xprt->prot,
> -                               parent_server->client->cl_timeout);
> +                               parent_server->client->cl_timeout,
> +                               parent_client->cl_minorversion);
>         if (error < 0)
>                 goto error;
> 
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 9bb81ae..63f8b00 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -63,7 +63,8 @@ struct nfs_client {
>          */
>         char                    cl_ipaddr[48];
>         unsigned char           cl_id_uniquifier;
> -#endif
> +       u32                     cl_minorversion;
> +#endif /* CONFIG_NFS_V4 */
>  };
> 
>  /*
> --
> 1.6.1.3
> 
> 
> 
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
