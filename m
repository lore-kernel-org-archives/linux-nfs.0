Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0E7DC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:28:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5400820831
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:28:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZFVV43bO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5400820831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726973AbeJYM7S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 08:59:18 -0400
Received: from mail-yb1-f194.google.com ([209.85.219.194]:35591 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726308AbeJYM7R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 08:59:17 -0400
Received: by mail-yb1-f194.google.com with SMTP id k132-v6so3127444ybc.2;
        Wed, 24 Oct 2018 21:28:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1qDR1fCNXP24M0EbxWQHYaVHSMy1GsjtfuuY3q+y0NM=;
        b=ZFVV43bOMojxu4T+l1vKYHHv/v8O47fJeYxp1r/kFYVKq+a9kk8rTXGxHNjFP7gyif
         vYiZ28YTaFlZLZ1wkkL/RJwUgykA28S2FZaeCRvUBxb3Z5Wx8Tx7NhrLpw8G9/rLZTt+
         dl+NhN0igeEv8GaAn9kACmc1XQQjhGkwrfh1C9oooItWz03YktDIWk2Pwp4PNaBUIcGX
         PkssjO5YK0lEi5EFEo6fYJGyrkzh3/iOmxttAxeQ5UJOZXfHwFJsqlFVkiZ9V2Xfa7wP
         Kq1E37KWvyjsM7R37z1MGxibUdrUGzRKpT+8KDUgGTCFuDzpoWRiZpOwMyg8ZCCc/QF/
         ZrOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1qDR1fCNXP24M0EbxWQHYaVHSMy1GsjtfuuY3q+y0NM=;
        b=Kq+5NXha1ePsejgTWKdT/oXJsOIv60k/NAdRoboEBeuQYMHWJ61TWIDEeWU0NYZK8+
         JFfRmTeLvu447ACt2U7URTUWyE0aC2ShuKIdPRp5IiwsktfsLd3ncq8E0jDmmkF5ql9P
         0MExmMrt+ojCr8D9pRBmqf7HXjkVZaSJ4l350/dd6lrKaGRcxspDXCEQDpteC7t50yun
         LXd0KidOWgtMR58wQ/h1JgtPU2DawAq1rzniw2CqHyCuL4GTB+3XIsckKXWDJ0pfisAf
         StYkQb5BSWqAVek1ZmC035+41MvYY4W9ushXHVI46lLTFC3cg4ZV9fk72LNqc1wzJcRb
         cOVg==
X-Gm-Message-State: AGRZ1gIbG6FciqFrwgmvljykuBWFjVdTDqhZUH/6HTspYSzxnaoyO5j6
        IExv5b3y1QyOEvsxaXn7WQh38Xc1qXp6z0qgA00=
X-Google-Smtp-Source: AJdET5cqnQYulilLZisc6GhROjs9H8bV9wmH7kgRdHjEDd/4uPzWacEFwqSy2PaTLvTDq4hMZmTvA6qGJeWUH57YSZc=
X-Received: by 2002:a25:37cf:: with SMTP id e198-v6mr4823499yba.243.1540441699500;
 Wed, 24 Oct 2018 21:28:19 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com> <20181024195837.35532-3-olga.kornievskaia@gmail.com>
In-Reply-To: <20181024195837.35532-3-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 07:28:10 +0300
Message-ID: <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
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

On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> From: Olga Kornievskaia <kolga@netapp.com>
>
> A proposed VFS change removes the check for the files to reside
> under the same file system. Instead, a file system driver implementation
> is allowed to perform a cross-device copy_file_range() and if
> the file system fails to support it instead fallback to doing
> a do_splice copy. Therefore, EXDEV is no longer a possible error.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  man2/copy_file_range.2 | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> index 20374ab..723b2d0 100644
> --- a/man2/copy_file_range.2
> +++ b/man2/copy_file_range.2
> @@ -39,7 +39,8 @@ The
>  .BR copy_file_range ()
>  system call performs an in-kernel copy between two file descriptors
>  without the additional cost of transferring data from the kernel to user space
> -and then back into the kernel.
> +and then back into the kernel. Since kernel version 4.21(???) passed in
> +file descriptors are not required to be under the same mounted file system.
>  It copies up to
>  .I len
>  bytes of data from file descriptor
> @@ -128,10 +129,6 @@ Out of memory.
>  .B ENOSPC
>  There is not enough space on the target filesystem to complete the copy.
>  .TP
> -.B EXDEV
> -The files referred to by
> -.IR file_in " and " file_out
> -are not on the same mounted filesystem.

Man page serves users of old kernels as well. You should not delete this
expected error, but you can add "... and kernel does not support cross
filesystem copy".

Thanks,
Amir.
