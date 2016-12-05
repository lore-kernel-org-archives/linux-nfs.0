Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36572 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbcLEJ2T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 04:28:19 -0500
Received: by mail-oi0-f65.google.com with SMTP id u15so35647786oie.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2016 01:28:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 5 Dec 2016 10:28:18 +0100
Message-ID: <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: Patrick Plagwitz <Patrick_Plagwitz@web.de>
Cc: "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Added a few more CCs]

On Mon, Dec 5, 2016 at 1:51 AM, Patrick Plagwitz
<Patrick_Plagwitz@web.de> wrote:
> Mounting an overlayfs with an NFSv4 lowerdir and an ext4 upperdir causes copy_up operations, specifically the function copy_up.c:ovl_copy_xattr, to fail with EOPNOTSUPP.
> For example, having the following folders:
>
> |- nfs <- NFSv4 is mounted here
> |--|- folder
> |- root <- ext4 is mounted here
> |- work <- also ext4
> |- merged <- overlay is mounted here with
>              lowerdir=nfs,upperdir=root,workdir=work
>
> And calling
> # touch merged/folder/file
> will print
> touch: cannot touch 'merged/folder/file': Operation not supported
>
> This is because NFS returns the xattr system.nfs4_acl with an empty value even if no NFS ACLs are in use in the lower filesystem. Trying to set this xattr in the upperdir
> fails because ext4 does not support it.
>
> Fix this by explicitly checking for the name of the xattr and an empty value and ignoring EOPNOTSUPP if both things match.
>
> Signed-off-by: Patrick Plagwitz <patrick_plagwitz@web.de>
> ---
> Maybe NFS could be changed to not return empty system.nfs4_acl values, I don't know. In any case, to support upperdir ext4 + lowerdir NFSv4, returning the error code from
> vfs_setxattr with this xattr name must be avoided as long as the value is empty.
>
> diff --git a/fs/overlayfs/copy_up.c b/fs/overlayfs/copy_up.c
> index 36795ee..505b86e 100644
> --- a/fs/overlayfs/copy_up.c
> +++ b/fs/overlayfs/copy_up.c
> @@ -123,6 +123,9 @@ int ovl_copy_xattr(struct dentry *old, struct dentry *new)
>                         continue; /* Discard */
>                 }
>                 error = vfs_setxattr(new, name, value, size, 0);
> +               if (error == -EOPNOTSUPP && *value == '\0' &&
> +                               strcmp(name, "system.nfs4_acl") == 0)
> +                       error = 0;
>                 if (error)
>                         break;
>         }

I agree that this should be fixed, but adding such exceptions for
certain filesystems or xattrs is not the proper way, IMO.

Can NFS people comment on this?  Where does the nfs4_acl come from?

What can overlayfs do if it's a non-empty ACL?

Does knfsd translate posix ACL into NFS acl?  If so, we can translate
back.  Should we do a generic POSIX<->NFS acl translator?

Thanks,
Miklos
