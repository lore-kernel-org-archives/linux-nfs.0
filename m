Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ED6FC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:34:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B633A20831
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:34:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vUcU2Kft"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B633A20831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726527AbeJYNFl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 09:05:41 -0400
Received: from mail-yw1-f65.google.com ([209.85.161.65]:37202 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726308AbeJYNFl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 09:05:41 -0400
Received: by mail-yw1-f65.google.com with SMTP id v77-v6so3056781ywc.4;
        Wed, 24 Oct 2018 21:34:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yy02/UOO2b/ai8yPT60D0XprJT5yKJRsDa53CQ+ZfqA=;
        b=vUcU2KftOOMlK8weSNBVrGX9W4MwTJAAQ0GAYQvJEZ0lyBU8d4gMaH5hXey9KwqP3u
         fKRgjufWfuFuT5RatOO1eJAuQqsE8uDW9VHkBra03zlSz1g9zluJ1GsYumqi0TlXaCBg
         32ui8YSu7FAM8FTXfOFBva78xKwBnOnanHwfP83vdYZGKU/3Viicy9vDIFqcuWgi/Cmr
         JFlykqac7snL+j6F06dIdRN24+Xg0uThRMX4H4ruxdKwGpkspCqxibYr0uMjC2nWY2of
         BTaoF8SiRjv7fQck5ZHlkMHvLbB5mP+meAIyV2uTHWAKeCV3bTtYJKGG/Y0HRaAV+ErO
         mMdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yy02/UOO2b/ai8yPT60D0XprJT5yKJRsDa53CQ+ZfqA=;
        b=tywzXkIxpkTPIRpCbhtBUSGK1KGdUIIHaJDB5YpjjOLxQriSUFBsnNDCQshsxW6dLt
         AgpB+xwgb3KQVH9NutvVoXNeg2Kk5ray/R9iMFUtxuff5Azt2WNI3tO2qufwuXQ1emAS
         OgSi2iTZjljtxCY7dLUMzg9b3IMAiis6gxE1BbLClHEniWeZoDJs254eA0VHWBNc3AHh
         xqaERimpSWl85soSw9xnemsKxtP/YMqX+WQt2liz0Kh4OVdSjHNVdNa/83JQJhqvymiE
         C120gr3hOXg0JmbVLJTYuHmUhLBX4z12W1MqIa8SkBtPDqwIa/QDEO5SyaCaPIaSqZEL
         x7mQ==
X-Gm-Message-State: AGRZ1gLgtgnzcIMyqGsSYx2dRkXJ2s9sX4/RXfHN++wvnv9XVdZiLUNi
        Mh0NE92cJpBkIIeRcpqluVqGsS7Fr4KzIJIjxKw=
X-Google-Smtp-Source: AJdET5fcshj5FokeZ6BQnqNz1hYerf9CxxcH8XUr8FRn7XcHhSaO0n44CqfPPoi3NaPJiA2WD/xuyvc9gPlx9RchNoQ=
X-Received: by 2002:a81:6505:: with SMTP id z5-v6mr27550ywb.34.1540442082156;
 Wed, 24 Oct 2018 21:34:42 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com> <20181024195837.35532-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181024195837.35532-2-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 07:34:31 +0300
Message-ID: <CAOQ4uxgx1YZfn2GsTQhGzxgZ4AMxMocCOrKOEo8StVVfr=2cyQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] VFS permit cross device vfs_copy_file_range
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

On Wed, Oct 24, 2018 at 10:58 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> From: Olga Kornievskaia <kolga@netapp.com>
>
> This patch removes the check for source and destination files to
> come from the same superblock. This feature was of interest to
> NFS as well as CIFS communities.
>
> Specifically, this feature is needed to allow for NFSv4.2 copy offload
> to be done between different NFSv4.2 servers. SMBv3 copy offload between
> different servers would be able to use this as well.
>
> Removal of the check implies that passed in source and destination
> files can come from different superblocks of the same file system
> type or different. It is upto each individual copy_file_range()
> file system implementation to decide what type of copy it is
> capable of doing and return -EXDEV in cases support is lacking.
>
> There are 3 known implementator of copy_file_range() f_op: NFS,
> CIFS, OverlayFS. NFS and CIFS are interested to support cross-device
> copy offload but do not support cross file system types copy offload.
> Following patches will add appropriate checks in each of the drivers.
>

That should be the other way around - first add limitation inside filesystems
then relax vfs check. otherwise you leave a bug in the middle of bisect.

> If the copy_file_range() errors with EXDEV, the code would fallback
> on doing do_splice_direct() copying which in itself is beneficial.
>
> Adding wording to the vfs.txt and porting documentation about the
> new support for cross-device copy offload.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting | 7 +++++++
>  Documentation/filesystems/vfs.txt | 6 +++++-
>  fs/read_write.c                   | 9 +++------
>  3 files changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
> index 7b7b845..ebb4954 100644
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
> +        destination's copy_file_range() is the function which is called.
> +       If it cannot copy ranges from the source, it should return -EXDEV.
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index a6c6a8a..34c0e8c 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -1,5 +1,6 @@
>
>               Overview of the Linux Virtual File System
> +- [fs] nfs: Don't let readdirplus revalidate an inode that was marked as stale (Benjamin Coddington) [1429514 1416532]
>

???

Thanks,
Amir.
