Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:53704 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbbAXOha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 09:37:30 -0500
Received: by mail-qc0-f175.google.com with SMTP id c9so1749948qcz.6
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 06:37:29 -0800 (PST)
MIME-Version: 1.0
From: Peng Tao <tao.peng@primarydata.com>
Date: Sat, 24 Jan 2015 22:37:09 +0800
Message-ID: <CAKVebiXRc2OZ+=PkC33de25xX3C-VOzrW+Ufo6s5e05TC422jw@mail.gmail.com>
Subject: Re: [PATCH v5 00/51] Add Flexfile Layout Module
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

oops, sorry for editing the mail subject... It was supposed to reply
to your email "Re: [PATCH v5 00/51] Add Flexfile Layout Module"

On Sat, Jan 24, 2015 at 10:33 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> Does following patch fix the warning and hang for you?
> I tested it locally on top of your flexfiles+pnfsd branch (tip 4f7961eb6) and xfstest generic/001 passed.
>
> Cheers,
> Tao
>
> From 47bc1a0ffc586ea96c99e453efd7e2435454b486 Mon Sep 17 00:00:00 2001
> From: Peng Tao <tao.peng@primarydata.com>
> Date: Sat, 24 Jan 2015 22:14:52 +0800
> Subject: [PATCH] nfs41: .init_read and .init_write can be called with valid pg_lseg
>
> With pgio refactoring in v3.15, .init_read and .init_write can be
> called with valid pgio->pg_lseg. file layout was fixed at that time
> by commit c6194271f (pnfs: filelayout: support non page aligned
> layouts). But the generic helper still needs to be fixed.
>
> Cc: stable@vger.kernel.org # 3.15+
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 41 ++++++++++++++++++++---------------------
>  1 file changed, 20 insertions(+), 21 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0fb0f19..c7be9b9 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1711,19 +1711,19 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
>  {
>         u64 rd_size = req->wb_bytes;
>
> -       WARN_ON_ONCE(pgio->pg_lseg != NULL);
> -
> -       if (pgio->pg_dreq == NULL)
> -               rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
> -       else
> -               rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
> -
> -       pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> -                                          req->wb_context,
> -                                          req_offset(req),
> -                                          rd_size,
> -                                          IOMODE_READ,
> -                                          GFP_KERNEL);
> +       if (pgio->pg_lseg == NULL) {
> +               if (pgio->pg_dreq == NULL)
> +                       rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
> +               else
> +                       rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
> +
> +               pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> +                                                  req->wb_context,
> +                                                  req_offset(req),
> +                                                  rd_size,
> +                                                  IOMODE_READ,
> +                                                  GFP_KERNEL);
> +       }
>         /* If no lseg, fall back to read through mds */
>         if (pgio->pg_lseg == NULL)
>                 nfs_pageio_reset_read_mds(pgio);
> @@ -1735,14 +1735,13 @@ void
>  pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
>                            struct nfs_page *req, u64 wb_size)
>  {
> -       WARN_ON_ONCE(pgio->pg_lseg != NULL);
> -
> -       pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> -                                          req->wb_context,
> -                                          req_offset(req),
> -                                          wb_size,
> -                                          IOMODE_RW,
> -                                          GFP_NOFS);
> +       if (pgio->pg_lseg == NULL)
> +               pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> +                                                  req->wb_context,
> +                                                  req_offset(req),
> +                                                  wb_size,
> +                                                  IOMODE_RW,
> +                                                  GFP_NOFS);
>         /* If no lseg, fall back to write through mds */
>         if (pgio->pg_lseg == NULL)
>                 nfs_pageio_reset_write_mds(pgio);
> --
> 1.9.1
>
