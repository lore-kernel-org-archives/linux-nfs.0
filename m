Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:38474 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab3GXRXG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2013 13:23:06 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 2/2] NFSv4.1 Use the MDS nfs_server authflavor
 for pNFS data server connections
Date: Wed, 24 Jul 2013 17:23:03 +0000
Message-ID: <7777F878-8380-4221-BA15-D24795D1FBB0@netapp.com>
References: <1374681590-2134-1-git-send-email-andros@netapp.com>
 <1374681590-2134-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374681590-2134-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a reason that this is ds specific? Why can't we just do this for cl_rpcclient and get rid of cl_ds_rpcclient?

That way, if there is already an rpcclient with that authflavor associated with an nfs_client we'd reuse it.

-dros

On Jul 24, 2013, at 11:59 AM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> pNFS data servers are not mounted in the normal sense as there is no associated
> nfs_server structure.
> 
> Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
> uses the nfs_client cl_rpcclient for all state management operations, and
> will use krb5i or auth_sys with no regard to the mount command authflavor
> choice.  For normal mounted servers, the nfs_server client authflavor is used
> for all non-state management operations
> 
> Data servers use the same authflavor as the MDS mount for non-state management
> operations. Note that the MDS has performed any sub-mounts and created an
> nfs_server rpc client. Add an array of struct rpc_clnt to struct
> nfs_client, one for each possible auth flavor for data server RPC connections.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/client.c            | 14 +++++++++-
> fs/nfs/nfs4filelayout.c    | 65 ++++++++++++++++++++++++++++++++++++++--------
> fs/nfs/nfs4filelayout.h    | 17 ++++++++++++
> fs/nfs/nfs4filelayoutdev.c |  3 ++-
> include/linux/nfs_fs_sb.h  |  5 ++++
> 5 files changed, 91 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 2dceee4..fc63967 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -152,7 +152,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
> {
> 	struct nfs_client *clp;
> 	struct rpc_cred *cred;
> -	int err = -ENOMEM;
> +	int err = -ENOMEM, i;
> 
> 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
> 		goto error_0;
> @@ -177,6 +177,8 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
> 
> 	INIT_LIST_HEAD(&clp->cl_superblocks);
> 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
> +	for (i = 0; i < NFS_NUM_DS_RPC_CLNT; i++)
> +		clp->cl_ds_clnt[i] = ERR_PTR(-EINVAL);
> 
> 	clp->cl_proto = cl_init->proto;
> 	clp->cl_net = get_net(cl_init->net);
> @@ -238,6 +240,8 @@ static void pnfs_init_server(struct nfs_server *server)
>  */
> void nfs_free_client(struct nfs_client *clp)
> {
> +	int i;
> +
> 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
> 
> 	nfs_fscache_release_client_cookie(clp);
> @@ -246,6 +250,14 @@ void nfs_free_client(struct nfs_client *clp)
> 	if (!IS_ERR(clp->cl_rpcclient))
> 		rpc_shutdown_client(clp->cl_rpcclient);
> 
> +	for (i = 0; i < NFS_NUM_DS_RPC_CLNT; i++) {
> +		if (!IS_ERR(clp->cl_ds_clnt[i])) {
> +			dprintk("%s shutdown data server client %p index %d\n",
> +				__func__, clp->cl_ds_clnt[i], i);
> +			rpc_shutdown_client(clp->cl_ds_clnt[i]);
> +		}
> +	}
> +
> 	if (clp->cl_machine_cred != NULL)
> 		put_rpccred(clp->cl_machine_cred);
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 17ed87e..eb33592 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -83,6 +83,31 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
> 	BUG();
> }
> 
> +/* Use the au_flavor of the MDS nfs_server RPC client to find or clone the
> + * correct data server RPC client.
> + *
> + * Note that the MDS has already performed any sub-mounts and negotiated
> + * a security flavor.
> + */
> +static struct rpc_clnt *
> +filelayout_rpc_clnt(struct inode *inode, struct nfs_client *clp)
> +{
> +	rpc_authflavor_t flavor = NFS_SERVER(inode)->client->cl_auth->au_flavor;
> +	int index = filelayout_rpc_clnt_index(flavor);
> +
> +	if (index < 0)
> +		return ERR_PTR(index);
> +
> +	if (IS_ERR(clp->cl_ds_clnt[index])) {
> +		clp->cl_ds_clnt[index] =
> +			rpc_clone_client_set_auth(clp->cl_rpcclient, flavor);
> +
> +		dprintk("%s clone data server client %p flavor %d index %d \n",
> +			__func__, clp->cl_ds_clnt[index], flavor, index);
> +	}
> +	return clp->cl_ds_clnt[index];
> +}
> +
> static void filelayout_reset_write(struct nfs_write_data *data)
> {
> 	struct nfs_pgio_header *hdr = data->header;
> @@ -524,6 +549,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
> 	struct nfs_pgio_header *hdr = data->header;
> 	struct pnfs_layout_segment *lseg = hdr->lseg;
> 	struct nfs4_pnfs_ds *ds;
> +	struct rpc_clnt *ds_clnt;
> 	loff_t offset = data->args.offset;
> 	u32 j, idx;
> 	struct nfs_fh *fh;
> @@ -538,6 +564,11 @@ filelayout_read_pagelist(struct nfs_read_data *data)
> 	ds = nfs4_fl_prepare_ds(lseg, idx);
> 	if (!ds)
> 		return PNFS_NOT_ATTEMPTED;
> +
> +	ds_clnt = filelayout_rpc_clnt(hdr->inode, ds->ds_clp);
> +	if (IS_ERR(ds_clnt))
> +		return PNFS_NOT_ATTEMPTED;
> +
> 	dprintk("%s USE DS: %s cl_count %d\n", __func__,
> 		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
> 
> @@ -552,8 +583,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
> 	data->mds_offset = offset;
> 
> 	/* Perform an asynchronous read to ds */
> -	nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
> -				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
> +	nfs_initiate_read(ds_clnt, data, &filelayout_read_call_ops,
> +			RPC_TASK_SOFTCONN);
> 	return PNFS_ATTEMPTED;
> }
> 
> @@ -564,6 +595,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
> 	struct nfs_pgio_header *hdr = data->header;
> 	struct pnfs_layout_segment *lseg = hdr->lseg;
> 	struct nfs4_pnfs_ds *ds;
> +	struct rpc_clnt *ds_clnt;
> 	loff_t offset = data->args.offset;
> 	u32 j, idx;
> 	struct nfs_fh *fh;
> @@ -574,6 +606,11 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
> 	ds = nfs4_fl_prepare_ds(lseg, idx);
> 	if (!ds)
> 		return PNFS_NOT_ATTEMPTED;
> +
> +	ds_clnt = filelayout_rpc_clnt(hdr->inode, ds->ds_clp);
> +	if (IS_ERR(ds_clnt))
> +		return PNFS_NOT_ATTEMPTED;
> +
> 	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s cl_count %d\n",
> 		__func__, hdr->inode->i_ino, sync, (size_t) data->args.count,
> 		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
> @@ -591,9 +628,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
> 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
> 
> 	/* Perform an asynchronous write */
> -	nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
> -				    &filelayout_write_call_ops, sync,
> -				    RPC_TASK_SOFTCONN);
> +	nfs_initiate_write(ds_clnt, data, &filelayout_write_call_ops, sync,
> +				RPC_TASK_SOFTCONN);
> 	return PNFS_ATTEMPTED;
> }
> 
> @@ -1101,16 +1137,19 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
> {
> 	struct pnfs_layout_segment *lseg = data->lseg;
> 	struct nfs4_pnfs_ds *ds;
> +	struct rpc_clnt *ds_clnt;
> 	u32 idx;
> 	struct nfs_fh *fh;
> 
> 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
> 	ds = nfs4_fl_prepare_ds(lseg, idx);
> -	if (!ds) {
> -		prepare_to_resend_writes(data);
> -		filelayout_commit_release(data);
> -		return -EAGAIN;
> -	}
> +	if (!ds) 
> +		goto out_err;
> +
> +	ds_clnt = filelayout_rpc_clnt(data->inode, ds->ds_clp);
> +	if (IS_ERR(ds_clnt))
> +		goto out_err;
> +
> 	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
> 		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
> 	data->commit_done_cb = filelayout_commit_done_cb;
> @@ -1119,9 +1158,13 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
> 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
> 	if (fh)
> 		data->args.fh = fh;
> -	return nfs_initiate_commit(ds->ds_clp->cl_rpcclient, data,
> +	return nfs_initiate_commit(ds_clnt, data,
> 				   &filelayout_commit_call_ops, how,
> 				   RPC_TASK_SOFTCONN);
> +out_err:
> +	prepare_to_resend_writes(data);
> +	filelayout_commit_release(data);
> +	return -EAGAIN;
> }
> 
> static int
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index cebd20e..9bb39ec 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -136,6 +136,23 @@ filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
> 	return test_bit(NFS_DEVICEID_INVALID, &node->flags);
> }
> 
> +static inline int
> +filelayout_rpc_clnt_index(rpc_authflavor_t flavor)
> +{
> +	switch (flavor) {
> +		case RPC_AUTH_UNIX:
> +			return 0;
> +		case RPC_AUTH_GSS_KRB5:
> +			return 1;
> +		case RPC_AUTH_GSS_KRB5I:
> +			return 2;
> +		case RPC_AUTH_GSS_KRB5P:
> +			return 3;
> +		default:
> +			return -EINVAL;
> +	}
> +}
> +
> extern bool
> filelayout_test_devid_unavailable(struct nfs4_deviceid_node *node);
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 95604f6..fea056d 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -162,7 +162,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> 	int status = 0;
> 
> 	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
> -		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
> +		mds_srv->client->cl_auth->au_flavor);
> 
> 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
> 		dprintk("%s: DS %s: trying address %s\n",
> @@ -186,6 +186,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> 		goto out_put;
> 
> 	ds->ds_clp = clp;
> +
> 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> out:
> 	return status;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index d221243..bd86a1b 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -20,6 +20,10 @@ struct nfs4_minor_version_ops;
> struct nfs41_server_scope;
> struct nfs41_impl_id;
> 
> +
> +/* One rpc clnt for each authentiction flavor */
> +#define NFS_NUM_DS_RPC_CLNT 4
> +
> /*
>  * The nfs_client identifies our client state to the server.
>  */
> @@ -56,6 +60,7 @@ struct nfs_client {
> 	struct rpc_cred		*cl_machine_cred;
> 
> #if IS_ENABLED(CONFIG_NFS_V4)
> +	struct rpc_clnt *	cl_ds_clnt[NFS_NUM_DS_RPC_CLNT];
> 	u64			cl_clientid;	/* constant */
> 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
> 	unsigned long		cl_state;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

