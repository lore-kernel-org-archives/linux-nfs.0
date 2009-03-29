From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 06/46] nfs41: Use mount minorversion option
Date: Sun, 29 Mar 2009 12:16:14 -0400
Message-ID: <1238343374.10999.4.camel@heimdal.trondhjem.org>
References: <49ADBD04.2090002@panasas.com>
	 <1236124362-3141-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbZC2QXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Mar 2009 12:23:31 -0400
In-Reply-To: <1236124362-3141-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:52 -0700, Benny Halevy wrote:
> Use the mount minorversion option to initialize the nfs_client
> cl_minorversion
> and match it in nfs_match_client() when looking up a nfs_client.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/client.c |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 2555e48..e9f002f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -101,6 +101,9 @@ struct nfs_client_initdata {
>         size_t addrlen;
>         const struct nfs_rpc_ops *rpc_ops;
>         int proto;
> +#ifdef CONFIG_NFS_V4
> +       u32 minorversion;
> +#endif
>  };
> 
>  /*
> @@ -149,6 +152,7 @@ static struct nfs_client *nfs_alloc_client(const
> struct nfs_client_initdata *cl_
>         rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
>         clp->cl_boot_time = CURRENT_TIME;
>         clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
> +       clp->cl_minorversion = cl_init->minorversion;
>  #endif
>         cred = rpc_lookup_machine_cred();
>         if (!IS_ERR(cred))
> @@ -356,7 +360,11 @@ static struct nfs_client *nfs_match_client(const
> struct nfs_client_initdata *dat
> 
>                 if (clp->cl_proto != data->proto)
>                         continue;
> -
> +#ifdef CONFIG_NFS_V4
> +               /* Match minorversion */
> +               if (clp->cl_minorversion != data->minorversion)
> +                       continue;
> +#endif

This is really ugly and unnecessary. Please just remove those ifdefs,
and have clp->cl_minorversion data->minorversion always defined, and set
to 0.

>                 /* Match the full socket address */
>                 if (memcmp(&clp->cl_addr, data->addr,
> sizeof(clp->cl_addr)) != 0)
>                         continue;
> @@ -1045,6 +1053,7 @@ static int nfs4_set_client(struct nfs_server
> *server,
>                 .addrlen = addrlen,
>                 .rpc_ops = &nfs_v4_clientops,
>                 .proto = proto,
> +               .minorversion = minorversion,

>         };
>         struct nfs_client *clp;
>         int error;
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
