Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:49631 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644AbcF0PUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2016 11:20:23 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 473532804EA
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jun 2016 17:20:21 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 3AE5313E98
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jun 2016 17:20:20 +0200 (MEST)
Date: Mon, 27 Jun 2016 17:20:19 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <17992391.19912565.1467040819602.JavaMail.zimbra@desy.de>
In-Reply-To: <1465840655-3927-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1465840655-3927-1-git-send-email-tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH v2] nfs4: clnt: respect noresvport when establishing
 connections to DSes
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond, Anna,

any update on this (and corresponding one for flexfile layout)?

Tigran.

----- Original Message -----
> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> To: linux-nfs@vger.kernel.org
> Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker" <Anna.Schumaker@netapp.com>, "Tigran
> Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Sent: Monday, June 13, 2016 7:57:35 PM
> Subject: [PATCH v2] nfs4: clnt: respect noresvport when establishing connections to DSes

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
> fs/nfs/internal.h   | 2 +-
> fs/nfs/nfs4client.c | 9 ++++++---
> fs/nfs/pnfs_nfs.c   | 2 +-
> 3 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 5154fa6..67b9345 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -184,7 +184,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server
> *,
> 					   rpc_authflavor_t);
> extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
> extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
> -extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> +extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
> 					     const struct sockaddr *ds_addr,
> 					     int ds_addrlen, int ds_proto,
> 					     unsigned int ds_timeo,
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 10410e8..1d36e7f 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -842,7 +842,7 @@ error:
>  * low timeout interval so that if a connection is lost, we retry through
>  * the MDS.
>  */
> -struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> +struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
> 		const struct sockaddr *ds_addr, int ds_addrlen,
> 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
> 		u32 minor_version, rpc_authflavor_t au_flavor)
> @@ -853,7 +853,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client*
> mds_clp,
> 		.nfs_mod = &nfs_v4,
> 		.proto = ds_proto,
> 		.minorversion = minor_version,
> -		.net = mds_clp->cl_net,
> +		.net = mds_srv->nfs_client->cl_net,
> 	};
> 	struct rpc_timeout ds_timeout;
> 	struct nfs_client *clp;
> @@ -863,13 +863,16 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client*
> mds_clp,
> 		return ERR_PTR(-EINVAL);
> 	cl_init.hostname = buf;
> 
> +	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
> +		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
> +
> 	/*
> 	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
> 	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
> 	 * (section 13.1 RFC 5661).
> 	 */
> 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
> -	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
> +	clp = nfs_get_client(&cl_init, &ds_timeout, mds_srv->nfs_client->cl_ipaddr,
> 			     au_flavor);
> 
> 	dprintk("<-- %s %p\n", __func__, clp);
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index 0dfc476..a3e3157 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -682,7 +682,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server
> *mds_srv,
> 		dprintk("%s: DS %s: trying address %s\n",
> 			__func__, ds->ds_remotestr, da->da_remotestr);
> 
> -		clp = nfs4_set_ds_client(mds_srv->nfs_client,
> +		clp = nfs4_set_ds_client(mds_srv,
> 					(struct sockaddr *)&da->da_addr,
> 					da->da_addrlen, IPPROTO_TCP,
> 					timeo, retrans, minor_version,
> --
> 2.5.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
