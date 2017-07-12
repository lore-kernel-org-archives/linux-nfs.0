Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35459 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756776AbdGLMlm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 08:41:42 -0400
Received: by mail-io0-f196.google.com with SMTP id 84so1879500iop.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 05:41:41 -0700 (PDT)
Subject: Re: [RFC v3 05/42] NFS OFFLOAD_STATUS op
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-6-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <b681fd0f-4a58-95c6-92b3-dd7c3f7788dc@gmail.com>
Date: Wed, 12 Jul 2017 08:41:38 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-6-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42.h     |  5 ++++-
>  fs/nfs/nfs42proc.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 46 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> index b6cd153..54b9941 100644
> --- a/fs/nfs/nfs42.h
> +++ b/fs/nfs/nfs42.h
> @@ -12,6 +12,7 @@
>  #define PNFS_LAYOUTSTATS_MAXDEV (4)
>  
>  /* nfs4.2proc.c */
> +#if defined(CONFIG_NFS_V4_2)

This is just me being nitpicky.  Can you move the "#if defined()" check to before
the "/* nfs4.2proc.c */" comment?  I think it would make the code easier to follow,
especially if we ever add more v4.2 files.

Thanks,
Anna

>  int nfs42_proc_allocate(struct file *, loff_t, loff_t);
>  ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
>  int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
> @@ -19,5 +20,7 @@
>  int nfs42_proc_layoutstats_generic(struct nfs_server *,
>  				   struct nfs42_layoutstat_data *);
>  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
> -
> +int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
> +			      struct nfs42_offload_status_res *);
> +#endif /* CONFIG_NFS_V4_2) */
>  #endif /* __LINUX_FS_NFS_NFS4_2_H */
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 6c2db51..5c42e71 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -263,6 +263,48 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
>  	return err;
>  }
>  
> +int _nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
> +				struct nfs42_offload_status_res *res)
> +{
> +	struct nfs42_offload_status_args args;
> +	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OFFLOAD_STATUS],
> +		.rpc_resp = res,
> +		.rpc_argp = &args,
> +	};
> +	int status;
> +
> +	args.osa_src_fh = NFS_FH(file_inode(dst));
> +	memcpy(&args.osa_stateid, stateid, sizeof(args.osa_stateid));
> +	status = nfs4_call_sync(dst_server->client, dst_server, &msg,
> +				&args.osa_seq_args, &res->osr_seq_res, 0);
> +	if (status == -ENOTSUPP)
> +		dst_server->caps &= ~NFS_CAP_OFFLOAD_STATUS;
> +
> +	return status;
> +}
> +
> +int nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
> +				struct nfs42_offload_status_res *res)
> +{
> +	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
> +	struct nfs4_exception exception = { };
> +	int status;
> +
> +	if (!(dst_server->caps & NFS_CAP_OFFLOAD_STATUS))
> +		return -EOPNOTSUPP;
> +
> +	do {
> +		status = _nfs42_proc_offload_status(dst, stateid, res);
> +		if (status == -ENOTSUPP)
> +			return -EOPNOTSUPP;
> +		status = nfs4_handle_exception(dst_server, status, &exception);
> +	} while (exception.retry);
> +
> +	return status;
> +}
> +
>  static loff_t _nfs42_proc_llseek(struct file *filep,
>  		struct nfs_lock_context *lock, loff_t offset, int whence)
>  {
> 
