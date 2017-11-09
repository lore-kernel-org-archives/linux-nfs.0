Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:51825 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754349AbdKIMch (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 07:32:37 -0500
Received: by mail-qt0-f195.google.com with SMTP id e19so2545124qte.8
        for <linux-nfs@vger.kernel.org>; Thu, 09 Nov 2017 04:32:36 -0800 (PST)
Message-ID: <1510230754.29194.6.camel@redhat.com>
Subject: Re: [PATCH 0/3] VFS: name lookup improvements.
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Ian Kent <ikent@redhat.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 09 Nov 2017 07:32:34 -0500
In-Reply-To: <151021179901.22743.15252956909042161062.stgit@noble>
References: <151021179901.22743.15252956909042161062.stgit@noble>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-11-09 at 18:20 +1100, NeilBrown wrote:
> These three patches address two issues: d_weak_revalidate and
> path_mountpoint lookups.
> 
> The former is poorly defined and doesn't actually do the one thing
> that it would be useful for it to do.  So the nfs implemention
> is improved, the 9p one discarded, and the documentation clarified.
> 
> Given this change and recent change to follow_automount() the
> mountpoint path lookup functions are no longer needed.  The regular
> path look functions are quite sufficient.
> The second two patches remove this with detailed explanation of why
> it is OK.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (3):
>       VFS/nfs/9p: revise meaning of d_weak_invalidate.
>       VFS: remove user_path_mountpoint_at()
>       VFS / autofs4: remove kern_path_mountpoint()
> 
> 
>  Documentation/filesystems/porting |    5 +
>  Documentation/filesystems/vfs.txt |   11 +--
>  fs/9p/vfs_dentry.c                |    1 
>  fs/autofs4/dev-ioctl.c            |    5 -
>  fs/internal.h                     |    1 
>  fs/namei.c                        |  150 -------------------------------------
>  fs/namespace.c                    |    2 
>  fs/nfs/dir.c                      |   60 ++-------------
>  include/linux/namei.h             |    1 
>  9 files changed, 24 insertions(+), 212 deletions(-)
> 
> --
> Signature
> 

I love that diffstat and I think the patches and the logic behind them
look reasonable. I'm the one that added d_weak_revalidate and while it
did fix a problem at the time, it has always seemed a bit of an odd
d_op.

Your patch does make me wonder if we should consider merging
d_weak_revalidate and d_revalidate back together, and simply require all
the d_revalidate ops vet the flags more thoroughly.

-- 
Jeff Layton <jlayton@redhat.com>
