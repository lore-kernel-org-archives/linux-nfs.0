Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab0LOScz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:32:55 -0500
Subject: Re: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten
 layoutreturn struct definitions"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1292437854-21651-1-git-send-email-bhalevy@panasas.com>
References: <4D0908F9.4060208@panasas.com>
	 <1292437854-21651-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 13:32:53 -0500
Message-ID: <1292437973.3068.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-15 at 20:30 +0200, Benny Halevy wrote:
> This reverts commit 19e1e5ae1ec0a3f5d997a1a5d924d482e147bea2.
> ---
>  include/linux/nfs4.h    |    1 +
>  include/linux/nfs_xdr.h |   23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 8ca7700..55511e8 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -557,6 +557,7 @@ enum {
>  	NFSPROC4_CLNT_RECLAIM_COMPLETE,
>  	NFSPROC4_CLNT_LAYOUTGET,
>  	NFSPROC4_CLNT_LAYOUTCOMMIT,
> +	NFSPROC4_CLNT_LAYOUTRETURN,
>  	NFSPROC4_CLNT_GETDEVICEINFO,
>  	NFSPROC4_CLNT_PNFS_WRITE,
>  	NFSPROC4_CLNT_PNFS_COMMIT,
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 9d847ac..a651574 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -258,6 +258,29 @@ struct nfs4_layoutcommit_data {
>  	int status;
>  };
>  
> +struct nfs4_layoutreturn_args {
> +	__u32   reclaim;
> +	__u32   layout_type;
> +	__u32   return_type;
> +	struct pnfs_layout_range range;
> +	struct inode *inode;
> +	struct nfs4_sequence_args seq_args;
> +};
> +
> +struct nfs4_layoutreturn_res {
> +	struct nfs4_sequence_res seq_res;
> +	u32 lrs_present;
> +	nfs4_stateid stateid;
> +};
> +
> +struct nfs4_layoutreturn {
> +	struct nfs4_layoutreturn_args args;
> +	struct nfs4_layoutreturn_res res;
> +	struct rpc_cred *cred;
> +	struct nfs_client *clp;
> +	int rpc_status;
> +};
> +
>  struct nfs4_getdeviceinfo_args {
>  	struct pnfs_device *pdev;
>  	struct nfs4_sequence_args seq_args;

Why? We don't need or even want layoutreturn. It adds too much
serialisation crap.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

