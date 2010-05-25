From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 3/3] SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
Date: Tue, 25 May 2010 14:20:36 +0300
Message-ID: <4BFBB284.1070703@panasas.com>
References: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com> <1274767019-19587-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55642 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932691Ab0EYLUk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 07:20:40 -0400
Received: by fxm5 with SMTP id 5so3192039fxm.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 04:20:39 -0700 (PDT)
In-Reply-To: <1274767019-19587-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/25/2010 08:56 AM, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/spnfs_ops.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/spnfs_ops.c b/fs/nfsd/spnfs_ops.c
> index 230fb59..b97a5af 100644
> --- a/fs/nfsd/spnfs_ops.c
> +++ b/fs/nfsd/spnfs_ops.c
> @@ -57,7 +57,7 @@ extern struct spnfs *global_spnfs;
>  int
>  spnfs_layout_type(struct super_block *sb)
>  {
> -	return LAYOUT_NFSV4_FILES;
> +	return LAYOUT_NFSV4_1_FILES;
>  }
>  
>  enum nfsstat4
> @@ -218,7 +218,7 @@ spnfs_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
>  	}
>  
>  	lr.cbl_recall_type = type;
> -	lr.cbl_seg.layout_type = LAYOUT_NFSV4_FILES;
> +	lr.cbl_seg.layout_type = LAYOUT_NFSV4_1_FILES;
>  	lr.cbl_seg.clientid = 0;
>  	lr.cbl_seg.offset = offset;
>  	lr.cbl_seg.length = len;

Sorry to bother you guys but I don't like the "_" between the 4 and the 1
I would mutch prefer the LAYOUT_NFSV41_FILES format. An "_" is an heavy wait
that should not be used lightly.

Boaz
