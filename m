Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36092 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab1ADU5z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 15:57:55 -0500
Subject: Re: [PATCH_V7 07/12] NFS implement v4.0 callback_ident
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1294173766-5573-8-git-send-email-andros@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
	 <1294173766-5573-2-git-send-email-andros@netapp.com>
	 <1294173766-5573-3-git-send-email-andros@netapp.com>
	 <1294173766-5573-4-git-send-email-andros@netapp.com>
	 <1294173766-5573-5-git-send-email-andros@netapp.com>
	 <1294173766-5573-6-git-send-email-andros@netapp.com>
	 <1294173766-5573-7-git-send-email-andros@netapp.com>
	 <1294173766-5573-8-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 15:57:53 -0500
Message-ID: <1294174673.5896.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 15:42 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Provide a unique callback identifier per SETCLIENTID call used to identify the
> v4.0 callback service associated with the clientid.
> 
> Do not worry about wrap around. Zero value means unset.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c         |    5 +++++
>  fs/nfs/nfs4state.c        |    1 +
>  include/linux/nfs_fs_sb.h |    1 +
>  include/linux/nfs_xdr.h   |    1 +
>  4 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 78b0899..6652e39 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3470,6 +3470,8 @@ do_state_recovery:
>  	return -EAGAIN;
>  }
>  
> +static u32 current_cb_ident = 1;
> +
>  int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  		unsigned short port, struct rpc_cred *cred,
>  		struct nfs4_setclientid_res *res)
> @@ -3478,6 +3480,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  	struct nfs4_setclientid setclientid = {
>  		.sc_verifier = &sc_verifier,
>  		.sc_prog = program,
> +		.sc_cb_ident = current_cb_ident++,

How about instead using ida_get_new() in order to get a truly unique id
in the range 1..0x7fffffff?

> 	};
>  	struct rpc_message msg = {
>  		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
> @@ -3522,6 +3525,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  			if (++clp->cl_id_uniquifier == 0)
>  				break;
>  	}
> +	if (status == NFS_OK)
> +		res->cb_ident = setclientid.sc_cb_ident;
>  	return status;
>  }
>  
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f575a31..fe61422 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -79,6 +79,7 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  	if (status != 0)
>  		goto out;
>  	clp->cl_clientid = clid.clientid;
> +	clp->cl_cb_ident = clid.cb_ident;
>  	nfs4_schedule_state_renewal(clp);
>  out:
>  	return status;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 452d964..1eaa054 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -71,6 +71,7 @@ struct nfs_client {
>  	 */
>  	char			cl_ipaddr[48];
>  	unsigned char		cl_id_uniquifier;
> +	u32			cl_cb_ident;	/* v4.0 callback identifier */
>  	const struct nfs4_minor_version_ops *cl_mvops;
>  #endif /* CONFIG_NFS_V4 */
>  
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 236e7e4..d325def 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -869,6 +869,7 @@ struct nfs4_setclientid {
>  struct nfs4_setclientid_res {
>  	u64				clientid;
>  	nfs4_verifier			confirm;
> +	u32				cb_ident;
>  };
>  
>  struct nfs4_statfs_arg {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

