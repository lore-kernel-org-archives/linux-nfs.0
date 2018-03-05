Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37782 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752063AbeCEVQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 16:16:19 -0500
Date: Mon, 5 Mar 2018 16:16:19 -0500
To: Scott Mayhew <smayhew@redhat.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Message-ID: <20180305211619.GA29226@fieldses.org>
References: <20180302160038.1598-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180302160038.1598-1-smayhew@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 02, 2018 at 11:00:38AM -0500, Scott Mayhew wrote:
> It seems that nfs_commit_inode can be called where the nfs_inode has
> outstanding requests and the commit lists are empty.  That can lead to
> invalidate_complete_page2 failing due to the associated page having
> private data which in turn leads to invalidate_inode_pages2_range
> returning -EBUSY.

For what it's worth, I verified that this fixes the EBUSY I was seeing:

	http://marc.info/?i=20180223160350.GF15876@fieldses.org

--b.

> 
> Instead of having nfs_commit_inode exit early when the commit lists are
> empty, only do so if nrequests is also 0.
> 
> Fixes: dc4fd9ab01 ("nfs: don't wait on commit in nfs_commit_inode() if there were no commit requests")
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/write.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 7428a66..0268bd1 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1890,7 +1890,7 @@ int nfs_commit_inode(struct inode *inode, int how)
>  	if (res)
>  		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
>  	nfs_commit_end(cinfo.mds);
> -	if (res == 0)
> +	if (res == 0 && !nfs_have_writebacks(inode))
>  		return res;
>  	if (error < 0)
>  		goto out_error;
> -- 
> 2.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
