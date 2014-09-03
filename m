Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53169 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991AbaICS6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 14:58:11 -0400
Message-ID: <540764A5.7030400@Netapp.com>
Date: Wed, 3 Sep 2014 14:57:41 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] pnfs: add a common GETDEVICELIST implementation
References: <1409718480-1529-1-git-send-email-hch@lst.de> <1409718480-1529-3-git-send-email-hch@lst.de>
In-Reply-To: <1409718480-1529-3-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/03/2014 12:27 AM, Christoph Hellwig wrote:
> At a simple helper to issue a GETDEVICELIST operation and pre-load
> the device id cache based on the result.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/pnfs.h     |  2 ++
>  fs/nfs/pnfs_dev.c | 29 +++++++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
>
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index c5f90e7..bf4e87d 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -276,6 +276,8 @@ bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>  void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
>  bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
>  void nfs4_deviceid_purge_client(const struct nfs_client *);
> +int nfs4_deviceid_getdevicelist(struct nfs_server *server,
> +		const struct nfs_fh *fh);
>  
>  static inline struct pnfs_layout_segment *
>  pnfs_get_lseg(struct pnfs_layout_segment *lseg)
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 791f8b3..82c2836 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -359,3 +359,32 @@ nfs4_deviceid_mark_client_invalid(struct nfs_client *clp)
>  	rcu_read_unlock();
>  }
>  
> +int
> +nfs4_deviceid_getdevicelist(struct nfs_server *server,
> +		const struct nfs_fh *fh)
> +{
> +	struct pnfs_devicelist *dlist;
> +	struct nfs4_deviceid_node *d;
> +	int error = 0, i;
> +
> +	dlist = kzalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
> +	if (!dlist)
> +		return -ENOMEM;
> +
> +	while (!dlist->eof) {
> +		error = nfs4_proc_getdevicelist(server, fh, dlist);
> +		if (error)
> +			break;
> +
> +		for (i = 0; i < dlist->num_devs; i++) {
> +			d = nfs4_find_get_deviceid(server, &dlist->dev_id[i],
> +					NULL, GFP_NOFS);
> +			if (d)
> +				nfs4_put_deviceid_node(d);

I think you need to change nfs4xdr.c:encode_getdevicelist() to use a stored cookie value for the GETDEVICELIST operation, otherwise we will always be reading from the beginning of the device list and the while loop might never exit.

Anna
> +		}
> +	}
> +
> +	kfree(dlist);
> +	return error;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_deviceid_getdevicelist);

