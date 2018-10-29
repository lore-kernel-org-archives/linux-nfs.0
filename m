Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62162C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:34:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2305220870
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:34:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SLhZFHSW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2305220870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729602AbeJ3DXz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:23:55 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:38311 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729567AbeJ3DXz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:23:55 -0400
Received: by mail-ua1-f65.google.com with SMTP id g10so3429118uak.5;
        Mon, 29 Oct 2018 11:34:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vtpu6BN48kFzb6VfZsrIOlM6z3xRmdh9v69S8kCjd9s=;
        b=SLhZFHSWqpyTR5+qaAQe5xKHfPnnaUELQ2CNIItUgpSPmGG33aN8otZXAMGtrssbMw
         HQuQnPY/IGEliiYKZyqYeSKTvRpqS/3EZplJDnnhdPBqI787scXQCxc8c1qS8cTgCKnP
         M8fbIWBEN+ZfyTsGJDNugV3+5PTIHTI7iUNPH26ReS39lGKy+z+X2k0YY1xnqo8ZAhZt
         HnN6Sw7xnZhUAWTH8H1hc3y4Ot/9odLZbseFAHNKYxE2ifA2YV+bm/ixTIyYy6XVpYkb
         UCbeVEjOWoWZSxBLbROLW7I1TkS3nK1ap+4oQ5Io/oaxgHd6uUpLIzG/+8GqaI6/1S5H
         /m1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=vtpu6BN48kFzb6VfZsrIOlM6z3xRmdh9v69S8kCjd9s=;
        b=uIBsy6TFr+XaQJikPhh5dJXflg2pYWBVbLiIcxmx0RhJvUTR5yUB/qvl+xCp1ctxgq
         3dbn41Xos5hOUycbzlRjnoe5TeJdsw+9FzChu/CcfxQoMM/art8SBb+NTTQRHEu8jqLS
         kL9r1/Kwi3MDr5hUNZZVQ/C6Fw905XfD4N6vWu9ZdGMy/3Z+YCLTLg/55PoGgpmKY6GC
         hRszC77wCT8IXPAiwUJmcL1uvkB7lJnDWsD9gUaVeMV6c/rdsYVuyVNEB5S0fO1g/Y3u
         oXtr3uWWztB34ajiM/STxxUTMtV5oIGVTAan+1v9gv8CPLTnbEar4FueSxwg0DfFlYKh
         xFJQ==
X-Gm-Message-State: AGRZ1gJayLZ9LyBhQKJjHdJ5taZYlyuBsoR/HxbuNHMd97+cTRfRJssq
        WAd3mCk993wKauKYlkdKKCo1Q14T3nLO+sXlKuo=
X-Google-Smtp-Source: AJdET5e81E8H+OvdIUfqBOzZ/pTm5sEv4kCBOAssQMSwDeHfJwLIg8apJ/CzZz8pfknyIGDeB3sPt9CdN1m6nZ86IYY=
X-Received: by 2002:a9f:3250:: with SMTP id y16mr6545837uad.120.1540838042760;
 Mon, 29 Oct 2018 11:34:02 -0700 (PDT)
MIME-Version: 1.0
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
 <20181029174059.38326-3-olga.kornievskaia@gmail.com> <CAOQ4uxiUCPb7vDU9c34UL5RkzBemiq49YqOoXfHL4T=+rrL8vg@mail.gmail.com>
In-Reply-To: <CAOQ4uxiUCPb7vDU9c34UL5RkzBemiq49YqOoXfHL4T=+rrL8vg@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 14:33:51 -0400
Message-ID: <CAN-5tyHHLkUs2iotiZifhvbrEW2gyObadpubOJdX-uSQ7GOGog@mail.gmail.com>
Subject: Re: [PATCH v5 01/12] VFS: move cross device copy_file_range() check
 into filesystems
To:     Amir Goldstein <amir73il@gmail.com>
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

