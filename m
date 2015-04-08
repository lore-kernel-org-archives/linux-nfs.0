Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35341 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbbDHOsD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 10:48:03 -0400
Received: by iejt8 with SMTP id t8so3851724iej.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 07:48:02 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Subject: Re: [PATCH] nfs: remove WARN_ON_ONCE from nfs_direct_good_bytes
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1428504083-8227-1-git-send-email-tao.peng@primarydata.com>
Date: Wed, 8 Apr 2015 10:48:01 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <CEFB35C0-6418-47DD-9997-8419037BE7B6@primarydata.com>
References: <1428504083-8227-1-git-send-email-tao.peng@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Makes sense to me!

Thanks,
-dros



> On Apr 8, 2015, at 10:41 AM, Peng Tao <tao.peng@primarydata.com> wrote:
> 
> For flexfiles driver, we might choose to read from mirror index other
> than 0 while mirror_count is always 1 for read.
> 
> Reported-by: Jean Spector <jean@primarydata.com>
> Cc: Weston Andros Adamson <dros@primarydata.com>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
> fs/nfs/direct.c | 2 --
> 1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 645109e..0c84f67 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -129,8 +129,6 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
> 	int i;
> 	ssize_t count;
> 
> -	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
> -
> 	count = dreq->mirrors[hdr->pgio_mirror_idx].count;
> 	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes)
> 		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
> -- 
> 1.9.1
> 

