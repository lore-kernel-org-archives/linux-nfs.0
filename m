Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC3EDC04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:22:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 793EA20878
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:22:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CIB0W6Pr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 793EA20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726167AbeLCKW6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 05:22:58 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:45478 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725947AbeLCKW6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 05:22:58 -0500
Received: by mail-yw1-f65.google.com with SMTP id d190so5140931ywd.12;
        Mon, 03 Dec 2018 02:22:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j6BOJXPsNrG1fKIq+HWk5IVPhoT2cjeFD09Cm0giQOc=;
        b=CIB0W6PrBiH/TByllLgyL7KvnC7Gp0ivr1LNixt2HB4H1UG520uRN8vPdonqapbENA
         ofVivcaKjyKDCuddBHAhQ6FBpHqZfkSHjBs7+mX/MxSjeHoMAMVLC+fQ4QKaHKdkBrOj
         XKWZi2Xk0R3P4OGvWgu+AL5bTV8HC6mXJkNRsjGVGifkJyWnjuMcXzFK4UJ+TdBzASN2
         oM3LiX0LpPYcD3nm8+W3/7U6CmgfC7dSQrs57z+gnWxf9vuS9eoTg5Dq6X0HFJrp0xkX
         P/I4pPIjoXvcFwOrXxNDNHDdnbURO9uhS2VakOV32Vz1WFYbmMdF6BLLLz57qu70LC5o
         JmwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=j6BOJXPsNrG1fKIq+HWk5IVPhoT2cjeFD09Cm0giQOc=;
        b=XH8UTnNoGbBugDogkZyXJGH4dk3j+HK+MyfrmRiE4i8b08iPZj/s3E6MY78Zy0SgXJ
         zv4d5tONAlInVhRG9sZihOUfU7PDotzF3Lkvgi6tDkRsn78eaZE/nXHiBUXSrNEeshVi
         VCLJhEs4pby01maC9ACYAjvn0YfmF0btAz8dRKpqgsER8FTpnzZlNmmH00wJCoXxfIQ8
         ANWtRvQqlQPYIi8yndIdBtfQqjs/EL52yYzkbynC06B14S8GLix60d7qFke0mcWZ8RVt
         3Kba8J/Nzt56h42x1tHQul8TQHTyb2lU42kkthERQxBSknHcNQlpH23o96v+QR3X+kpa
         VDcA==
X-Gm-Message-State: AA+aEWZ0QY1qXpg67mmGmo/YCzGvQZm7w52qFYfZCyjuLHwADmIU+fYb
        SEjVjiXvl3JSVxDAHeyCYWmG/9177stYQmvPzh8=
X-Google-Smtp-Source: AFSGD/XmDURIQeN8AgfrnL0QRzTlTdONpB54r9GwNua96AJ6xliDKN2EcY0uTpuXrdI7j1BXVv5Ndd4UlmtUDeZy2Wg=
X-Received: by 2002:a81:2916:: with SMTP id p22mr15047887ywp.176.1543832552466;
 Mon, 03 Dec 2018 02:22:32 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-4-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-4-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 12:22:21 +0200
Message-ID: <CAOQ4uxjRErxoOTAr+yzu7s5S4SEYZuw6GcfQ-M7UXAasTG9Knw@mail.gmail.com>
Subject: Re: [PATCH 03/11] vfs: no fallback for ->copy_file_range
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
> Now that we have generic_copy_file_range(), remove it as a fallback
> case when offloads fail. This puts the responsibility for executing
> fallbacks on the filesystems that implement ->copy_file_range and
> allows us to add operational validity checks to
> generic_copy_file_range().
>
> Rework vfs_copy_file_range() to call a new do_copy_file_range()
> helper to exceute the copying callout, and move calls to
> generic_file_copy_range() into filesystem methods where they
> currently return failures.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

You may add
Reviewed-by: Amir Goldstein <amir73il@gmail.com>

After fixing the overlayfs issue below.
...

> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index 84dd957efa24..68736e5d6a56 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -486,8 +486,15 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>                                    struct file *file_out, loff_t pos_out,
>                                    size_t len, unsigned int flags)
>  {
> -       return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> +       ssize_t ret;
> +
> +       ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>                             OVL_COPY);
> +
> +       if (ret == -EOPNOTSUPP)
> +               ret = generic_copy_file_range(file_in, pos_in, file_out,
> +                                       pos_out, len, flags);
> +       return ret;
>  }
>

This is unneeded, because ovl_copyfile(OVL_COPY) is implemented
by calling vfs_copy_file_range() (on the underlying files) and it is
not possible
to get EOPNOTSUPP from vfs_copy_file_range().

Thanks,
Amir.
