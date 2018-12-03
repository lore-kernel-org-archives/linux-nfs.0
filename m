Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2A29C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:04:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA5EF214C1
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:04:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Hxg7p5A8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA5EF214C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726191AbeLCLEy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 06:04:54 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:41553 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725888AbeLCLEy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 06:04:54 -0500
Received: by mail-yw1-f65.google.com with SMTP id f65so5194831ywc.8;
        Mon, 03 Dec 2018 03:04:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yYbezS2DF8oB0aKiloCHakgmqPdE9VfXa786+ZWAcAQ=;
        b=Hxg7p5A8LksQPrJp5yFcxVmRsutTMyRCS6rDmDnqKSauMg91xIQ1k2/7l80d883gX5
         IjUg3FW4m3/q4nOYAX1FCsPHESaEcjcAMZLlm9VBviCQENnVKRrLaSqICj0m07Z9SjtJ
         cPesSRpfSiO67+kpCPvweJvzheLWk2NVrhfM0PFh6z8R4LDNBW8W2eBRlNZ+jdVHJGfg
         4pgbd+MZnDgTrndb4gUZUjx0KLl5Ed9kwPp+fwJmBtsC5/JbnJNDlh3gb5l25L+heqBn
         oVLsl2oMBI0rcKuaxPybLxmUrNqfNsPU6GvMw+iSxY/hTL6M0YU3QBYDAexwsLK8a/Iv
         mEHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yYbezS2DF8oB0aKiloCHakgmqPdE9VfXa786+ZWAcAQ=;
        b=Ab2n8KQkPctlJGh6y1tCs51lFax5HM41QcOOppoqoGdyZk3nMDAsz4izpB1KLIX6+H
         jYtwpR4ar47721MAv5ByKkj9DPXSSYw8svnT+ML2pZcdepcputUAhtG0dG+S3nhXnCOe
         QVCh3J3/OHrQWHtfJqkl6kGG5n1VgNJp4AdjKPrVLC/Z48lmBRpBNoe/kSMLrVk5XyiJ
         PBJWO3cacNl+CyYy6A1PpjTSDXvfD1emQfIes+NfYzOeXPpk9xNjjXFJmWHXEu9wQor6
         eFPb2mU3isHPYMIpaFhRQBL0sCn/uFMtX6KUgN4uqWYXFoSoa1/gi0luj4EF5lf508U1
         +fng==
X-Gm-Message-State: AA+aEWaiFdUMg5+CflmT9WFkFVBDdzAGCYBvHEKtIYRsDD8SEDGveF5w
        aYKTyoB50KJsJ0TzR2VK5KCFMp4wtDfJZ9LRuMMVGRM7
X-Google-Smtp-Source: AFSGD/UiyrsQxOqCbA5c37ynWu5+MWmfu8ymrPZoK9Ax7iti1JTlKwDTFrQIUXzBthu27U8BbE5r6TliP/ByDi/Hfn8=
X-Received: by 2002:a81:2916:: with SMTP id p22mr15137935ywp.176.1543835058475;
 Mon, 03 Dec 2018 03:04:18 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-9-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-9-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 13:04:07 +0200
Message-ID: <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> before we can enable cross-device copies into copy_file_range(),
> we have to ensure that ->remap_file_range() implemenations will
> correctly reject attempts to do cross filesystem clones. Currently

But you only fixed remap_file_range() implemenations of xfs and ocfs2...

> these checks are done above calls to ->remap_file_range(), but
> we need to drive them inwards so that we get EXDEV protection for all
> callers of ->remap_file_range().
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/read_write.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 3288db1d5f21..174cf92eea1d 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
>         bool same_inode = (inode_in == inode_out);
>         int ret;
>
> +       /*
> +        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> +        * the same mount. Practically, they only need to be on the same file
> +        * system. We check this here rather than at the ioctl layers because
> +        * this is effectively a limitation of the fielsystem implementations,
> +        * not so much the API itself. Further, ->remap_file_range() can be
> +        * called from syscalls that don't have cross device copy restrictions
> +        * (such as copy_file_range()) and so we need to catch them before we
> +        * do any damage.
> +        */
> +       if (inode_in->i_sb != inode_out->i_sb)
> +               return -EXDEV;
> +
>         /* Don't touch certain kinds of inodes */
>         if (IS_IMMUTABLE(inode_out))
>                 return -EPERM;
> @@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
>         if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
>                 return -EINVAL;
>
> -       /*
> -        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> -        * the same mount. Practically, they only need to be on the same file
> -        * system.
> -        */
> -       if (inode_in->i_sb != inode_out->i_sb)
> -               return -EXDEV;
> -

That leaves {nfs42,cifs,btrfs}_remap_file_range() exposed to passing
files not of their own fs type let alone same sb when do_clone_file_range()
is called from ovl_copy_up_data().

Thanks,
Amir.
