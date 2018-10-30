Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2ED6C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 21:26:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7CF9C2081B
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 21:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XHm+LGgE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF9C2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726134AbeJaGWD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 02:22:03 -0400
Received: from mail-yb1-f195.google.com ([209.85.219.195]:36853 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725743AbeJaGWD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 02:22:03 -0400
Received: by mail-yb1-f195.google.com with SMTP id w16-v6so5705915ybp.3;
        Tue, 30 Oct 2018 14:26:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=awXz5s1qjpOo7a42F5ZM7gVvr1+s0leq5BL9hVQvnpI=;
        b=XHm+LGgE/9zEDPxqeiwofb32ycLAdOcOgzOQFcyZqCNqPuoRRm7859ZuT/rgY4enuw
         A51NG1EiQ7bC2RjOEO7p9wOrxPhJaSAGDi1Z10BCfK63A60cgYQvfkJ5nVH5ZbAPNz6L
         pCAQ6MS9ZozBAQumi4uVKUq8vjm5CeG2b3KTYw+ldqBZxuH+2Ts+50DuMB33UxJU0nh/
         h0KeWORDnWcC+7fQMealve3kFpd8i/pX6QG639+w27hQiBRD9vSKUqGQNvK1E4z029hn
         rB+3nh8fDNVg/7rwk7rjtRF39Asxd+WqEFWEm2tOxBIpXBCMq8IimMT9Qp2Lq2xiCvGx
         itvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=awXz5s1qjpOo7a42F5ZM7gVvr1+s0leq5BL9hVQvnpI=;
        b=YB491gcsINDz8w4AQ6o2zEWZhpVuBsXtz0JeXPq9X5vD6AG4KQOypWv0JOfT4PoUCP
         zfXWXwEJj7FDJjywGap/XK11wUxSNXsi3Velgg9/UR3HfOsBoLlVwffHLhTQNkB7teqV
         VC+X8AgfSvX6c1HRl2NTUmdpx9trXFjyyd5vRwPKBZeKNX5H0eVuuCTIl0KFgJxo6Ntv
         osFxyMvH6WoytqCqf096gLk+JNhoIT0sCXHQuzv8307x3EL3LIqtdwhd5+zaa6fjPrkp
         sw1DxpgKZsicXLjmwZTfOhdtLETo0F4DDRGPpAW6p0CuzSleIjgxQ6h/u4e8wkLHWOvW
         u5IA==
X-Gm-Message-State: AGRZ1gKC42VKtt24QdOpSYo0larakmT8dxuBIai8w255/7x6KK1s4fBr
        Hw9RiO8EC7X5YwMVsRfRJGBz8ZqRYw8eyzDCGxo=
X-Google-Smtp-Source: AJdET5e2GDWH26bc6mxCsOK9RAFJHUsO8ydQxDts2kXsgfJZTKNSQnlPvfmC9B0VT18NjFYmOO480pEM4T9NQqa0zcs=
X-Received: by 2002:a25:4e03:: with SMTP id c3-v6mr438411ybb.325.1540934815156;
 Tue, 30 Oct 2018 14:26:55 -0700 (PDT)
MIME-Version: 1.0
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com> <20181030205614.40754-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181030205614.40754-2-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Tue, 30 Oct 2018 23:26:44 +0200
Message-ID: <CAOQ4uxhDdm4vmbcPeqnJkZF8U5Qygk4KT36JLejhkJU382z2KQ@mail.gmail.com>
Subject: Re: [PATCH v7 01/11] VFS: move cross device copy_file_range() check
 into filesystems
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        overlayfs <linux-unionfs@vger.kernel.org>,
        linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 10:56 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> From: Olga Kornievskaia <kolga@netapp.com>
>
> This patch makes it the responsibility of individual filesystems to
> allow or deny cross device copies.  Both NFS and CIFS have operations
> for cross-server copies, and later patches will implement this feature.
>
> Note that as of this patch, the copy_file_range() function might be passed
> superblocks from different filesystem types. -EXDEV should be returned
> if cross device copies aren't supported.
>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Steve French <stfrench@microsoft.com>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting |  7 +++++++
>  fs/cifs/cifsfs.c                  |  3 +++
>  fs/nfs/nfs4file.c                 |  3 +++
>  fs/overlayfs/file.c               |  3 +++
>  fs/read_write.c                   | 12 +++++++-----
>  5 files changed, 23 insertions(+), 5 deletions(-)
>
> diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
> index 7b7b845..897e1e7 100644
> --- a/Documentation/filesystems/porting
> +++ b/Documentation/filesystems/porting
> @@ -622,3 +622,10 @@ in your dentry operations instead.
>         alloc_file_clone(file, flags, ops) does not affect any caller's references.
>         On success you get a new struct file sharing the mount/dentry with the
>         original, on failure - ERR_PTR().
> +--
> +[mandatory]
> +       ->copy_file_range() may now be passed files which belong to two
> +       different superblocks of the same file system type or which belong
> +       to two different filesystems types all together. As before, the
> +       destination's copy_file_range() is the function which is called.
> +       If it cannot copy ranges from the source, it should return -EXDEV.
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 7065426..ca8fc87 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
>         unsigned int xid = get_xid();
>         ssize_t rc;
>
> +       if (file_inode(src_file)->i_sb != file_inode(dst_file)->i_sb)
> +               return -EXDEV;
> +
>         rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
>                                         len, flags);
>         free_xid(xid);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 4288a6e..5a73c90 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>         ssize_t ret;
>
> +       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +               return -EXDEV;
> +
>         if (file_inode(file_in) == file_inode(file_out))
>                 return -EINVAL;
>  retry:
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index aeaefd2..0331e33 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>                                    struct file *file_out, loff_t pos_out,
>                                    size_t len, unsigned int flags)
>  {
> +       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +               return -EXDEV;
> +
>         return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>                             OVL_COPY);
>  }
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 39b4a21..c5bed2e 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1575,10 +1575,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>             (file_out->f_flags & O_APPEND))
>                 return -EBADF;
>
> -       /* this could be relaxed once a method supports cross-fs copies */
> -       if (inode_in->i_sb != inode_out->i_sb)
> -               return -EXDEV;
> -
>         if (len == 0)
>                 return 0;
>
> @@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>          * Try cloning first, this is supported by more file systems, and
>          * more efficient if both clone and copy are supported (e.g. NFS).
>          */
> -       if (file_in->f_op->clone_file_range) {
> +       if (inode_in->i_sb == inode_out->i_sb &&
> +           file_in->f_op->clone_file_range) {
>                 ret = file_in->f_op->clone_file_range(file_in, pos_in,
>                                 file_out, pos_out, len);
>                 if (ret == 0) {
> @@ -1604,6 +1601,11 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>                         goto done;
>         }
>
> +       if (inode_in->i_sb != inode_out->i_sb) {
> +               ret = -EXDEV;
> +               goto done;
> +       }
> +
>         ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
>                         len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
>

If this check would stay here for long I would say it needs a TODO comment
of some sort, similar to the one that was removed, but I expect
someone, if not Olga,
will pick this up shorty after merge. If nobody else, I probably will.

So I re-affirm my Reviewed-by.

Thanks,
Amir.
