Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:33661 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaEBTBw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2014 15:01:52 -0400
Received: by mail-qa0-f44.google.com with SMTP id k15so4794241qaq.31
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2014 12:01:52 -0700 (PDT)
Date: Fri, 2 May 2014 15:01:49 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <dros@primarydata.com>, <hch@infradead.org>
Subject: Re: [PATCH v2 05/17] NFS: Move the write verifier into the
 nfs_pgio_header
Message-ID: <20140502150149.26715288@tlielax.poochiereds.net>
In-Reply-To: <1398459360-2093-6-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
	<1398459360-2093-6-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Apr 2014 16:55:48 -0400
Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> The header had a pointer to the verifier that was set from the old write
> data struct.  We don't need to keep the pointer around now that we have
> shared structures.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/nfs/direct.c         | 4 ++--
>  fs/nfs/write.c          | 7 +++----
>  include/linux/nfs_xdr.h | 3 +--
>  3 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index bbe688e..164b016 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -813,12 +813,12 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>  			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
>  				bit = NFS_IOHDR_NEED_RESCHED;
>  			else if (dreq->flags == 0) {
> -				memcpy(&dreq->verf, hdr->verf,
> +				memcpy(&dreq->verf, &hdr->verf,
>  				       sizeof(dreq->verf));
>  				bit = NFS_IOHDR_NEED_COMMIT;
>  				dreq->flags = NFS_ODIRECT_DO_COMMIT;
>  			} else if (dreq->flags == NFS_ODIRECT_DO_COMMIT) {
> -				if (memcmp(&dreq->verf, hdr->verf, sizeof(dreq->verf))) {
> +				if (memcmp(&dreq->verf, &hdr->verf, sizeof(dreq->verf))) {
>  					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
>  					bit = NFS_IOHDR_NEED_RESCHED;
>  				} else
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 37c4c98..321a791 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -82,7 +82,6 @@ struct nfs_rw_header *nfs_writehdr_alloc(void)
>  		INIT_LIST_HEAD(&hdr->rpc_list);
>  		spin_lock_init(&hdr->lock);
>  		atomic_set(&hdr->refcnt, 0);
> -		hdr->verf = &p->verf;
>  	}
>  	return p;
>  }
> @@ -644,7 +643,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>  			goto next;
>  		}
>  		if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
> -			memcpy(&req->wb_verf, &hdr->verf->verifier, sizeof(req->wb_verf));
> +			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
>  			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>  			goto next;
>  		}
> @@ -1344,8 +1343,8 @@ static void nfs_writeback_release_common(void *calldata)
>  		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
>  			; /* Do nothing */
>  		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags))
> -			memcpy(hdr->verf, &data->verf, sizeof(*hdr->verf));
> -		else if (memcmp(hdr->verf, &data->verf, sizeof(*hdr->verf)))
> +			memcpy(&hdr->verf, &data->verf, sizeof(hdr->verf));
> +		else if (memcmp(&hdr->verf, &data->verf, sizeof(hdr->verf)))
>  			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
>  		spin_unlock(&hdr->lock);
>  	}
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 2d34e0d..965c2aa 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1263,7 +1263,7 @@ struct nfs_pgio_header {
>  	struct list_head	rpc_list;
>  	atomic_t		refcnt;
>  	struct nfs_page		*req;
> -	struct nfs_writeverf	*verf;
> +	struct nfs_writeverf	verf;		/* Used for writes */
>  	struct pnfs_layout_segment *lseg;
>  	loff_t			io_start;
>  	const struct rpc_call_ops *mds_ops;
> @@ -1297,7 +1297,6 @@ struct nfs_pgio_data {
>  struct nfs_rw_header {
>  	struct nfs_pgio_header	header;
>  	struct nfs_pgio_data	rpc_data;
> -	struct nfs_writeverf	verf;
>  };
>  
>  struct nfs_mds_commit_info {

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
