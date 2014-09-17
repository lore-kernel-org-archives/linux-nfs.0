Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:46769 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbaIQBco (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2014 21:32:44 -0400
Received: by mail-ig0-f180.google.com with SMTP id hn15so429290igb.13
        for <linux-nfs@vger.kernel.org>; Tue, 16 Sep 2014 18:32:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140917111017.499eb3a9@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053135.22257.46476.stgit@notabene.brown>
	<CAHQdGtQbFtLFEpzgqoMoLiG7-Y0FdFiZdpS4dgkT7hsCnqMiPA@mail.gmail.com>
	<20140917111017.499eb3a9@notabene.brown>
Date: Tue, 16 Sep 2014 21:32:43 -0400
Message-ID: <CAHQdGtST5nEE-Wh99vKLNPsOHc_pSgau4om7dWr+GhfLauFBnA@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFS/SUNRPC: Remove other deadlock-avoidance
 mechanisms in nfs_release_page()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2014 at 9:10 PM, NeilBrown <neilb@suse.de> wrote:
>
> However ... something else occurs to me.  We could use the bdi congestion
> markers to guide the timeout.
> When the wait for PG_private times out, or when a connection re-establishment
> is required (and maybe other similar times) we could set_bdi_congested().
> Then in nfs_release_page() we could completely avoid the wait if
> bdi_write_congested().
>
> The congestion setting should encourage vmscan away from the filesystem so it
> won't keep calling nfs_release_page() which is a bonus.
>
> Setting bdi_congestion from the RPC layer might be awkward from a layering
> perspective, but probably isn't necessary.
>
> Would the following allay your concerns?  The change to
> nfs_inode_remove_request ensures that any congestion is removed when a
> 'commit' completes.
>
> We certainly could keep the PF_FSTRANS setting in the SUNRPC layer - that was
> why it was a separate patch.  It would be nice to find a uniform solution
> though.
>
> Thanks,
> NeilBrown
>
>
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 5949ca37cd18..bc674ad250ce 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -477,10 +477,15 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>          * benefit that someone else can worry about the freezer.
>          */
>         if (mapping) {
> +               struct nfs_server *nfss = NFS_SERVER(mapping->host);
>                 nfs_commit_inode(mapping->host, 0);
> -               if ((gfp & __GFP_WAIT))
> +               if ((gfp & __GFP_WAIT) &&
> +                   !bdi_write_congested(&nfss->backing_dev_info))
>                         wait_on_page_bit_killable_timeout(page, PG_private,
>                                                           HZ);
> +               if (PagePrivate(page))
> +                       set_bdi_congested(&nfss->backing_dev_info,
> +                                         BLK_RW_ASYNC);
>         }
>         /* If PagePrivate() is set, then the page is not freeable */
>         if (PagePrivate(page))
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 700e7a865e6d..3ab122e92c9d 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -726,6 +726,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>         struct inode *inode = req->wb_context->dentry->d_inode;
>         struct nfs_inode *nfsi = NFS_I(inode);
>         struct nfs_page *head;
> +       struct nfs_server *nfss = NFS_SERVER(inode);
>
>         if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
>                 head = req->wb_head;
> @@ -742,6 +743,9 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>                 spin_unlock(&inode->i_lock);
>         }
>
> +       if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
> +               clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);

Hmm.... We already have this equivalent functionality in
nfs_end_page_writeback(), so adding it to nfs_inode_remove_request()
is just causing duplication as far as the stable writeback path is
concerned. How about adding it to nfs_commit_release_pages() instead?

Otherwise, yes, the above does indeed look at if it has merit. Have
you got a good test?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
