Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63D78C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 08:19:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 26DBB208A3
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 08:19:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mY4HPfZZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26DBB208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726069AbeLDITI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 03:19:08 -0500
Received: from mail-vs1-f65.google.com ([209.85.217.65]:34105 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726017AbeLDITI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 03:19:08 -0500
Received: by mail-vs1-f65.google.com with SMTP id y27so9291454vsi.1;
        Tue, 04 Dec 2018 00:19:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0537H4La/WYlNomM31b5svhRVhE/diqE8fHXLqpRrag=;
        b=mY4HPfZZZL00JIMov86UrrMChTqaLN+IQEfjzRDwE2GItIT0/fFyWEXKTMBagoxHHD
         rdNhYZwiHgUi2enfdoSUoaRaHbcfWBrU2Ib9AFWUajOyMWb5zGLLEoYT6a85O5wYdp9X
         tzdyAVhDRZfVAKXhjAqN7t371glAhsN+wOf1ly/sZwL5+LkiBR2rCDgo0gBAqGlbF7PF
         pLv9pt8CJcQyq6FHaVe8DEyukHxnXCFfLHixJnKQgPIgLvfpa9Gnm59RXJN8Nv0tlr+d
         oUd85vcAWgPQIevI+2Ewa7gOifWbiZ3y6sMxCQS9iNLDybT2ZEYv2vQW611Xn8v/6gS9
         6aTw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0537H4La/WYlNomM31b5svhRVhE/diqE8fHXLqpRrag=;
        b=tJn1Gf9aFJWmkv3J8y6J1ZYWJVeJvlN3UNmOCyLMu8WXirQzvr47fYRRYyzPJEWo2l
         Y/Co0C1NlchUhDirvko1y13P1h6vQGch05bCCAxKR518i1J5iWMkwCKafJM65hwvFEWm
         ToPO1fYLAVBHYnHEThPkrasyhEI50fXSPQwrTfw2ylX6GB4TR5NdQXFHOetTlPovwbNR
         ohnLw1G8EcmmILGNsl8WiNuYdV/7+tCSZuf7VgyPNgi8SreIaofHUXkC1zHyGtGTSKem
         YxtvYoiEEnEMZjW3cQewtwwkXN0dXKnMxun3d57qdf5QSnQI4WmBsWDOnSvFyPDcVrLs
         jY2w==
X-Gm-Message-State: AA+aEWZrtxAZMu7y4VadJb6ceP8NYLFq2hX3q48o4zeGCysFgFF/XNJI
        z2UtBK31Ofqh+ugPh61wCTvpE6+6KMVhqi+fGg77ng==
X-Google-Smtp-Source: AFSGD/WLKTP7jegptcp5A3mcVTUYMY6FDfYSWoWoupi+CJY45IwTqHlsdC1u2R98M8/yO5AP90Bq7exhAYOXhSmTwVM=
X-Received: by 2002:a67:77c4:: with SMTP id s187mr8294487vsc.85.1543911545610;
 Tue, 04 Dec 2018 00:19:05 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-9-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-9-david@fromorbit.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 4 Dec 2018 03:18:54 -0500
Message-ID: <CAN-5tyEumh4A+74Xp+ywk0-73X8iqhrv81S+mfLLPExsp4SE8g@mail.gmail.com>
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
To:     david@fromorbit.com
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 3:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> before we can enable cross-device copies into copy_file_range(),
> we have to ensure that ->remap_file_range() implemenations will
> correctly reject attempts to do cross filesystem clones. Currently
> these checks are done above calls to ->remap_file_range(), but
> we need to drive them inwards so that we get EXDEV protection for all
> callers of ->remap_file_range().

If there is no check before calling ->remap_file_range() then NFS
barfs. Perhaps it needs a check internally that checks that both file
handles are from the NFS but this was not needed before. Or there
needs to the a check in VFS.

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
>         if (!(file_in->f_mode & FMODE_READ) ||
>             !(file_out->f_mode & FMODE_WRITE) ||
>             (file_out->f_flags & O_APPEND))
> --
> 2.19.1
>
