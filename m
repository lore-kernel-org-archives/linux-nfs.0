Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF90EC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 13:05:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E4A120878
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 13:05:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GCP5vBI9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E4A120878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725852AbeLCNGu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 08:06:50 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:35532 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725830AbeLCNGu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 08:06:50 -0500
Received: by mail-yw1-f65.google.com with SMTP id h32so5336308ywk.2;
        Mon, 03 Dec 2018 05:05:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Eo3EOaLWTp6yCV2t2P1SGEyPOWe0lwLjNo2QwXEfAHY=;
        b=GCP5vBI9bi2CCyYcMVGqXq41WNCbqeRs+TPKnNZCT7tUPZcVQT3FUj5AmD94S1n6P0
         8tRLhFHeBsO9l3aNGb6Jxk8mL66Y/5pwqWv0m53AAF1kW88B/fcBN1vwvmVWc9REhnRl
         GaBuS4lWNAJCOk7ZjhNlmVlElI71SNSIA08kwzJnTdV0PSp3aMmgLXtSIq3fxjq4bgbY
         IRRDOG3UBY8nEgL6WK5swUoXotdVisvV8r560djCIhH5qQHYNrHhYZeQRtL9ITY55M1q
         p8WzFE9uNI96180Kw1Y7q8f51o8tV+JKBTBfuDZTGAwk6j0wzr9C/Y1f6avMopTtbvhr
         kYvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Eo3EOaLWTp6yCV2t2P1SGEyPOWe0lwLjNo2QwXEfAHY=;
        b=N1Ej8WtTXnxsCyrFiek8FDp1SYuMV9gMDv7x9DHKmp2WKSPmd0qC5A3sz3lm3GVB7J
         m69H1eLhbO+3vQNL/wgjzcEGNr85Bem9ekkYV4qNj7LJS6mvC+l7nPRoRO2TgQFDW+Bz
         MGnhRYo8W9u4/wsnIno/7/19m28hbg52XCpXMPBpQ6NuhaNtKuMP2WgcHN7/rumJkdFg
         +t7t9zOS7eG99F4VV912Ef+O2z4pkzS74emX6edEDq2OveHowpFfaaCYh2MMUC52zii7
         r0AxWXOReW4Cd9op+p8exC2u0o6L6T+xxObfG/BZGprGVChnt+hC05XLZM/moM9A+pZ/
         OWag==
X-Gm-Message-State: AA+aEWaqVpw/fFcd1soEF+1a7sZTD4cPmJhmgInurvDyVolxDnq6TBVw
        oLt5KFvMvLhbNuuYOWKFR3+VUC0sCf18Z1kxMPs=
X-Google-Smtp-Source: AFSGD/Wmabs357plQWSSIVokp88RuRjKeIrq3P7o+oFsfg7IeaXI2BPmNWn7DYTEy7v9CO5AB/0vQZMOp86hES1PtPo=
X-Received: by 2002:a81:c144:: with SMTP id e4mr16015753ywl.409.1543842351778;
 Mon, 03 Dec 2018 05:05:51 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083952.GC6311@dastard>
