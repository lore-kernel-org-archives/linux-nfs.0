Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:26209 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434Ab2DIXZy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2012 19:25:54 -0400
Subject: Re: [PATCH] fix page number calculation bug for block layout decode buffer
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1334013727-1931-1-git-send-email-rees@umich.edu>
Date: Mon, 9 Apr 2012 19:25:42 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Message-Id: <787F4D40-6513-4424-A297-FD608268EA56@oracle.com>
References: <1334013727-1931-1-git-send-email-rees@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Since all the layouts (and I'm guessing the non-pNFS path too) seem to need this calculation, would it make sense to create an inline function in a header somewhere?

On Apr 9, 2012, at 7:22 PM, Jim Rees wrote:

> Signed-off-by: Jim Rees <rees@umich.edu>
> Suggested-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/blocklayout/blocklayout.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 48cfac3..576da5b 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -872,7 +872,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
> 	 * GETDEVICEINFO's maxcount
> 	 */
> 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> -	max_pages = max_resp_sz >> PAGE_SHIFT;
> +	max_pages = (max_resp_sz  + PAGE_SIZE - 1) >> PAGE_SHIFT;
> 	dprintk("%s max_resp_sz %u max_pages %d\n",
> 		__func__, max_resp_sz, max_pages);
> 
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




