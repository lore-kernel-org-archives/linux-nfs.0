Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:55844 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071AbbAES0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2015 13:26:35 -0500
Received: by mail-pd0-f175.google.com with SMTP id g10so28667827pdj.34
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 10:26:34 -0800 (PST)
Date: Mon, 5 Jan 2015 10:26:31 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 11/49] pnfs: Add nfs_rpc_ops in calls to
 nfs_initiate_pgio
Message-ID: <20150105182631.GA3268@kitty.kitty>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
 <1419405208-25975-12-git-send-email-loghyr@primarydata.com>
 <54AAD37C.9050401@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54AAD37C.9050401@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 05, 2015 at 01:10:04PM -0500, Anna Schumaker wrote:
> Hey Tom,
> 
> On 12/24/2014 02:12 AM, Tom Haynes wrote:
> > Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> > ---
> >  fs/nfs/filelayout/filelayout.c | 4 ++--
> >  fs/nfs/internal.h              | 1 +
> >  fs/nfs/pagelist.c              | 6 ++++--
> >  fs/nfs/read.c                  | 3 ++-
> >  fs/nfs/write.c                 | 3 ++-
> >  include/linux/nfs_page.h       | 1 +
> >  6 files changed, 12 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> > index bc36ed3..25c4896 100644
> > --- a/fs/nfs/filelayout/filelayout.c
> > +++ b/fs/nfs/filelayout/filelayout.c
> > @@ -501,7 +501,7 @@ filelayout_read_pagelist(struct nfs_pgio_header *hdr)
> >  	hdr->mds_offset = offset;
> >  
> >  	/* Perform an asynchronous read to ds */
> > -	nfs_initiate_pgio(ds_clnt, hdr,
> > +	nfs_initiate_pgio(ds_clnt, hdr, NFS_PROTO(hdr->inode),
> >  			    &filelayout_read_call_ops, 0, RPC_TASK_SOFTCONN);
> >  	return PNFS_ATTEMPTED;
> >  }
> > @@ -542,7 +542,7 @@ filelayout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
> >  	hdr->args.offset = filelayout_get_dserver_offset(lseg, offset);
> >  
> >  	/* Perform an asynchronous write */
> > -	nfs_initiate_pgio(ds_clnt, hdr,
> > +	nfs_initiate_pgio(ds_clnt, hdr, NFS_PROTO(hdr->inode),
> >  				    &filelayout_write_call_ops, sync,
> >  				    RPC_TASK_SOFTCONN);
> >  	return PNFS_ATTEMPTED;
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 5543850..1d15ffa 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -251,6 +251,7 @@ void nfs_pgio_header_free(struct nfs_pgio_header *);
> >  void nfs_pgio_data_destroy(struct nfs_pgio_header *);
> >  int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
> >  int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_header *,
> > +		      const struct nfs_rpc_ops *,
> >  		      const struct rpc_call_ops *, int, int);
> >  void nfs_free_request(struct nfs_page *req);
> >  
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index 2b5e769..35a2626 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -597,6 +597,7 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
> >  }
> >  
> >  int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
> > +		      const struct nfs_rpc_ops *rpc_ops,
> >  		      const struct rpc_call_ops *call_ops, int how, int flags)
> >  {
> >  	struct rpc_task *task;
> > @@ -616,7 +617,7 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
> >  	};
> >  	int ret = 0;
> >  
> > -	hdr->rw_ops->rw_initiate(hdr, &msg, &task_setup_data, how);
> > +	hdr->rw_ops->rw_initiate(hdr, &msg, rpc_ops, &task_setup_data, how);
> >  
> >  	dprintk("NFS: %5u initiated pgio call "
> >  		"(req %s/%llu, %u bytes @ offset %llu)\n",
> > @@ -792,7 +793,8 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
> >  	ret = nfs_generic_pgio(desc, hdr);
> >  	if (ret == 0)
> >  		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
> > -					hdr, desc->pg_rpc_callops,
> > +					hdr, NFS_PROTO(hdr->inode),
> > +					desc->pg_rpc_callops,
> >  					desc->pg_ioflags, 0);
> >  	return ret;
> >  }
> > diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> > index c91a479..092ab49 100644
> > --- a/fs/nfs/read.c
> > +++ b/fs/nfs/read.c
> > @@ -168,13 +168,14 @@ out:
> >  
> >  static void nfs_initiate_read(struct nfs_pgio_header *hdr,
> >  			      struct rpc_message *msg,
> > +			      const struct nfs_rpc_ops *rpc_ops,
> >  			      struct rpc_task_setup *task_setup_data, int how)
> >  {
> >  	struct inode *inode = hdr->inode;
> >  	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
> >  
> >  	task_setup_data->flags |= swap_flags;
> > -	NFS_PROTO(inode)->read_setup(hdr, msg);
> > +	rpc_ops->read_setup(hdr, msg);
> >  }
> >  
> >  static void
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index af3af68..e5ed21c 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -1240,13 +1240,14 @@ static int flush_task_priority(int how)
> >  
> >  static void nfs_initiate_write(struct nfs_pgio_header *hdr,
> >  			       struct rpc_message *msg,
> > +			       const struct nfs_rpc_ops *rpc_ops,
> >  			       struct rpc_task_setup *task_setup_data, int how)
> >  {
> >  	struct inode *inode = hdr->inode;
> >  	int priority = flush_task_priority(how);
> >  
> >  	task_setup_data->priority = priority;
> > -	NFS_PROTO(inode)->write_setup(hdr, msg);
> > +	rpc_ops->write_setup(hdr, msg);
> >  
> >  	nfs4_state_protect_write(NFS_SERVER(inode)->nfs_client,
> >  				 &task_setup_data->rpc_client, msg, hdr);
> 
> When I compile without NFS v4 I get:
> 
> fs/nfs/write.c: In function 'nfs_initiate_write':
> fs/nfs/write.c:1246:16: error: unused variable 'inode' [-Werror=unused-variable]
>   struct inode *inode = hdr->inode;
> 
> The call to nfs4_state_protect_write() is getting optimized out?
> 
> Anna

Hi Anna,

If it is getting optimized out, then the issue is a compiler bug.

I.e., if it optimized out the call, then it should optimize out the
variable and not whine about it.

If you tell it not to optimize, does the warning go away?

Tom

> 
> > diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> > index 6c3e06e..4c3aa80 100644
> > --- a/include/linux/nfs_page.h
> > +++ b/include/linux/nfs_page.h
> > @@ -69,6 +69,7 @@ struct nfs_rw_ops {
> >  			struct inode *);
> >  	void (*rw_result)(struct rpc_task *, struct nfs_pgio_header *);
> >  	void (*rw_initiate)(struct nfs_pgio_header *, struct rpc_message *,
> > +			    const struct nfs_rpc_ops *,
> >  			    struct rpc_task_setup *, int);
> >  };
> >  
> > 
> 
