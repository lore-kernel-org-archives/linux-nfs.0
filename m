Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36174 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbbFRUfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 16:35:38 -0400
Received: by iecrd14 with SMTP id rd14so62632677iec.3
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 13:35:37 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:35:34 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] pNFS: Fix a memory leak when attempted pnfs fails
Message-ID: <20150618163534.5bc0ac04@tlielax.poochiereds.net>
In-Reply-To: <1434585771-14169-1-git-send-email-trond.myklebust@primarydata.com>
References: <1434585771-14169-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jun 2015 20:02:50 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> pnfs_do_write() expects the call to pnfs_write_through_mds() to free the
> pgio header and to release the layout segment before exiting. The problem
> is that nfs_pgio_data_destroy() doesn't actually do this; it only frees
> the memory allocated by nfs_generic_pgio().
> 
> Ditto for pnfs_do_read()...
> 
> Fix in both cases is to add a call to hdr->release(hdr).
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 230606243be6..219ee6a3f1b3 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1865,6 +1865,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
>  		mirror->pg_recoalesce = 1;
>  	}
>  	nfs_pgio_data_destroy(hdr);
> +	hdr->release(hdr);
>  }
>  
>  static enum pnfs_try_status
> @@ -1979,6 +1980,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
>  		mirror->pg_recoalesce = 1;
>  	}
>  	nfs_pgio_data_destroy(hdr);
> +	hdr->release(hdr);
>  }
>  
>  /*

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
