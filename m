Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE171C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:03:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A839620870
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:03:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tz2Kwelu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A839620870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728177AbeJ3Cwx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:52:53 -0400
Received: from mail-yw1-f65.google.com ([209.85.161.65]:36448 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728104AbeJ3Cwx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:52:53 -0400
Received: by mail-yw1-f65.google.com with SMTP id h21-v6so3504113ywa.3;
        Mon, 29 Oct 2018 11:03:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6LQCPsrtEkwZaOao99hCgQ8koY1AcZtGP8XM5gu9tmM=;
        b=tz2KweluEmPk+WCrJwQ9f/tnn3cMvta56AsgPwEyc6b8oDRLBJWpWeUySYgR0QpsRm
         cMj6BxDb96N3a/XZP3q6nbYl1kS1j6w627TP7aL99G/klSQ4KirY8OJEbdirzm8cL23f
         SFRr62/GkeOQ273ES2fWvFjR2N7go1SeceHTl9GR508nt5ldlyUGkluGdQyZwjJo2re0
         IBc076RLpMAgA7wvR2o1Rudjt2+z8Wc8q21MB2XbXGAAua2a+5yV0VyP8rIfMRXK6H7g
         mvx+z98h01wQFIWPzTY/Sz4m9zmTtPRlK+N0MF6qXE7XsiT0unMpjaYVzoVa4PdI9s01
         RO9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=6LQCPsrtEkwZaOao99hCgQ8koY1AcZtGP8XM5gu9tmM=;
        b=M5nX/+WWkNvNTP8m2arKFnzXMz5FLAHFoF0kAndhbggdsqX9J/l9K5Dv3tdvXDfubb
         xUBUituEDhjGPiubSbE4RMMyr5TzcFTdxH0v//qVtjk3+t46DeTb9i4YPQ2OVsXep4Yq
         7xP6FuP7k79rxJkXyA4pzau1rswmVIo3qAqExiAPhnRi555YfKcsWQmZ735IYGhrFs4i
         mlgEqtavQGtFXOGs30OpIiQneTp1V3+swcg66T2sis9TYIs1dOC26Nuq6Tny3tJUnpTS
         PtCCtQoGL3l/D4g+JmTN2Gi9aXSukmw1WWSfueeC2/Zl5eNGAT+3ezoysZh8fEjpmrvj
         A/8Q==
X-Gm-Message-State: AGRZ1gLgHHGyUGggvcscOlJ8I6VkrKdQDjjOXIAAIbh9NvzG1IL2DPb/
        CmbCNr3iTwFBt36F72gVix2HJcv5VZ6Y+u7zrI0=
X-Google-Smtp-Source: AJdET5ejBx+R7PmwphfzKOE4V1sop6TB0jcVt9JITDgYT3yK9A46MhLg7syCI+n35eJcfxnI3R45XIT86NhMs8rvLZY=
X-Received: by 2002:a0d:d181:: with SMTP id t123-v6mr14678432ywd.241.1540836189994;
 Mon, 29 Oct 2018 11:03:09 -0700 (PDT)
MIME-Version: 1.0
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com> <20181029174059.38326-3-olga.kornievskaia@gmail.com>
In-Reply-To: <20181029174059.38326-3-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 29 Oct 2018 20:02:58 +0200
Message-ID: <CAOQ4uxiUCPb7vDU9c34UL5RkzBemiq49YqOoXfHL4T=+rrL8vg@mail.gmail.com>
Subject: Re: [PATCH v5 01/12] VFS: move cross device copy_file_range() check
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

On Mon, Oct 29, 2018 at 7:41 PM Olga Kornievskaia
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

This Note is not ok.
As Dave commented, you shoud make this change in a separate path.
I will explain...

>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Steve French <stfrench@microsoft.com>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting | 7 +++++++
>  fs/cifs/cifsfs.c                  | 3 +++
>  fs/nfs/nfs4file.c                 | 3 +++
>  fs/overlayfs/file.c               | 3 +++
>  fs/read_write.c                   | 7 ++-----
>  5 files changed, 18 insertions(+), 5 deletions(-)
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
> index 39b4a21..7a912e3 100644
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

IMO, series will look the least awkward, if you start with "moving"
this check to before
 file_in->f_op->clone_file_range() AND before file_in->f_op->copy_file_range().
The title of the patch would be something like:
"VFS: generic cross-device copy_file_range() support for all filesystems"
(Dave's suggested commit message)

Then, in the next patch, which is this patch you posted
"VFS: move cross device copy_file_range() check into filesystems"

You will only need to remove the same fs check from before
file_in->f_op->copy_file_range() and add it inside filesystems.

I hope that is clear.

Thanks,
Amir.
