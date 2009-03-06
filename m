From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH] Remove redundant NFS_STALE() call in __nfs_revalidate_inode()
Date: Fri, 06 Mar 2009 09:40:53 +0530
Message-ID: <49B0A24D.4060302@suse.de>
References: <> <1236305157-10461-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:49370 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbZCFELE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 23:11:04 -0500
In-Reply-To: <1236305157-10461-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ricardo Labiaga wrote:
> The extra NFS_STALE() invocation is likely the result of a mismerge.

Ah, I just posted this cleanup patch a little while ago..
http://marc.info/?l=linux-nfs&m=123486480925457&w=2


> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/inode.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 0c38168..af77c2d 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -667,8 +667,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>  
>  	if (is_bad_inode(inode))
>  		goto out;
> -	if (NFS_STALE(inode))
> -		goto out;
>  
>  	if (NFS_STALE(inode))
>  		goto out;


-- 
Suresh Jayaraman
