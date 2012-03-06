Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:41659 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318Ab2CFXY0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 18:24:26 -0500
Subject: Re: [PATCH] NFS: add crc hash to nfs_display_fhandle
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1331075875-20421-1-git-send-email-dros@netapp.com>
Date: Tue, 6 Mar 2012 18:24:21 -0500
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <C50941B2-C7B7-4432-9576-7FF28405F8BE@oracle.com>
References: <1331075875-20421-1-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2012, at 6:17 PM, Weston Andros Adamson wrote:

> Match wireshark's CRC-32 hash for easier debugging.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> Requested by Chuck and others.
> 
> Nothing in trond/nfs-for-next uses nfs_display_fhandle() yet.
> I tested by calling it in nfs4xdr.c:encode_putfh().

The one patch in my series that used it was dropped.  So this is for debugging only.  If we don't add any permanent call sites for it, enterprise distributions could wrap nfs_display_fhandle() in RPC_DEBUG.

> fs/nfs/inode.c |    8 +++++++-
> 1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 99a4f52..c1f44e9 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -39,6 +39,7 @@
> #include <linux/slab.h>
> #include <linux/compat.h>
> #include <linux/freezer.h>
> +#include <linux/crc32.h>
> 
> #include <asm/system.h>
> #include <asm/uaccess.h>
> @@ -1057,13 +1058,18 @@ struct nfs_fh *nfs_alloc_fhandle(void)
> void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
> {
> 	unsigned short i;
> +	u32 crc;
> 
> 	if (fh->size == 0 || fh == NULL) {
> 		printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
> 		return;
> 	}
> 
> -	printk(KERN_DEFAULT "%s at %p is %u bytes:\n", caption, fh, fh->size);
> +	/* match wireshark's CRC-32 hash */
> +	crc = ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
> +
> +	printk(KERN_DEFAULT "%s at %p is %u bytes, crc: 0x%08x:\n",
> +	                    caption, fh, fh->size, crc);
> 	for (i = 0; i < fh->size; i += 16) {
> 		__be32 *pos = (__be32 *)&fh->data[i];
> 
> -- 
> 1.7.4.4
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




