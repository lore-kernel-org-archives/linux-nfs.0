Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33248 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489AbaDUVxa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 17:53:30 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so3099183wgh.15
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 14:53:29 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
Mime-Version: 1.0 (1.0)
References: <1398098062-48849-1-git-send-email-dros@primarydata.com>
In-Reply-To: <1398098062-48849-1-git-send-email-dros@primarydata.com>
Date: Mon, 21 Apr 2014 17:53:30 -0400
Message-ID: <3976754869871158642@unknownmsgid>
Subject: Re: [PATCH] pnfs: fix race in filelayout commit path
To: "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hold off on applying this patch - there may be more to do...

More soon!
-dros

> On Apr 21, 2014, at 12:34 PM, Weston Andros Adamson <dros@primarydata.com> wrote:
>
> Hold the lock while changing wlseg in filelayout_recover_commit_reqs.
>
> The following oops can be reproduced by running iozone for a while against
> a 2 DS pynfs filelayout server.
>
> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
> Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs fscache
> CPU: 0 PID: 903 Comm: iozone Not tainted 3.15.0-rc1-branch-dros_testing+ #44
> Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference
> task: ffff880078164480 ti: ffff88006e972000 task.ti: ffff88006e972000
> RIP: 0010:[<ffffffffa01936e1>]  [<ffffffffa01936e1>] nfs_init_commit+0x22/0x
> RSP: 0018:ffff88006e973d30  EFLAGS: 00010246
> RAX: ffff88006e973e00 RBX: ffff88006e828800 RCX: ffff88006e973e10
> RDX: 0000000000000000 RSI: ffff88006e973e00 RDI: dead4ead00000000
> RBP: ffff88006e973d38 R08: ffff88006e8289d8 R09: 0000000000000000
> R10: ffff88006e8289d8 R11: 0000000000016988 R12: ffff88006e973b98
> R13: ffff88007a0a6648 R14: ffff88006e973e10 R15: ffff88006e828800
> FS:  00007f2ce396b740(0000) GS:ffff88007f200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f03278a1000 CR3: 0000000079043000 CR4: 00000000001407f0
> Stack:
> ffff88006e8289d8 ffff88006e973da8 ffffffffa00f144f ffff88006e9478c0
> ffff88006e973e00 ffff88006de21080 0000000100000002 ffff880079be6c48
> ffff88006e973d70 ffff88006e973d70 ffff88006e973e10 ffff88006de21080
> Call Trace:
> [<ffffffffa00f144f>] filelayout_commit_pagelist+0x1ae/0x34a [nfs_layout_nfsv
> [<ffffffffa0194f72>] nfs_generic_commit_list+0x92/0xc4 [nfs]
> [<ffffffffa0195053>] nfs_commit_inode+0xaf/0x114 [nfs]
> [<ffffffffa01892bd>] nfs_file_fsync_commit+0x82/0xbe [nfs]
> [<ffffffffa01ceb0d>] nfs4_file_fsync+0x59/0x9b [nfsv4]
> [<ffffffff8114ee3c>] vfs_fsync_range+0x18/0x20
> [<ffffffff8114ee60>] vfs_fsync+0x1c/0x1e
> [<ffffffffa01891c2>] nfs_file_flush+0x7f/0x84 [nfs]
> [<ffffffff81127a43>] filp_close+0x3c/0x72
> [<ffffffff81140e12>] __close_fd+0x82/0x9a
> [<ffffffff81127a9c>] SyS_close+0x23/0x4c
> [<ffffffff814acd12>] system_call_fastpath+0x16/0x1b
> Code: 5b 41 5c 41 5d 41 5e 5d c3 0f 1f 44 00 00 55 48 89 e5 53 48 89 fb 48 8
> RIP  [<ffffffffa01936e1>] nfs_init_commit+0x22/0xe1 [nfs]
> RSP <ffff88006e973d30>
> ---[ end trace 732fe6419b235e2f ]---
>
> Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>
> Minor change applied to Trond's suggested fix. Should we add a signed-off-by
> line for Trond too?
>
> fs/nfs/nfs4filelayout.c | 9 ++++++---
> 1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index b9a35c0..aa9172d 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -1220,15 +1220,18 @@ static void filelayout_recover_commit_reqs(struct list_head *dst,
>                       struct nfs_commit_info *cinfo)
> {
>    struct pnfs_commit_bucket *b;
> +    struct pnfs_layout_segment *lseg;
>    int i;
>
> +restart:
>    spin_lock(cinfo->lock);
>    for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
>        if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
> -            spin_unlock(cinfo->lock);
> -            pnfs_put_lseg(b->wlseg);
> +            lseg = b->wlseg;
>            b->wlseg = NULL;
> -            spin_lock(cinfo->lock);
> +            spin_unlock(cinfo->lock);
> +            pnfs_put_lseg(lseg);
> +            goto restart;
>        }
>    }
>    cinfo->ds->nwritten = 0;
> --
> 1.8.5.2 (Apple Git-48)
>
