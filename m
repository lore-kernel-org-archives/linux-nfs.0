Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:61586 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbaLPVD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2014 16:03:26 -0500
Message-ID: <54909E1B.4000005@Netapp.com>
Date: Tue, 16 Dec 2014 16:03:23 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 38/50] nfs41: add a debug warning if we destroy an unempty
 layout
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com> <1418756513-95187-39-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-39-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/16/2014 02:01 PM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> So that we can detect the case if some layout segments are still
> pinned which is surely a bug that we need to fix.

How often is this hit?  A patch fixing the bug would be better than a patch just to detect it :).

Anna

> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 5f7c422..e123cfc 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -242,6 +242,8 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
>  	struct inode *inode = lo->plh_inode;
>  
>  	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
> +		if (!list_empty(&lo->plh_segs))
> +			WARN_ONCE(1, "NFS: BUG unfreed layout segments.\n");
>  		pnfs_detach_layout_hdr(lo);
>  		spin_unlock(&inode->i_lock);
>  		pnfs_free_layout_hdr(lo);
> 

