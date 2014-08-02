Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:52339 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808AbaHBO7W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Aug 2014 10:59:22 -0400
Received: by mail-vc0-f177.google.com with SMTP id hy4so8426637vcb.22
        for <linux-nfs@vger.kernel.org>; Sat, 02 Aug 2014 07:59:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53DCF97D.3000605@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53DCF97D.3000605@gmail.com>
Date: Sat, 2 Aug 2014 10:59:21 -0400
Message-ID: <CAHQdGtTwWFbjPEC08vpzvLCs1Kzq1h7UR7yDPc-XgHivDMD--Q@mail.gmail.com>
Subject: Re: [PATCH] fs/locks.c: Copy fl_lmops to conflock for nfsd using
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>, jlayton@redhat.com,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 2, 2014 at 10:45 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks)
> using fl_lmops field in file_lock for checking nfsd4 lockowner.
>
> But, commit 1a747ee0cc (locks: don't call ->copy_lock methods
> on return of conflicting locks) causes the fl_lmops of conflock
> for nfsd4_lock always be NULL.
>
> Also, commit 0996905f93 (lockd: posix_test_lock() should not call
> locks_copy_lock()) caused the fl_lmops of conflock for nfsd4_lockt
> always be NULL too.
>
> So that, nfsd4 lockowner for it always be NULL too.
>
> This patch re-coping the fl_lmops to conflock.
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/locks.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/locks.c b/fs/locks.c
> index 717fbc4..cc1219a 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -279,7 +279,7 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>         new->fl_start = fl->fl_start;
>         new->fl_end = fl->fl_end;
>         new->fl_ops = NULL;
> -       new->fl_lmops = NULL;
> +       new->fl_lmops = fl->fl_lmops;
>  }
>  EXPORT_SYMBOL(__locks_copy_lock);
>
> @@ -290,7 +290,6 @@ void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>         __locks_copy_lock(new, fl);
>         new->fl_file = fl->fl_file;
>         new->fl_ops = fl->fl_ops;
> -       new->fl_lmops = fl->fl_lmops;
>
>         locks_copy_private(new, fl);
>  }
> --

No. There is a very good reason why we separate __locks_copy_lock and
locks_copy_private(). We don't want to have anyone calling notifiers
etc for copies of locks.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
