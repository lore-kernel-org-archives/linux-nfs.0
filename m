Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98D96C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:31:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 560BF20657
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OL8Yfe09"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 560BF20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726616AbeJ2XUM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 19:20:12 -0400
Received: from mail-vk1-f196.google.com ([209.85.221.196]:46312 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725977AbeJ2XUM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 19:20:12 -0400
Received: by mail-vk1-f196.google.com with SMTP id 185so2082779vkv.13;
        Mon, 29 Oct 2018 07:31:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9JCQg5YRpEuULzqzTOD1AYxH6UveapaJO0B++3CIWlM=;
        b=OL8Yfe09Pa1S2kHeo8Jygf7uxikiQv2YUG+EuVFs2/O+7qP4tVnEsmYETR1XwH3jnR
         GlcCBBIleFvFNAQNKbE0djnvUAzyleSXJQsh4NOctox9CmwcFw0nInkr92Z/o92br7yg
         Pz/asgBkcUH4VPQon3pS//gw+hyHyyA1VEWBk+4EbP5nPkkiB8gpQN1o4RrcAgadlYw+
         COTb8FcbulG5fQ1MKFFaoZgyS14W+psU6dx0Hf6yOBhek19zbknZtjcuH7F7cR8HB0UF
         t03vumBk7nedisU4QbgTqk4CLlt9gXfzfwl14jowdzTkO0SWhHYRqDw18mADbujA5vVG
         ekkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9JCQg5YRpEuULzqzTOD1AYxH6UveapaJO0B++3CIWlM=;
        b=iV1TSi/1H/noctXTEHEXSK9UIHDsU887D9pqKLSWVAF2g5SszJAajjzMErdFoCotGf
         ADXafgOosm8Tnf8g7jsJALZYW7z6lFK1Xo4A8fUhruAPsLHSeXf5Z/r8KMg4aM5EGtPW
         0NXnL40kKpmqTveKs8M4M0Mt5jQHLWgyaRZjAMuhPzdJh6x4km8xk2V1SsA44ZspKPVX
         TH04xbJXyLUb1ySa3OJGRtjG9ZruJJY2fms+HQyB81ll10TjuckE3/U+WFoULzphMkVU
         DdnZIaVCMEqaM7JjUdiI6PtOCMJnI/ctDDbmkeBepLgCxC7hyr1sIOOp09ZwhTnnMots
         XU0Q==
X-Gm-Message-State: AGRZ1gIz59ARZBQP7L99QuD0Ha6ed+W13E7i+OSDBujXXSomO22YJJ9G
        txXKOIlcIldUeRsD5onO7VWkXbdRAZ7AzDCiwYo=
X-Google-Smtp-Source: AJdET5eajLnfyZ6MmREywcoOdeU+s10RkvFkbW1q1V0mAZSNQ9+eLph1cDnM4enKqP55agxB7smm4Wz05YdQCmsqfqU=
X-Received: by 2002:a1f:1d4b:: with SMTP id d72-v6mr6092675vkd.34.1540823477133;
 Mon, 29 Oct 2018 07:31:17 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-2-olga.kornievskaia@gmail.com> <20181027090923.GJ6311@dastard>
In-Reply-To: <20181027090923.GJ6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 10:31:05 -0400
Message-ID: <CAN-5tyGQM3EkaGwAuLxxh82=aZ99bD=M5Z_SzF5xaLPurP_vdw@mail.gmail.com>
Subject: Re: [PATCH v4 01/11] VFS: move cross device copy_file_range() check
 into filesystems
To:     david@fromorbit.com
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 27, 2018 at 5:09 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Fri, Oct 26, 2018 at 04:10:46PM -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > This patch makes it the responsibility of individual filesystems to
> > allow or deny cross device copies.  Both NFS and CIFS have operations
> > for cross-server copies, and later patches will implement this feature.
> >
> > Note that as of this patch, the copy_file_range() function might be passed
> > superblocks from different filesystem types. -EXDEV should be returned
> > if cross device copies aren't supported, causing the VFS to fall back
> > on using do_splice_direct().
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  Documentation/filesystems/porting | 7 +++++++
> >  fs/cifs/cifsfs.c                  | 3 +++
> >  fs/nfs/nfs4file.c                 | 3 +++
> >  fs/overlayfs/file.c               | 3 +++
> >  fs/read_write.c                   | 9 +++------
> >  5 files changed, 19 insertions(+), 6 deletions(-)
> >
> > diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
> > index 7b7b845..897e1e7 100644
> > --- a/Documentation/filesystems/porting
> > +++ b/Documentation/filesystems/porting
> > @@ -622,3 +622,10 @@ in your dentry operations instead.
> >       alloc_file_clone(file, flags, ops) does not affect any caller's references.
> >       On success you get a new struct file sharing the mount/dentry with the
> >       original, on failure - ERR_PTR().
> > +--
> > +[mandatory]
> > +     ->copy_file_range() may now be passed files which belong to two
> > +     different superblocks of the same file system type or which belong
> > +     to two different filesystems types all together. As before, the
> > +     destination's copy_file_range() is the function which is called.
> > +     If it cannot copy ranges from the source, it should return -EXDEV.
> > diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> > index 7065426..f2d7f4f 100644
> > --- a/fs/cifs/cifsfs.c
> > +++ b/fs/cifs/cifsfs.c
> > @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
> >       unsigned int xid = get_xid();
> >       ssize_t rc;
> >
> > +     if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
>
> file_inode(file)->i_sb, please.
>
> > +             return -EXDEV;
> > +
> >       rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
> >                                       len, flags);
> >       free_xid(xid);
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 4288a6e..09df688 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> >  {
> >       ssize_t ret;
> >
> > +     if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > +             return -EXDEV;
> > +
> >       if (file_inode(file_in) == file_inode(file_out))
> >               return -EINVAL;
>
> Please look at the code around your modifications and make sure your
> additions are consistent with it.

Will make the changes. Thanks.

>
> > @@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >        * Try cloning first, this is supported by more file systems, and
> >        * more efficient if both clone and copy are supported (e.g. NFS).
> >        */
> > -     if (file_in->f_op->clone_file_range) {
> > +     if (inode_in->i_sb == inode_out->i_sb &&
> > +                     file_in->f_op->clone_file_range) {
>
>         if (inode_in->i_sb == inode_out->i_sb &&
>             file_in->f_op->clone_file_range) {
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
