Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57337 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab1GMNWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 09:22:08 -0400
Received: by wyg8 with SMTP id 8so129803wyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2011 06:22:07 -0700 (PDT)
Message-ID: <4E1D9BFA.1050000@tonian.com>
Date: Wed, 13 Jul 2011 16:22:02 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/8] NFS: Allow the nfs_pageio_descriptor to signal that
 a re-coalesce is needed
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-12 22:29, Trond Myklebust wrote:
> If an attempt to do pNFS fails, and we have to fall back to writing through
> the MDS, then we may want to re-coalesce the requests that we already have
> since the block size for the MDS read/writes may be different to that of
> the DS read/writes.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/pagelist.c        |   57 +++++++++++++++++++++++++++++++++++++++++++--
>  include/linux/nfs_page.h |    3 +-
>  2 files changed, 56 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index d421e19..7139dbf 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -240,6 +240,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  	desc->pg_bsize = bsize;
>  	desc->pg_base = 0;
>  	desc->pg_moreio = 0;
> +	desc->pg_recoalesce = 0;
>  	desc->pg_inode = inode;
>  	desc->pg_ops = pg_ops;
>  	desc->pg_ioflags = io_flags;
> @@ -331,7 +332,7 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>   * Returns true if the request 'req' was successfully coalesced into the
>   * existing list of pages 'desc'.
>   */
> -int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
> +static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>  			   struct nfs_page *req)
>  {
>  	while (!nfs_pageio_do_add_request(desc, req)) {
> @@ -340,17 +341,67 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>  		if (desc->pg_error < 0)
>  			return 0;
>  		desc->pg_moreio = 0;
> +		if (desc->pg_recoalesce)
> +			return 0;
>  	}
>  	return 1;
>  }
>  
> +static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
> +{
> +	LIST_HEAD(head);
> +
> +	do {
> +		list_splice_init(&desc->pg_list, &head);
> +		desc->pg_bytes_written -= desc->pg_count;
> +		desc->pg_count = 0;
> +		desc->pg_base = 0;
> +		desc->pg_recoalesce = 0;
> +
> +		while (!list_empty(&head)) {
> +			struct nfs_page *req;
> +
> +			req = list_first_entry(&head, struct nfs_page, wb_list);
> +			nfs_list_remove_request(req);
> +			if (__nfs_pageio_add_request(desc, req))
> +				continue;
> +			if (desc->pg_error < 0)
> +				return 0;
> +			break;
> +		}
> +	} while (desc->pg_recoalesce);
> +	return 1;
> +}
> +
> +int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
> +		struct nfs_page *req)
> +{
> +	int ret;
> +
> +	do {
> +		ret = __nfs_pageio_add_request(desc, req);
> +		if (ret)
> +			break;
> +		if (desc->pg_error < 0)
> +			break;
> +		ret = nfs_do_recoalesce(desc);
> +	} while (ret);
> +	return ret;
> +}
> +
>  /**
>   * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
>   * @desc: pointer to io descriptor
>   */
>  void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
>  {
> -	nfs_pageio_doio(desc);
> +	for (;;) {
> +		nfs_pageio_doio(desc);
> +		if (!desc->pg_recoalesce)
> +			break;
> +		if (!nfs_do_recoalesce(desc))
> +			break;
> +	}

nit: how about the following?

	do
		nfs_pageio_doio(desc);
	while (desc->pg_recoalesce && nfs_do_recoalesce(desc));

Benny

>  }
>  
>  /**
> @@ -369,7 +420,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
>  	if (!list_empty(&desc->pg_list)) {
>  		struct nfs_page *prev = nfs_list_entry(desc->pg_list.prev);
>  		if (index != prev->wb_index + 1)
> -			nfs_pageio_doio(desc);
> +			nfs_pageio_complete(desc);
>  	}
>  }
>  
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index db3194f..7241b2a 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -68,7 +68,8 @@ struct nfs_pageio_descriptor {
>  	size_t			pg_count;
>  	size_t			pg_bsize;
>  	unsigned int		pg_base;
> -	char			pg_moreio;
> +	unsigned char		pg_moreio : 1,
> +				pg_recoalesce : 1;
>  
>  	struct inode		*pg_inode;
>  	const struct nfs_pageio_ops *pg_ops;
