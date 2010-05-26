From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 8/8] pnfs-submit: support for cb_recall_any (layouts)
Date: Wed, 26 May 2010 13:48:43 +0300
Message-ID: <4BFCFC8B.40700@panasas.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com> <1274119004-30213-4-git-send-email-batsakis@netapp.com> <1274119004-30213-5-git-send-email-batsakis@netapp.com> <1274119004-30213-6-git-send-email-batsakis@netapp.com> <1274119004-30213-7-git-send-email-batsakis@netapp.com> <1274119004-30213-8-git-send-email-batsakis@netapp.com> <1274119004-30213-9-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36904 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab0EZKsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 06:48:54 -0400
Received: by fxm5 with SMTP id 5so4239187fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 03:48:52 -0700 (PDT)
In-Reply-To: <1274119004-30213-9-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-05-17 20:56, Alexandros Batsakis wrote:
> CB_RECALL_ANY serves as a hint to the client to return some server state.
> We reply immediately and we clean the layouts asycnhronously.
> 
> FIXME: currently we return _all_ layouts
> FIXME: eventually we should treat layouts as delegations, marked them expired
> and fire the state manager to clean them.
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/callback.h      |    7 ++++++
>  fs/nfs/callback_proc.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 58 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 73f21bc..b39ac86 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -115,6 +115,13 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
>  
>  #define RCA4_TYPE_MASK_RDATA_DLG	0
>  #define RCA4_TYPE_MASK_WDATA_DLG	1
> +#define RCA4_TYPE_MASK_DIR_DLG         2
> +#define RCA4_TYPE_MASK_FILE_LAYOUT     3
> +#define RCA4_TYPE_MASK_BLK_LAYOUT      4
> +#define RCA4_TYPE_MASK_OBJ_LAYOUT_MIN  8
> +#define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
> +#define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
> +#define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
>  
>  struct cb_recallanyargs {
>  	struct sockaddr	*craa_addr;
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 419fee7..d09fb07 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -337,6 +337,26 @@ out_put_no_client:
>  	return status;
>  }
>  
> +static int pnfs_recall_all_layouts(struct nfs_client *clp)
> +{
> +	struct cb_pnfs_layoutrecallargs rl;
> +	struct inode *inode;
> +	int status = 0;
> +
> +	rl.cbl_recall_type = RETURN_ALL;
> +	rl.cbl_seg.offset = 0;
> +	rl.cbl_seg.length = NFS4_MAX_UINT64;
> +	rl.cbl_seg.iomode = IOMODE_ANY;

nit: set the fields in actual memory order...

> +	/* we need the inode to get the nfs_server struct */
> +	inode = nfs_layoutrecall_find_inode(clp, &rl);
> +	if (!inode)
> +		return status;
> +	status = pnfs_async_return_layout(clp, inode, &rl);
> +	iput(inode);
> +
> +	return status;
> +}
> +
>  __be32 pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
>  			    void *dummy)
>  {
> @@ -651,6 +671,27 @@ out:
>  	return status;
>  }
>  
> +static inline int

bool maybe?

> +validate_bitmap_values(const unsigned long* mask)
> +{
> +	int i;
> +	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
> +	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
> +	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
> +	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
> +	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
> +		return 1;
> +	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
> +             i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
> +		if (test_bit(i, mask))
> +			return 1;
> +	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
> +	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
> +		if (test_bit(i, mask))
> +			return 1;

What about undefined bits?
The spec requires returning NFS4ERR_INVAL in this case.
How about having a mask of all known bits (a constant)
and checking that (mask & ~known_mask) == 0 
I'm not absolutely sure that returning INVAL when (mask & known_mask) == 0
(as you effectively do in this patchset) is the right thing to do.
