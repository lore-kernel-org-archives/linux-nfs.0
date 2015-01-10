Return-Path: linux-kernel-owner@vger.kernel.org
MIME-Version: 1.0
In-Reply-To: <fdc56e2887c3ed93f4e6a6e784ee0748c2d13295.1420708562.git.osandov@osandov.com>
References: <fdc56e2887c3ed93f4e6a6e784ee0748c2d13295.1420708562.git.osandov@osandov.com>
Date: Sat, 10 Jan 2015 17:08:03 -0500
Message-ID: <CAHQdGtT=sXmDk=samGCD92mC-Rjr57NAOURudD9TRyFy3=YaBA@mail.gmail.com>
Subject: Re: [PATCH RESEND] nfs: prevent truncate on active swapfile
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Omar Sandoval <osandov@osandov.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Omar,

On Thu, Jan 8, 2015 at 4:18 AM, Omar Sandoval <osandov@osandov.com> wrote:
> Most filesystems prevent truncation of an active swapfile by way of
> inode_newsize_ok, called from inode_change_ok. NFS doesn't call either
> from nfs_setattr, presumably because most of these checks are expected
> to be done server-side. However, the IS_SWAPFILE check can only be done
> client-side, and truncating a swapfile can't possibly be good.
>
> Signed-off-by: Omar Sandoval <osandov@osandov.com>
> ---
> Hi, Trond,
>
> Now that the holidays are over, could you take a look at this? It was
> generated against v3.19-rc3.
>
> Thanks!
>
>  fs/nfs/inode.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 4bffe63..9205513 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -506,10 +506,15 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>                 attr->ia_valid &= ~ATTR_MODE;
>
>         if (attr->ia_valid & ATTR_SIZE) {
> +               loff_t i_size;
> +
>                 BUG_ON(!S_ISREG(inode->i_mode));
>
> -               if (attr->ia_size == i_size_read(inode))
> +               i_size = i_size_read(inode);
> +               if (attr->ia_size == i_size)
>                         attr->ia_valid &= ~ATTR_SIZE;
> +               else if (attr->ia_size < i_size && IS_SWAPFILE(inode))
> +                       return -ETXTBSY;
>         }
>
>         /* Optimization: if the end result is no change, don't RPC */
> --
> 2.2.1
>

I agree that truncating a swap file is bad, however as you point out,
this really only addresses the case on the client that knows about
this being a swap file.
I'll take the patch, but I'm wondering if we couldn't do better in the
case where we're using NFSv4 by using share deny modes (which are
enforced by the server). The problem is that there appears to be
nothing in swapon() that tells the filesystem this is an open of a
swap file...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
