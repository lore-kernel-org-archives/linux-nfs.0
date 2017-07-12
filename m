Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37891 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932074AbdGLRNQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 13:13:16 -0400
Received: by mail-it0-f43.google.com with SMTP id k192so17862630ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 10:13:15 -0700 (PDT)
Subject: Re: [RFC v3 23/42] NFS add a simple sync nfs4_proc_commit after async
 COPY
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-24-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <f2eda78c-943f-ebab-0358-ef527186d656@gmail.com>
Date: Wed, 12 Jul 2017 13:13:12 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-24-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> A COPY with unstable write data needs a simple commit that doesnt
> deal with inodes
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42proc.c | 22 ++++++++++++++++++++++
>  fs/nfs/nfs4_fs.h   |  2 +-
>  fs/nfs/nfs4proc.c  | 33 +++++++++++++++++++++++++++++++++
>  3 files changed, 56 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 09f653d..590bd50 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -289,6 +289,28 @@ static ssize_t _nfs42_proc_copy(struct file *src,
>  			return status;
>  	}
>  
> +	if ((!res->synchronous || !args->sync) &&
> +			res->write_res.verifier.committed != NFS_FILE_SYNC) {
> +		struct nfs_commitres cres;
> +
> +		cres.verf = kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
> +		if (!cres.verf)
> +			return -ENOMEM;
> +
> +		status = nfs4_proc_commit(dst, pos_dst, res->write_res.count,
> +					  &cres);
> +		if (status) {
> +			kfree(cres.verf);
> +			return status;
> +		}
> +		if (!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
> +					    &cres.verf->verifier)) {
> +			/* what are we suppose to do here ? */
> +			dprintk("commit verf differs from copy verf\n");
> +		}
> +		kfree(cres.verf);
> +	}
> +
>  	truncate_pagecache_range(dst_inode, pos_dst,
>  				 pos_dst + res->write_res.count);
>  
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 4ca9657..1b817b4 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -477,7 +477,7 @@ extern int nfs4_sequence_done(struct rpc_task *task,
>  			      struct nfs4_sequence_res *res);
>  
>  extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
> -
> +extern int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res);
>  extern const nfs4_stateid zero_stateid;
>  
>  /* nfs4super.c */
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ecaadb0..c477333 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4749,6 +4749,39 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
>  	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
>  }
>  
> +static int _nfs4_proc_commit(struct file *dst, struct nfs_commitargs *args,
> +				struct nfs_commitres *res)
> +{
> +	struct inode *dst_inode = file_inode(dst);
> +	struct nfs_server *server = NFS_SERVER(dst_inode);
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT],
> +		.rpc_argp = args,
> +		.rpc_resp = res,
> +	};
> +	return nfs4_call_sync(server->client, server, &msg,
> +			&args->seq_args, &res->seq_res, 1);
> +}
> +
> +int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res)
> +{
> +	struct nfs_commitargs args = {
> +		.fh = NFS_FH(file_inode(dst)),
> +		.offset = offset,
> +		.count = count,
> +	};
> +	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
> +	struct nfs4_exception exception = { };
> +	int status;
> +
> +	do {
> +		status = _nfs4_proc_commit(dst, &args, res);
                ^^^^^^
Do you want to check the status here before continuing on to nfs4_handle_exception()?

Thanks,
Anna

> +		status = nfs4_handle_exception(dst_server, status, &exception);
> +	} while (exception.retry);
> +
> +	return status;
> +}
> +
>  struct nfs4_renewdata {
>  	struct nfs_client	*client;
>  	unsigned long		timestamp;
> 
