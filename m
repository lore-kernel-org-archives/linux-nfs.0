Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:63974 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaIKNzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 09:55:03 -0400
Received: by mail-qc0-f180.google.com with SMTP id c9so20773161qcz.25
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 06:55:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410362617-28018-4-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 21:54:42 +0800
Message-ID: <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 11:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> If a layout driver keeps per-inode state outside of the layout segments it
> needs to be notified of any layout returns or recalls on an inode, and not
> just about the freeing of layout segments.  Add a method to acomplish this,
> which will allow the block layout driver to handle the case of truncated
> and re-expanded files properly.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/callback_proc.c | 12 +++++++++---
>  fs/nfs/pnfs.c          | 10 ++++++++++
>  fs/nfs/pnfs.h          |  3 +++
>  3 files changed, 22 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 0d26951..56bd0ea 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -181,10 +181,16 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>         spin_lock(&ino->i_lock);
>         if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
>             pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> -                                       &args->cbl_range))
> +                                       &args->cbl_range)) {
>                 rv = NFS4ERR_DELAY;
> -       else
> -               rv = NFS4ERR_NOMATCHING_LAYOUT;
> +               goto unlock;
> +       }
> +
> +       if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
It looks better to put return_range inside
pnfs_mark_matching_lsegs_invalid() to have it called every time a
range of layout segments all get freed. So that ld is sure to free
things up.

Cheers,
Tao
