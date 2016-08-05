Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:53060 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1428151AbcHEWGG convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2016 18:06:06 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Adamson William Andros <andros@netapp.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 7 8/8] NFS pnfs data server multipath session
 trunking
Date: Fri, 5 Aug 2016 22:05:42 +0000
Message-ID: <DDDED45E-EB74-45DE-8D8D-41F4BFADD086@primarydata.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
 <1469645000-19791-9-git-send-email-andros@netapp.com>
In-Reply-To: <1469645000-19791-9-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 27, 2016, at 14:43, andros@netapp.com wrote:
> 
> From: Andy Adamson <andros@netapp.com>
> 
> Try all multipath addresses for a data server. The first address that
> successfully connects and creates a session is the DS mount address.
> All subsequent addresses are tested for session trunking and
> added as aliases.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/nfs4_fs.h  |  2 ++
> fs/nfs/nfs4proc.c |  2 ++
> fs/nfs/pnfs_nfs.c | 52 ++++++++++++++++++++++++++++++++++++++--------------
> 3 files changed, 42 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index b2a94ca..8e4343f 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -59,6 +59,8 @@ struct nfs4_minor_version_ops {
> 			struct nfs4_lock_state *);
> 	struct nfs_seqid *
> 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
> +	int	(*session_trunk)(struct rpc_clnt *, struct rpc_xprt_switch *,
> +			struct rpc_xprt *, void *);
> 	const struct rpc_call_ops *call_sync_ops;
> 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
> 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index fa9ae75..8767720 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -8934,6 +8934,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
> 	.find_root_sec = nfs41_find_root_sec,
> 	.free_lock_state = nfs41_free_lock_state,
> 	.alloc_seqid = nfs_alloc_no_seqid,
> +	.session_trunk = nfs4_test_session_trunk,
> 	.call_sync_ops = &nfs41_call_sync_ops,
> 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
> 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
> @@ -8963,6 +8964,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
> 	.free_lock_state = nfs41_free_lock_state,
> 	.call_sync_ops = &nfs41_call_sync_ops,
> 	.alloc_seqid = nfs_alloc_no_seqid,
> +	.session_trunk = nfs4_test_session_trunk,
> 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
> 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
> 	.state_renewal_ops = &nfs41_state_renewal_ops,
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index f3468b5..7cc1c4d 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -690,13 +690,44 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
> 		dprintk("%s: DS %s: trying address %s\n",
> 			__func__, ds->ds_remotestr, da->da_remotestr);
> 
> -		clp = nfs4_set_ds_client(mds_srv,
> -					(struct sockaddr *)&da->da_addr,
> -					da->da_addrlen, IPPROTO_TCP,
> -					timeo, retrans, minor_version,
> -					au_flavor);
> -		if (!IS_ERR(clp))
> -			break;
> +		if (!IS_ERR(clp) && clp->cl_mvops->session_trunk) {
> +			struct xprt_create xprt_args = {
> +				.ident = XPRT_TRANSPORT_TCP,
> +				.net = clp->cl_net,
> +				.dstaddr = (struct sockaddr *)&da->da_addr,
> +				.addrlen = da->da_addrlen,
> +				.servername = clp->cl_hostname,
> +			};
> +			struct nfs4_add_xprt_data xprtdata = {
> +				.clp = clp,
> +			};
> +			xprtdata.cred = nfs4_get_clid_cred(clp);
> +
> +			/**
> +			* Test this address for session trunking and
> +			* add as an alias
> +			*/
> +			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
> +					  clp->cl_mvops->session_trunk,
> +					  &xprtdata);
> +		} else {
> +			clp = nfs4_set_ds_client(mds_srv,
> +						(struct sockaddr *)&da->da_addr,
> +						da->da_addrlen, IPPROTO_TCP,
> +						timeo, retrans, minor_version,
> +						au_flavor);
> +			if (IS_ERR(clp))
> +				continue;
> +
> +			status = nfs4_init_ds_session(clp,
> +					mds_srv->nfs_client->cl_lease_time);
> +			if (status) {
> +				nfs_put_client(clp);
> +				clp = ERR_PTR(-EIO);
> +				continue;
> +			}
> +
> +		}
> 	}
> 
> 	if (IS_ERR(clp)) {
> @@ -704,18 +735,11 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
> 		goto out;
> 	}
> 
> -	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
> -	if (status)
> -		goto out_put;
> -
> 	smp_wmb();
> 	ds->ds_clp = clp;
> 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> out:
> 	return status;
> -out_put:
> -	nfs_put_client(clp);
> -	goto out;
> }

Is there something which checks whether or not a particular transport has already been added?
Also, doesn’t something need to change in nfs_match_client() so that we can find the struct nfs_client using any of the IP addresses that are registered to it?


