Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35173 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752680AbdGLN42 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 09:56:28 -0400
Received: by mail-io0-f193.google.com with SMTP id 84so2054509iop.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 06:56:28 -0700 (PDT)
Subject: Re: [RFC v3 10/42] NFS export nfs4_async_handle_error
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-11-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <8f0c7b41-4504-2322-70b6-7ad5b25a69ca@gmail.com>
Date: Wed, 12 Jul 2017 09:56:18 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-11-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> Make this function available to nfs42proc.c

I'm confused about why this patch is needed.  Aren't NFS v4.2 and nfs4_async_handle_error()
both built into the NFSv4.ko module?

Anna

> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h  | 3 +++
>  fs/nfs/nfs4proc.c | 3 ++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index af285cc..f5d014e 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -244,6 +244,9 @@ int nfs4_replace_transport(struct nfs_server *server,
>  
>  /* nfs4proc.c */
>  extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
> +extern int nfs4_async_handle_error(struct rpc_task *task,
> +				   struct nfs_server *server,
> +				   struct nfs4_state *state, long *timeout);
>  extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
>  			  struct rpc_message *, struct nfs4_sequence_args *,
>  			  struct nfs4_sequence_res *, int);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b37e528..fdb6b76 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -548,7 +548,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
>  	return ret;
>  }
>  
> -static int
> +int
>  nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
>  			struct nfs4_state *state, long *timeout)
>  {
> @@ -569,6 +569,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
>  		return -EAGAIN;
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(nfs4_async_handle_error);
>  
>  /*
>   * Return 'true' if 'clp' is using an rpc_client that is integrity protected
> 