On Mon, Oct 29, 2018 at 2:03 PM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Mon, Oct 29, 2018 at 7:41 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > This patch makes it the responsibility of individual filesystems to
> > allow or deny cross device copies.  Both NFS and CIFS have operations
> > for cross-server copies, and later patches will implement this feature.
> >
> > Note that as of this patch, the copy_file_range() function might be passed
> > superblocks from different filesystem types. -EXDEV should be returned
> > if cross device copies aren't supported.
>
> This Note is not ok.
> As Dave commented, you shoud make this change in a separate path.
> I will explain...
>
> >
> > Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > Reviewed-by: Steve French <stfrench@microsoft.com>
> > Reviewed-by: Jeff Layton <jlayton@kernel.org>
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  Documentation/filesystems/porting | 7 +++++++
> >  fs/cifs/cifsfs.c                  | 3 +++
> >  fs/nfs/nfs4file.c                 | 3 +++
> >  fs/overlayfs/file.c               | 3 +++
> >  fs/read_write.c                   | 7 ++-----
> >  5 files changed, 18 insertions(+), 5 deletions(-)
> >
> > diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
> > index 7b7b845..897e1e7 100644
> > --- a/Documentation/filesystems/porting
> > +++ b/Documentation/filesystems/porting
> > @@ -622,3 +622,10 @@ in your dentry operations instead.
> >         alloc_file_clone(file, flags, ops) does not affect any caller's references.
> >         On success you get a new struct file sharing the mount/dentry with the
> >         original, on failure - ERR_PTR().
> > +--
> > +[mandatory]
> > +       ->copy_file_range() may now be passed files which belong to two
> > +       different superblocks of the same file system type or which belong
> > +       to two different filesystems types all together. As before, the
> > +       destination's copy_file_range() is the function which is called.
> > +       If it cannot copy ranges from the source, it should return -EXDEV.
> > diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> > index 7065426..ca8fc87 100644
> > --- a/fs/cifs/cifsfs.c
> > +++ b/fs/cifs/cifsfs.c
> > @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
> >         unsigned int xid = get_xid();
> >         ssize_t rc;
> >
> > +       if (file_inode(src_file)->i_sb != file_inode(dst_file)->i_sb)
> > +               return -EXDEV;
> > +
> >         rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
> >                                         len, flags);
> >         free_xid(xid);
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 4288a6e..5a73c90 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> >  {
> >         ssize_t ret;
> >
> > +       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> > +               return -EXDEV;
> > +
> >         if (file_inode(file_in) == file_inode(file_out))
> >                 return -EINVAL;
> >  retry:
> > diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> > index aeaefd2..0331e33 100644
> > --- a/fs/overlayfs/file.c
> > +++ b/fs/overlayfs/file.c
> > @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
> >                                    struct file *file_out, loff_t pos_out,
> >                                    size_t len, unsigned int flags)
> >  {
> > +       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> > +               return -EXDEV;
> > +
> >         return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> >                             OVL_COPY);
> >  }
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 39b4a21..7a912e3 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1575,10 +1575,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >             (file_out->f_flags & O_APPEND))
> >                 return -EBADF;
> >
> > -       /* this could be relaxed once a method supports cross-fs copies */
> > -       if (inode_in->i_sb != inode_out->i_sb)
> > -               return -EXDEV;
> > -
>
> IMO, series will look the least awkward, if you start with "moving"
> this check to before
>  file_in->f_op->clone_file_range() AND before file_in->f_op->copy_file_range().
> The title of the patch would be something like:
> "VFS: generic cross-device copy_file_range() support for all filesystems"
> (Dave's suggested commit message)
>
> Then, in the next patch, which is this patch you posted
> "VFS: move cross device copy_file_range() check into filesystems"
>
> You will only need to remove the same fs check from before
> file_in->f_op->copy_file_range() and add it inside filesystems.
>
> I hope that is clear.
>

You want to make the side-effect into the first class citizen. Ok.