In-Reply-To: <20181203083952.GC6311@dastard>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 15:05:40 +0200
Message-ID: <CAOQ4uxhDXF_XZNzaBBkoc0a76xMsipRWJ96inq+GSkvk0PQwzA@mail.gmail.com>
Subject: Re: [PATCH 12/11] man-pages: copy_file_range updates
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 10:40 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> Update with all the missing errors the syscall can return, the
> behaviour the syscall should have w.r.t. to copies within single
> files, etc.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  man2/copy_file_range.2 | 94 +++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 77 insertions(+), 17 deletions(-)
>
> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> index 20374abb21f0..23b00c2f3fea 100644
> --- a/man2/copy_file_range.2
> +++ b/man2/copy_file_range.2
> @@ -42,9 +42,9 @@ without the additional cost of transferring data from the kernel to user space
>  and then back into the kernel.
>  It copies up to
>  .I len
> -bytes of data from file descriptor
> +bytes of data from the source file descriptor
>  .I fd_in
> -to file descriptor
> +to target file descriptor
>  .IR fd_out ,
>  overwriting any data that exists within the requested range of the target file.
>  .PP
> @@ -74,6 +74,11 @@ is not changed, but
>  .I off_in
>  is adjusted appropriately.
>  .PP
> +.I fd_in
> +and
> +.I fd_out
> +can refer to the same file. If they refer to the same file, then the source and
> +target ranges are not allowed to overlap.
>  .PP
>  The
>  .I flags
> @@ -93,34 +98,73 @@ is set to indicate the error.
>  .SH ERRORS
>  .TP
>  .B EBADF
> -One or more file descriptors are not valid; or
> +One or more file descriptors are not valid.
> +.TP
> +.B EBADF
>  .I fd_in
>  is not open for reading; or
>  .I fd_out
> -is not open for writing; or
> -the
> +is not open for writing.
> +.TP
> +.B EBADF
> +The
>  .B O_APPEND
>  flag is set for the open file description referred to by
>  .IR fd_out .
>  .TP
>  .B EFBIG
> -An attempt was made to write a file that exceeds the implementation-defined
> -maximum file size or the process's file size limit,
> -or to write at a position past the maximum allowed offset.
> +An attempt was made to write at a position past the maximum file offset the
> +kernel supports.
> +.TP
> +.B EFBIG
> +An attempt was made to write a range that exceeds the allowed maximum file size.
> +The maximum file size differs between filesystem implemenations and can be
> +different to the maximum allowed file offset.
> +.TP
> +.B EFBIG
> +An attempt was made to write beyond the process's file size resource
> +limit. This may also result in the process receiving a
> +.I SIGXFSZ
> +signal.
>  .TP
>  .B EINVAL
> -Requested range extends beyond the end of the source file; or the
> -.I flags
> -argument is not 0.
> +.I (off_in + len)
> +spans the end of the source file.
>  .TP
> -.B EIO
> -A low-level I/O error occurred while copying.
> +.B EINVAL
> +.I fd_in
> +and
> +.I fd_out
> +refer to the same file and the source and target ranges overlap.
> +.TP
> +.B EINVAL
> +.I fd_in
> +or
> +.I fd_out
> +is not a regular file.
>  .TP
>  .B EISDIR
>  .I fd_in
>  or
>  .I fd_out
>  refers to a directory.
> +.B EINVAL
> +The
> +.I flags
> +argument is not 0.
> +.TP
> +.B EINVAL
> +.I off_in
> +or
> +.I (off_in + len)
> +is beyond the maximum valid file offset.
> +.TP
> +.B EOVERFLOW
> +The requested source or destination range is too large to represent in the
> +specified data types.
> +.TP
> +.B EIO
> +A low-level I/O error occurred while copying.
>  .TP
>  .B ENOMEM
>  Out of memory.
> @@ -128,16 +172,32 @@ Out of memory.
>  .B ENOSPC
>  There is not enough space on the target filesystem to complete the copy.
>  .TP
> -.B EXDEV
> -The files referred to by
> -.IR file_in " and " file_out
> -are not on the same mounted filesystem.
> +.B TXTBSY
> +.I fd_in
> +or
> +.I fd_out
> +refers to an active swap file.
> +.TP
> +.B EPERM
> +.I fd_out
> +refers to an immutable file.
> +.TP
> +.B EACCES
> +The user does not have write permissions for the destination file.
>  .SH VERSIONS
>  The
>  .BR copy_file_range ()
>  system call first appeared in Linux 4.5, but glibc 2.27 provides a user-space
>  emulation when it is not available.
>  .\" https://sourceware.org/git/?p=glibc.git;a=commit;f=posix/unistd.h;h=bad7a0c81f501fbbcc79af9eaa4b8254441c4a1f
> +.PP
> +A major rework of the kernel implementation occurred in 4.21. Areas of the API
> +that weren't clearly defined were clarified and the API bounds are much more
> +strictly checked than on earlier kernels. Applications should target the
> +behaviour and requirements of 4.21 kernels.
> +.PP
> +First support for cross-filesystem copies was introduced in Linux 4.21. Older
> +kernels will return -EXDEV when cross-filesystem copies are attempted.

IMO, you should leave the entry for expected error EXDEV in place and prefix
it with "Prior to Linux 4.21..."

Thanks,
Amir.
