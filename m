Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f47.google.com ([209.85.213.47]:39310 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843AbaHZO02 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 10:26:28 -0400
Received: by mail-yh0-f47.google.com with SMTP id f10so11795459yha.6
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 07:26:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53FC9545.4000800@plexistor.com>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-4-git-send-email-hch@lst.de>
	<53FA259C.9050807@gmail.com>
	<20140824191839.GA9717@lst.de>
	<53FC9545.4000800@plexistor.com>
Date: Tue, 26 Aug 2014 10:26:27 -0400
Message-ID: <CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2014 at 10:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
>
> This fixes a dead-lock in the pnfs recall processing
>
> pnfs_layoutcommit_inode() is called through update_inode()
> called from VFS. By setting set_inode_dirty during
> pnfs write IO.
>
> But the VFS will not schedule another update_inode()
> If it is already inside an update_inode() or an sb-writeback
>
> As part of writeback pnfs code might get stuck in LAYOUT_GET
> with the server returning ERR_RECALL_CONFLICT because some
> operation has caused the server to RECALL all layouts, including
> those from our client.
>
> So the RECALL is received, but our client is returning ERR_DELAY
> because its write-segments need a LAYOUT_COMMIT, but
> pnfs_layoutcommit_inode will never come because it is scheduled
> behind the LAYOUT_GET which is stuck waiting for the recall to
> finish
>
> Hence the deadlock, client is stuck polling LAYOUT_GET receiving
> ERR_RECALL_CONFLICT. Server is stuck polling RECALL receiving
> ERR_DELAY.
>
> With pnfs-objects the above condition can easily happen, when
> a file grows beyond a group of devices. The pnfs-objects-server
> will RECALL all layouts because the file-objects-map will
> change and all old layouts will have stale attributes, therefor
> the RECALL is initiated as part of a LAYOUT_GET, and this can
> be triggered from within a single client operation.
>
> A simple solution is to kick out a pnfs_layoutcommit_inode()
> from within the recall, to free any need-to-commit segments
> and let the client return success on the RECALL, so streaming
> can continue.
>
> This patch Is based on 3.17-rc1. It is completely UNTESTED.
> I have tested a version of this patch at around the 3.12 Kernel
> at which point the deadlock was resolved but I hit some race
> conditions on pnfs state management farther on, so the actual
> overall processing was not fixed. But hopefully these were fixed
> by Trond and Christoph, and it should work better now.
>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  fs/nfs/callback_proc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 41db525..8660f96 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -171,6 +171,14 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>                 goto out;
>
>         ino = lo->plh_inode;
> +
> +       spin_lock(&ino->i_lock);
> +       pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
> +       spin_unlock(&ino->i_lock);
> +
> +       /* kick out any segs held by need to commit */
> +       pnfs_layoutcommit_inode(ino, true);

Making this call synchronous could deadlock the entire back channel.
Is there any reason why it can't just be made asynchonous?

> +
>         spin_lock(&ino->i_lock);
>         if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
>             pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> @@ -178,7 +186,6 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>                 rv = NFS4ERR_DELAY;
>         else
>                 rv = NFS4ERR_NOMATCHING_LAYOUT;
> -       pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>         spin_unlock(&ino->i_lock);
>         pnfs_free_lseg_list(&free_me_list);
>         pnfs_put_layout_hdr(lo);
> --
> 1.9.3
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
