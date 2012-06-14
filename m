Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7932 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597Ab2FNVxH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jun 2012 17:53:07 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q5ELqlS9013649
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jun 2012 14:52:47 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 1/1] NFSv4.1 Fix umount when filelayout DS is
 also the MDS
Date: Thu, 14 Jun 2012 21:52:45 +0000
Message-ID: <3CC581F2-5BD8-4BC0-8839-40795BD4BED5@netapp.com>
References: <1339690375-2294-1-git-send-email-andros@netapp.com>
 <1339690375-2294-2-git-send-email-andros@netapp.com>
 <1339694462.2886.35.camel@lade.trondhjem.org>
In-Reply-To: <1339694462.2886.35.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 14, 2012, at 1:21 PM, Myklebust, Trond wrote:

> On Thu, 2012-06-14 at 12:12 -0400, andros@netapp.com wrote:
> 
>> ---
>> fs/nfs/client.c            |   88 ++++++++++++++++++++++++++++++++++++++++++-
>> fs/nfs/internal.h          |    1 +
>> fs/nfs/nfs4filelayoutdev.c |   29 ++++++++++++--
>> include/linux/nfs_fs_sb.h  |    1 +
>> 4 files changed, 112 insertions(+), 7 deletions(-)
> 
> Hi Andy,
> 
> Is there any reason why the following wouldn't work instead? It is
> essentially the same idea.

Hi Trond

Works great - less filling - cool!

ACK

-->Andy

> 
> Cheers
>  Trond
> 8<-------------------------------------------------------
> From dbee3513f10c3324aa0683d415193a5d2af6a31e Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 14 Jun 2012 13:08:38 -0400
> Subject: [PATCH] NFSv4.1: Fix umount when filelayout DS is also the MDS
> 
> Currently there is a 'chicken and egg' issue when the DS is also the mounted
> MDS. The nfs_match_client() reference from nfs4_set_ds_client bumps the
> cl_count, the nfs_client is not freed at umount, and nfs4_deviceid_purge_client
> is not called to dereference the MDS usage of a deviceid which holds a
> reference to the DS nfs_client.  The result is the umount program returns,
> but the nfs_client is not freed, and the cl_session hearbeat continues.
> 
> The MDS (and all other nfs mounts) lose their last nfs_client reference in
> nfs_free_server when the last nfs_server (fsid) is umounted.
> The file layout DS lose their last nfs_client reference in destroy_ds
> when the last deviceid referencing the data server is put and destroy_ds is
> called. This is triggered by a call to nfs4_deviceid_purge_client which
> removes references to a pNFS deviceid used by an MDS mount.
> 
> The fix is to track how many filesystems are mounted from this server,
> and then to purge the device id cache once that count is zero.
> 
> Reported-by: Jorge Mora <Jorge.Mora@netapp.com>
> Reported-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/client.c           |   43 +++++++++++++++++++++++++++++++++++++------
> include/linux/nfs_fs_sb.h |    1 +
> 2 files changed, 38 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 17ba6b9..faa58d5 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -207,16 +207,25 @@ error_0:
> static void nfs4_shutdown_session(struct nfs_client *clp)
> {
> 	if (nfs4_has_session(clp)) {
> -		nfs4_deviceid_purge_client(clp);
> 		nfs4_destroy_session(clp->cl_session);
> 		nfs4_destroy_clientid(clp);
> 	}
> 
> }
> +
> +static void nfs4_purge_dataservers(struct nfs_client *clp)
> +{
> +	if (nfs4_has_session(clp))
> +		nfs4_deviceid_purge_client(clp);
> +}
> #else /* CONFIG_NFS_V4_1 */
> static void nfs4_shutdown_session(struct nfs_client *clp)
> {
> }
> +
> +static void nfs4_purge_dataservers(struct nfs_client *clp)
> +{
> +}
> #endif /* CONFIG_NFS_V4_1 */
> 
> /*
> @@ -801,6 +810,29 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
> 	return 0;
> }
> 
> +static int
> +nfs_server_set_client(struct nfs_server *server, struct nfs_client *clp)
> +{
> +	/* Track the number of filesystems being mounted from this server */
> +	atomic_inc(&clp->cl_server_count);
> +	server->nfs_client = clp;
> +	return 0;
> +}
> +
> +static void
> +nfs_server_unset_client(struct nfs_server *server)
> +{
> +	struct nfs_client *clp = server->nfs_client;
> +
> +	/* Purge the list of pNFS data servers once the number of mounted
> +	 * filesystems falls to zero.
> +	 */
> +	if (atomic_dec_and_test(&clp->cl_server_count))
> +		nfs4_purge_dataservers(clp);
> +
> +	nfs_put_client(clp);
> +}
> +
> /**
>  * nfs_init_client - Initialise an NFS2 or NFS3 client
>  *
> @@ -887,7 +919,7 @@ static int nfs_init_server(struct nfs_server *server,
> 		return PTR_ERR(clp);
> 	}
> 
> -	server->nfs_client = clp;
> +	nfs_server_set_client(server, clp);
> 
> 	/* Initialise the client representation from the mount data */
> 	server->flags = data->flags;
> @@ -934,8 +966,7 @@ static int nfs_init_server(struct nfs_server *server,
> 	return 0;
> 
> error:
> -	server->nfs_client = NULL;
> -	nfs_put_client(clp);
> +	nfs_server_unset_client(server);
> 	dprintk("<-- nfs_init_server() = xerror %d\n", error);
> 	return error;
> }
> @@ -1149,7 +1180,7 @@ void nfs_free_server(struct nfs_server *server)
> 	if (!IS_ERR(server->client))
> 		rpc_shutdown_client(server->client);
> 
> -	nfs_put_client(server->nfs_client);
> +	nfs_server_unset_client(server);
> 
> 	ida_destroy(&server->lockowner_id);
> 	ida_destroy(&server->openowner_id);
> @@ -1469,7 +1500,7 @@ static int nfs4_set_client(struct nfs_server *server,
> 	 */
> 	set_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state);
> 
> -	server->nfs_client = clp;
> +	nfs_server_set_client(server, clp);
> 	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
> 	return 0;
> error:
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index fbb78fb..2d51077 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -25,6 +25,7 @@ struct nfs41_impl_id;
>  */
> struct nfs_client {
> 	atomic_t		cl_count;
> +	atomic_t		cl_server_count;
> 	int			cl_cons_state;	/* current construction state (-ve: init error) */
> #define NFS_CS_READY		0		/* ready to be used */
> #define NFS_CS_INITING		1		/* busy initialising */
> -- 
> 1.7.10.2
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

