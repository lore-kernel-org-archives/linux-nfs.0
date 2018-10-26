Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AB5EECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 22:10:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2581B2085B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 22:10:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h92DMQsg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2581B2085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728609AbeJ0GtV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 02:49:21 -0400
Received: from mail-pl1-f195.google.com ([209.85.214.195]:36818 "EHLO
        mail-pl1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728605AbeJ0GtV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 02:49:21 -0400
Received: by mail-pl1-f195.google.com with SMTP id y11-v6so1109827plt.3;
        Fri, 26 Oct 2018 15:10:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N1bytJIJou6ktvBBXL+fsymYTblhAnkyVsym0Jsv580=;
        b=h92DMQsgCucANXwJu8NGeCudmF/hG9YUdBGxFlIaMACn6Do5QTrZMAkJ3wvkiUEhJI
         o1J6NhZTLoPjjV4ldDpew2DFseEgyGqlql5IBgIISKkXAjrIunU64vf7YFqsLcnruDRC
         qzBImytJdXwgUZG+iAJnTjcEj5ug/wyj0wjii16yHGemr2dm7YYdgIlzV5Qj/21juEb9
         N7K6eOS5KC9Jm73JrnKNo/QbOZ6h2UNVF24ifGZ5W+kdV02FWLatoKmC2JPRLkxVBqJm
         V2ArWzdu40YdyI6pMZ4ljIYR0E5AMstYVr6lQFJrQwHcsF+ygCf3CaTiyH2l7xAcCMpH
         bOtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=N1bytJIJou6ktvBBXL+fsymYTblhAnkyVsym0Jsv580=;
        b=t+s/wXpOoCEU4BT17FFzA+qAVjpAJCrA426TWRyJNiCdfqXPfXaceWfW2xb2HVNRS7
         HHVKBAG+8WdvaOEjrlekDYWcYO22KVZTky7FhrS3GHoxvSaC2qTAh+ot86h0p7k9M66U
         w77KnfcsO9TLnHvjFj5mE3psX4D5nrb7JmUKjFoeJcdhZfTUDHKbdPF1n1F3BC61JAjg
         VjtqeijiKfsMTDmFVk6eV9jheh11r8adc2oUk5vExnLDtfOOl154oDRXIYPjspXaNZ1e
         zKskS+QvwhRLIKZx++Kx4MuFSsv8fNp250DFowdstoH3xybl+dIH04Sb5Or+hhHWvZCk
         n+cg==
X-Gm-Message-State: AGRZ1gIDpBG9kQT7SU8TAExfMnVjGDhn+GCF1O5bz1W55IR35FBqxh4n
        sHa1KRI1DK32MSL689tkSlYR1Eo/GHpCi+iJp7w=
X-Google-Smtp-Source: AJdET5fR4aAqZ1G7SCNPHF2p0RZkt8ndBq65yvlaK/uAopHDov4F7qnlKAb10PwZnIQbKAYGBYtTWBa01jUewhX8QRc=
X-Received: by 2002:a17:902:7b85:: with SMTP id w5-v6mr3523700pll.290.1540591834538;
 Fri, 26 Oct 2018 15:10:34 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com> <20181026201057.36899-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181026201057.36899-2-olga.kornievskaia@gmail.com>
From:   Steve French <smfrench@gmail.com>
Date:   Fri, 26 Oct 2018 17:10:22 -0500
Message-ID: <CAH2r5mtncAh0_KA1sPS435a+6m9EkgUsRi7bqmdZnxOh-3qQ1A@mail.gmail.com>
Subject: Re: [PATCH v4 01/11] VFS: move cross device copy_file_range() check
 into filesystems
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Miklos Szeredi <miklos@szeredi.hu>, linux-nfs@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        CIFS <linux-cifs@vger.kernel.org>, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks fine to me - will relax the semantics in followon patch for
cifs.ko (to allow for cases where we can support it) as soon as this
is in.

Reviewed-by: Steve French <stfrench@microsoft.com>
On Fri, Oct 26, 2018 at 3:11 PM Olga Kornievskaia
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
> if cross device copies aren't supported, causing the VFS to fall back
> on using do_splice_direct().
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting | 7 +++++++
>  fs/cifs/cifsfs.c                  | 3 +++
>  fs/nfs/nfs4file.c                 | 3 +++
>  fs/overlayfs/file.c               | 3 +++
>  fs/read_write.c                   | 9 +++------
>  5 files changed, 19 insertions(+), 6 deletions(-)
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
> index 7065426..f2d7f4f 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
>         unsigned int xid = get_xid();
>         ssize_t rc;
>
> +       if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
> +               return -EXDEV;
> +
>         rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
>                                         len, flags);
>         free_xid(xid);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 4288a6e..09df688 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>         ssize_t ret;
>
> +       if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +               return -EXDEV;
> +
>         if (file_inode(file_in) == file_inode(file_out))
>                 return -EINVAL;
>  retry:
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index aeaefd2..5282853 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>                                    struct file *file_out, loff_t pos_out,
>                                    size_t len, unsigned int flags)
>  {
> +       if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +               return -EXDEV;
> +
>         return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>                             OVL_COPY);
>  }
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 39b4a21..fb4ffca 100644
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
> +                       file_in->f_op->clone_file_range) {
>                 ret = file_in->f_op->clone_file_range(file_in, pos_in,
>                                 file_out, pos_out, len);
>                 if (ret == 0) {
> @@ -1600,7 +1597,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>         if (file_out->f_op->copy_file_range) {
>                 ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
>                                                       pos_out, len, flags);
> -               if (ret != -EOPNOTSUPP)
> +               if (ret != -EOPNOTSUPP && ret != -EXDEV)
>                         goto done;
>         }
>
> --
> 1.8.3.1
>


-- 
Thanks,

Steve
