Return-Path: <smayhew@redhat.com>
Date: Thu, 11 Jan 2018 08:10:38 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: bcodding@redhat.com, dwysocha@redhat.com, fsorenso@redhat.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs/pnfs: fix nfs_direct_req ref leak when i/o falls
 back to the mds
Message-ID: <20180111131038.vi25s2rvmjgqr3l6@tonberry.usersys.redhat.com>
References: <20171213182220.lrfbvkaj65fg6abk@tonberry.usersys.redhat.com>
 <20171215211232.18942-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171215211232.18942-1-smayhew@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

Trond, Anna,

Any concerns with this patch?

We left this run on multiple machines through the holidays... all doing
direct I/O to a Netapp filer while doing storage failovers on an hourly
basis on the filer.  No more issues with processes getting stuck in
inode_dio_wait.

-Scott

On Fri, 15 Dec 2017, Scott Mayhew wrote:

> Currently when falling back to doing I/O through the MDS (via
> pnfs_{read|write}_through_mds), the client frees the nfs_pgio_header
> without releasing the reference taken on the dreq
> via pnfs_generic_pg_{read|write}pages -> nfs_pgheader_init ->
> nfs_direct_pgio_init.  It then takes another reference on the dreq via
> nfs_generic_pg_pgios -> nfs_pgheader_init -> nfs_direct_pgio_init and
> as a result the requester will become stuck in inode_dio_wait.  Once
> that happens, other processes accessing the inode will become stuck as
> well.
> 
> Ensure that pnfs_read_through_mds() and pnfs_write_through_mds() clean
> up correctly by calling hdr->completion_ops->completion() instead of
> calling hdr->release() directly.
> 
> This can be reproduced (sometimes) by performing "storage failover
> takeover" commands on NetApp filer while doing direct I/O from a client.
> 
> This can also be reproduced using SystemTap to simulate a failure while
> doing direct I/O from a client (from Dave Wysochanski
> <dwysocha@redhat.com>):
> 
> stap -v -g -e 'probe module("nfs_layout_nfsv41_files").function("nfs4_fl_prepare_ds").return { $return=NULL; exit(); }'
> 
> Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/pnfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d602fe9..eb098cc 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2255,7 +2255,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
>  		nfs_pageio_reset_write_mds(desc);
>  		mirror->pg_recoalesce = 1;
>  	}
> -	hdr->release(hdr);
> +	hdr->completion_ops->completion(hdr);
>  }
>  
>  static enum pnfs_try_status
> @@ -2378,7 +2378,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
>  		nfs_pageio_reset_read_mds(desc);
>  		mirror->pg_recoalesce = 1;
>  	}
> -	hdr->release(hdr);
> +	hdr->completion_ops->completion(hdr);
>  }
>  
>  /*
> -- 
> 2.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
