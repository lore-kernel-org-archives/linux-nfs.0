Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC00EC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:36:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 72FCC20850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:36:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OUDJxh8b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72FCC20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726502AbeLCMhF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:37:05 -0500
Received: from mail-yb1-f193.google.com ([209.85.219.193]:35267 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726238AbeLCMhE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:37:04 -0500
Received: by mail-yb1-f193.google.com with SMTP id z2-v6so5195123ybj.2;
        Mon, 03 Dec 2018 04:36:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JDe2htvdGYJ17xTCzqD0/PZFt7huaU7qjeFKzScUHlI=;
        b=OUDJxh8bMDGvGBfjh1orX9uRTpFjY6bAU4Wo/tWxYKSM9+9Lghco3Gs4/+8ZAdQYLT
         jGbuEE5jaATrtfQ9WxtMZ58ZR0H6aH+6ENXpaaq8pPYdPT4D83aNfm4XSO1LnbCPUZhk
         osbweVUSFAbL6XSY/TVGgrG9IcHvnKpM8i2lprXYP47klkNG0dBjlvJTecmMj5KxxiH9
         OTUQqRWHQLdS/anm1UCKO/xiFSx0mDLMxkrT8E4evwfeW7n5sA8rKGYcqGMSeU77ss/R
         aUImxIyZdOnQbBw6cheN5+HJFaeLCnVfqYPOaIqQ7WC1Y+3nI4W907CD7QEkIP/IQ8Pw
         R1jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JDe2htvdGYJ17xTCzqD0/PZFt7huaU7qjeFKzScUHlI=;
        b=q9FuBBjXMPOOEnUWuQ+hGalKpind6HjBCX4FEhC+/ZxCT29l53AeYCHwdzKW3mtQod
         fFIhi/j7wUH1qxqTNoeIpkG72hWLQZq6gbGrY78Jd2PsaKHt4pO7TtI3ZYBOs6zgzqS4
         afvUMUktW6jn9rUlPTGzZUisROM+oQ8GX8Mz112QhJwEZV5mAOZNE15cnmBfFBkNbjf2
         cShGanSRfMohhI/H/ZxUK5bQWlMneEh8TVjIYqcvwNcPbBNhNCrUBpuirpt5sIye6oQg
         Lgqc+/tRub55k4r3ShQlkl6Gxvr1epN8tcqATlaAc27H8XwrThUr6Gh1O/tWINmQ/Z9B
         4TnQ==
X-Gm-Message-State: AA+aEWY5Tdn/2vF3jOgEteWPsJ3F7Hj09GprwZeDg8oC6dIgBZvoXL51
        JKSxD3bh8nm1PnaNYeJcIgAZK/9qYXM7Jz4XjKA=
X-Google-Smtp-Source: AFSGD/VSQRc7ZEyrGZZUN2vRjotx4c2mh8ntr7sCGjPMvEN5BGWSnmlFVcs6FUfR10rTvBQpRq8ey9SR3Dh9vMHsPl0=
X-Received: by 2002:a25:e4c1:: with SMTP id b184-v6mr15077021ybh.337.1543840571423;
 Mon, 03 Dec 2018 04:36:11 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-10-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-10-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:36:00 +0200
Message-ID: <CAOQ4uxhiWGXrdzvXzsYcaTGL06xipDUC8KWMwGTBfcM+hZoekA@mail.gmail.com>
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
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
> We want to enable cross-filesystem copy_file_range functionality
> where possible, so push the "same superblock only" checks down to
> the individual filesystem callouts so they can make their own
> decisions about cross-superblock copy offload.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

Looks good.
You may add
Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Similar comment about overlayfs as patch 3.

 diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index 68736e5d6a56..34fb0398d016 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -443,6 +443,14 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
>         const struct cred *old_cred;
>         loff_t ret;
>
> +       /*
> +        * Temporary. Cross device copy checks should be left to the copy file
> +        * call on the real inodes, but existing behaviour checks the upper
> +        * files only.
> +        */
> +       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +               return -EXDEV;
> +
>         ret = ovl_real_fdget(file_out, &real_out);
>         if (ret)
>                 return ret;
> @@ -491,7 +499,7 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>         ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>                             OVL_COPY);
>
> -       if (ret == -EOPNOTSUPP)
> +       if (ret == -EOPNOTSUPP || ret == -EXDEV)
>                 ret = generic_copy_file_range(file_in, pos_in, file_out,
>                                         pos_out, len, flags);

This fallback is already provided by vfs_copy_file_range().

Thanks,
Amir.
