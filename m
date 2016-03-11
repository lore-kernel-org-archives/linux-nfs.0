Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54968 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbcCKWwt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Mar 2016 17:52:49 -0500
Date: Fri, 11 Mar 2016 17:52:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd: add SCSI layout support
Message-ID: <20160311225247.GA18755@fieldses.org>
References: <1457120777-30687-1-git-send-email-hch@lst.de>
 <1457120777-30687-5-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457120777-30687-5-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 04, 2016 at 08:46:17PM +0100, Christoph Hellwig wrote:
> This is a simple extension to the block layout driver to use SCSI
> persistent reservations for access control and fencing, as well as
> SCSI VPD pages for device identification.
> 
> For this we need to pass the nfs4_client to the proc_getdeviceinfo method
> to generate the reservation key, and add a new fence_client method
> to allow for fence actions in the layout driver.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/filesystems/nfs/pnfs-scsi-server.txt |  22 ++
>  fs/nfsd/Kconfig                                    |  13 +
>  fs/nfsd/Makefile                                   |   1 +
>  fs/nfsd/blocklayout.c                              | 298 ++++++++++++++++++---
>  fs/nfsd/blocklayoutxdr.c                           |  65 ++++-
>  fs/nfsd/blocklayoutxdr.h                           |  14 +
>  fs/nfsd/nfs4layouts.c                              |  27 +-
>  fs/nfsd/nfs4proc.c                                 |   6 +-
>  fs/nfsd/pnfs.h                                     |   6 +
>  fs/xfs/Makefile                                    |   1 +
>  fs/xfs/xfs_pnfs.h                                  |   2 +-
>  11 files changed, 407 insertions(+), 48 deletions(-)
>  create mode 100644 Documentation/filesystems/nfs/pnfs-scsi-server.txt
> 
> diff --git a/Documentation/filesystems/nfs/pnfs-scsi-server.txt b/Documentation/filesystems/nfs/pnfs-scsi-server.txt
> new file mode 100644
> index 0000000..4150979
> --- /dev/null
> +++ b/Documentation/filesystems/nfs/pnfs-scsi-server.txt
> @@ -665,7 +680,13 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  		/*
>  		 * Unknown error or non-responding client, we'll need to fence.
>  		 */
> -		nfsd4_cb_layout_fail(ls);
> +		trace_layout_recall_fail(&ls->ls_stid.sc_stateid);
> +
> +		ops = nfsd4_layout_ops[ls->ls_layout_type];
> +		if (ops->fence_client)
> +			ops->fence_client(ls);
> +		else
> +			nfsd4_cb_layout_fail(ls);
>  		return -1;

I'm still not happy about this fencing on callback failure.  I think we
discussed it before, but all I can find is a promise from me to finish
some pynfs tests for the right behavior.  Which I haven't done.

I'd have to think through the failure scenarios to figure out how likely
this is to bite us.

--b.
