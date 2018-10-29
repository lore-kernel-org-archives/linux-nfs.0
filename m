Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F04EFC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:11:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9A622082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IHx8eZd/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9A622082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728431AbeJ3DBB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:01:01 -0400
Received: from mail-yw1-f65.google.com ([209.85.161.65]:44616 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727502AbeJ3DBA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:01:00 -0400
Received: by mail-yw1-f65.google.com with SMTP id t78-v6so3753809ywg.11;
        Mon, 29 Oct 2018 11:11:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AlSUq5B/8leYwSCQlzB2ObUyMyMPo6Jn2m81hvDyQ9o=;
        b=IHx8eZd/aPdBz8LEz2/dSunrwQTUoGqQELUHpd5wqjM0W4kCLYcjmruntoxpc2xiRd
         gTuRrVw+7x86V/mRPK+aWcONOE9azke0P1fd0pBdRTegc5SeDNaniSaOLbulhvqHCN20
         swDLVfW0BW81qpbg5feqSH/pSdG8oqjGYFvV3mm8622AaT4gmFCqNLCnQxJHGObEss5c
         0d4yfDWDG3P1YmQcVWOacR2h/U7zl1ZPdA+LB71ZCinPuXx5q3AYIWpBi3YB9UGgTQYX
         Jk+B1wXmJF2N96WKULr4yyClS9mo5RuhYfuyscHQlDhBqae7yGl5CplFT+LUJxg+9s8j
         YsrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=AlSUq5B/8leYwSCQlzB2ObUyMyMPo6Jn2m81hvDyQ9o=;
        b=Yfygu/c+qT2IR3O/KrOocjjr0rYI4URNr4QSt5RPnlObL9ZH3pU8gembWkTbQtxnrI
         258Q3rjWtrc73T0Z0S743L+OKzCL7bVNPXS/xnWwl3G20Y2iB+KORni53Mw9zechyrw0
         ixJNjywDu5xBzUP5f2cF1t+m4QjSzPVyY7nQX26uP5ruSdqdZujKk+IajHUHRt0UDlOS
         IXcKe8LHZM45PhIbwxThGlI4Qb7Zgxu/b6cYlsyF6/CheEOQqjOuePwUM/pnKIF4oyCN
         LHlEhx49xKvXvyBGUUvffsQKUDQT3yuKHpOpGocIxsHQfeO39VXvrA9QyctaWEWzUiiN
         RcYg==
X-Gm-Message-State: AGRZ1gJxtWx5bG7+NteOt6E1i0UVSaqsIxHEwVF0RbEVCDKhviqpFaQR
        B60ykbMfIHFwgueGAfNZdQZiL61+J7W2TbN9fkc=
X-Google-Smtp-Source: AJdET5dC1sAu6tC4PqxX4C+ducsMvSvqML3RDBbcOESZwkuKmEisI/1yc/FtTpMnW2y9XF4JGpzrlIuQMIzadEGtYJA=
X-Received: by 2002:a81:ac1f:: with SMTP id k31-v6mr6954113ywh.248.1540836675013;
 Mon, 29 Oct 2018 11:11:15 -0700 (PDT)
MIME-Version: 1.0
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com> <20181029174059.38326-4-olga.kornievskaia@gmail.com>
In-Reply-To: <20181029174059.38326-4-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 29 Oct 2018 20:11:02 +0200
Message-ID: <CAOQ4uxibDdXdf1WVe5V+vuA=TiJhETq+aSS7jSwBpqYV+MbrdA@mail.gmail.com>
Subject: Re: [PATCH v5 02/12] VFS: generic cross-device copy_file_range()
 support for all filesystems
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
> If a filesystem does not support cross device or cross file system
> type copy offload functionality, then this patch provides a fallback

The flaw in this statement is that in the common case, filesystem that does
not support copy_file_range, doesn't have copy_file_range() file operation,
so in fact, patch [1/12] has already implemented
"generic cross-device copy_file_range() support for most filesystems"
This is why the order of this patch in the series is awkward.
Please see my suggestion in comment to patch [1/12].

> to a page cache based physical data copy. This means the
> copy_file_range() systemcall will never fail with EXDEV, and so in
> future userspace will not need to detect or provide a fallback for
> failed cross-device copies anymore.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/read_write.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 7a912e3..cff59bd 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1597,7 +1597,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
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
