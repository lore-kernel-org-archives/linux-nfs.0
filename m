Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46173 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbHYQb5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 12:31:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFSv4: Force a post-op attribute update when holding a delegation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1440122378-30452-1-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 25 Aug 2015 12:31:49 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0BEC962F-39D5-410E-9B75-ED9EE98FFC56@oracle.com>
References: <1440122378-30452-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 20, 2015, at 9:59 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If the ctime or mtime or change attribute have changed because
> of an operation we initiated, we should make sure that we force
> an attribute update. However we do not want to mark the page cache
> for revalidation.

I've tested your linux-next branch (tip is aebbe9d73169
("NFS41/flexfiles: zero out DS write wcc") against Solaris 12
with write delegation enabled (over RDMA, even!).

I was not able to reproduce the write append failures I saw
before.


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/inode.c | 7 +++++++
> 1 file changed, 7 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 2744d48bbbfe..e2cc0031decb 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1477,6 +1477,13 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
> {
> 	unsigned long invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
> 
> +	/*
> +	 * Don't revalidate the pagecache if we hold a delegation, but do
> +	 * force an attribute update
> +	 */
> +	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
> +		invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_FORCED;
> +
> 	if (S_ISDIR(inode->i_mode))
> 		invalid |= NFS_INO_INVALID_DATA;
> 	nfs_set_cache_invalid(inode, invalid);
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



