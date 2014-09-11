Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:55097 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbaIKOME (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 10:12:04 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so21102679qcr.18
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 07:12:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410362617-28018-7-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-7-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 22:11:42 +0800
Message-ID: <CAKVebiV==2PwNaHJY57sP4oFjUqAzPCLZgx+k9bRf+oiVSeXVw@mail.gmail.com>
Subject: Re: [PATCH 6/9] pnfs/blocklayout: rewrite extent tracking
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

I really like your refactoring. It looks a lot better than the
original lists-every-where code. One minor comment below:

<snip..>
>  static void bl_write_cleanup(struct work_struct *work)
>  {
> -       struct rpc_task *task;
> -       struct nfs_pgio_header *hdr;
> +       struct rpc_task *task = container_of(work, struct rpc_task, u.tk_work);
> +       struct nfs_pgio_header *hdr =
> +                       container_of(task, struct nfs_pgio_header, task);
> +
>         dprintk("%s enter\n", __func__);
> -       task = container_of(work, struct rpc_task, u.tk_work);
> -       hdr = container_of(task, struct nfs_pgio_header, task);
> +
>         if (likely(!hdr->pnfs_error)) {
> -               /* Marks for LAYOUTCOMMIT */
> -               mark_extents_written(BLK_LSEG2EXT(hdr->lseg),
> -                                    hdr->args.offset, hdr->args.count);
> +               struct pnfs_block_layout *bl = BLK_LSEG2EXT(hdr->lseg);
> +               u64 start = hdr->args.offset & (loff_t)PAGE_CACHE_MASK;
> +               u64 end = (hdr->args.offset + hdr->args.count +
> +                       PAGE_CACHE_SIZE - 1) & (loff_t)PAGE_CACHE_MASK;
> +
> +               ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
> +                                       (end - start) >> SECTOR_SHIFT);
The old code works in a way that mark_extents_written() always
succeeds. Now that ext_tree_mark_written() may fail, it should check
for the return value and resend to MDS if failed, otherwise there may
be silent data corruption.

Thanks,
Tao
