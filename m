Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39665 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbbHSVYU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 17:24:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFSv4/pnfs: Ensure we don't miss a file extension
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1440015890-28211-1-git-send-email-tao.peng@primarydata.com>
Date: Wed, 19 Aug 2015 14:24:16 -0700
Cc: stable@vger.kernel.org, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <00A0DB2C-A3DF-4ECC-A5E5-8861165B22DA@oracle.com>
References: <1440015890-28211-1-git-send-email-tao.peng@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 19, 2015, at 1:24 PM, Peng Tao <tao.peng@primarydata.com> wrote:

> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> pNFS writes don't return attributes, however that doesn't mean that we
> should ignore the fact that they may be extending the file. This patch
> ensures that if a write is seen to extend the file, then we always set
> an attribute barrier, and update the cached file size.

I think this is the same problem I see when a write delegation
is in effect. The flush-after-close does not wait, and does not
set an attribute barrier. So a subsequent append write starts
at the wrong file length.


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> Please apply this to 4.0+ stable releases. It is upstream commit
> 2b83d3de4c18af49800e0b26ae013db4fcf43a4a. It fixes
> a08a8cd375db9769588257e7782f6b6b68561b88(NFS: Add attribute update barriers to NFS writebacks)
> and makes sure we pass fstest read_write/mctime.t test with delegation and inband IO.
> Without it, users might see mtime not updated after write.
> 
> Cheers,
> Tao
> 
> fs/nfs/write.c | 15 +++++++++------
> 1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 359e9ad..0e6a2b8 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1378,24 +1378,27 @@ static void nfs_writeback_check_extend(struct nfs_pgio_header *hdr,
> {
> 	struct nfs_pgio_args *argp = &hdr->args;
> 	struct nfs_pgio_res *resp = &hdr->res;
> +	u64 size = argp->offset + resp->count;
> 
> 	if (!(fattr->valid & NFS_ATTR_FATTR_SIZE))
> +		fattr->size = size;
> +	if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode)) {
> +		fattr->valid &= ~NFS_ATTR_FATTR_SIZE;
> 		return;
> -	if (argp->offset + resp->count != fattr->size)
> -		return;
> -	if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode))
> +	}
> +	if (size != fattr->size)
> 		return;
> 	/* Set attribute barrier */
> 	nfs_fattr_set_barrier(fattr);
> +	/* ...and update size */
> +	fattr->valid |= NFS_ATTR_FATTR_SIZE;
> }
> 
> void nfs_writeback_update_inode(struct nfs_pgio_header *hdr)
> {
> -	struct nfs_fattr *fattr = hdr->res.fattr;
> +	struct nfs_fattr *fattr = &hdr->fattr;
> 	struct inode *inode = hdr->inode;
> 
> -	if (fattr == NULL)
> -		return;
> 	spin_lock(&inode->i_lock);
> 	nfs_writeback_check_extend(hdr, fattr);
> 	nfs_post_op_update_inode_force_wcc_locked(inode, fattr);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



