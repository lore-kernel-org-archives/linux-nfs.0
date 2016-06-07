Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:36784 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161460AbcFGSm3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2016 14:42:29 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfs4: clnt: respect noresvport when establishing
 connections to DSes
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, <linux-nfs@vger.kernel.org>
References: <1464955723-4678-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1464957977-9077-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1464957977-9077-2-git-send-email-tigran.mkrtchyan@desy.de>
CC: Yves Kemp <yves.kemp@desy.de>, Trond Myklebust <trondmy@primarydata.com>
Message-ID: <f08c7718-7fcc-aab9-6935-f41d64f29a45@Netapp.com>
Date: Tue, 7 Jun 2016 14:42:21 -0400
MIME-Version: 1.0
In-Reply-To: <1464957977-9077-2-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran, 

On 06/03/2016 08:46 AM, Tigran Mkrtchyan wrote:
> result:
> 
> $ mount -o vers=4.1 dcache-lab007:/ /pnfs
> $ cp /etc/profile /pnfs
> tcp        0      0 131.169.185.68:1005     131.169.191.141:32049   ESTABLISHED
> tcp        0      0 131.169.185.68:751      131.169.191.144:2049    ESTABLISHED
> $
> 
> $ mount -o vers=4.1,noresvport dcache-lab007:/ /pnfs
> $ cp /etc/profile /pnfs
> tcp        0      0 131.169.185.68:34894    131.169.191.141:32049   ESTABLISHED
> tcp        0      0 131.169.185.68:35722    131.169.191.144:2049    ESTABLISHED
> $
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfs/internal.h   | 1 +
>  fs/nfs/nfs4client.c | 5 ++++-
>  fs/nfs/pnfs_nfs.c   | 2 ++
>  3 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 5154fa6..e8b2192 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -185,6 +185,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
>  extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
>  extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
>  extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> +					     int noresvport,

I wonder if it would be better to change this to a "flags" parameter to open up the possibility of setting other NFS_CS_* values without needing to keep tacking on extra arguments.  What do you think?

I also wonder if it would be easier to have callers pass a struct nfs_client_initdata to this function instead of building one with the provided values.

Thanks,
Anna
>  					     const struct sockaddr *ds_addr,
>  					     int ds_addrlen, int ds_proto,
>  					     unsigned int ds_timeo,
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 10410e8..6cfb5f9 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -842,7 +842,7 @@ error:
>   * low timeout interval so that if a connection is lost, we retry through
>   * the MDS.
>   */
> -struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> +struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp, int noresvport,
>  		const struct sockaddr *ds_addr, int ds_addrlen,
>  		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
>  		u32 minor_version, rpc_authflavor_t au_flavor)
> @@ -863,6 +863,9 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>  		return ERR_PTR(-EINVAL);
>  	cl_init.hostname = buf;
>  
> +	if (noresvport)
> +		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
> +
>  	/*
>  	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
>  	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index 0dfc476..b4ac66d 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -8,6 +8,7 @@
>   */
>  
>  #include <linux/nfs_fs.h>
> +#include <linux/nfs_mount.h>
>  #include <linux/nfs_page.h>
>  #include <linux/sunrpc/addr.h>
>  #include <linux/module.h>
> @@ -683,6 +684,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
>  			__func__, ds->ds_remotestr, da->da_remotestr);
>  
>  		clp = nfs4_set_ds_client(mds_srv->nfs_client,
> +					mds_srv->flags & NFS_MOUNT_NORESVPORT ? 1 : 0,
>  					(struct sockaddr *)&da->da_addr,
>  					da->da_addrlen, IPPROTO_TCP,
>  					timeo, retrans, minor_version,
> 

