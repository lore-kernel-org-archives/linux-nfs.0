Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7122EC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:01:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 23A032080A
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:01:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="knQHaCD4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A032080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729279AbeKADBC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 23:01:02 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:43895 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729206AbeKADBC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 23:01:02 -0400
Received: by mail-vs1-f65.google.com with SMTP id k14so10594340vsm.10
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 11:01:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=di4CmRv+RoBpzpk3ifDHR91hMvC7dAXvDM0qWB2Zu3o=;
        b=knQHaCD4KWvliNJLhLktFG6sQBnL471jCSr5eNqPSoF6P0CMf/bC82S2JbGq1XkciC
         UmLmltjCBxG4jE2rCwe6F44FNZyIZcU1d4HIXv+6MUuR8S/x9S9GarE3NhaIeIzlPqbB
         VPB8fw8V9dsYYmOXYi/cT+wkvHXRlmoXI9r8g86QRIVwbnswt9qsQfooC78oHhKIV6JF
         c7g8MV2gfs2xCQTIe7NifBVU5mLUnT6vxlexY1rUbfSr5peMDKTq8ywchSy2E8aPEuFN
         GRnys5xB5z9Thqvfrp4nrINa4NJCdfp+GeXoiRnO149wJ3EWrwlrjDHmOLPW3/202k19
         Nj3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=di4CmRv+RoBpzpk3ifDHR91hMvC7dAXvDM0qWB2Zu3o=;
        b=l/S276gtMTOPUQbAiWs57bQtyRbt4/6SE+gH93/fJtv7qE9tcYwy6H9urp1kAOU1MI
         lByUCXYBWjP47AQ5kr1z2wjOj9Qr60FYXfL4QXoXSSoq1i04nRc/M8S96HjwHEr9CWDn
         VyoFHLKma0cbOFUsHF9Xx/DULOWn1H3i0N37HBF36Sg+2A6hBWoljTWXpVrFexI57O8X
         9d6vULQ8Rwp/dpEbGh+ayvKqB32WpK8ioMMrCtyWh7zqA13kgWGBWTjEnrgNmhxlFRf4
         kJTr35EH3IMsTz6hFQ82Cw8lEMghAk5wJfnfVXD5PpqvsS6h53U4VPaWHTVPMl3rYkW2
         kSUw==
X-Gm-Message-State: AGRZ1gK//OeS0RucTBKeNV1WrC0fzFuM3jVrJmoHQPgKy+cXE0Pegisc
        4frb7hq1FGQJwdHmp7Wq5KT1FGa2d3pSAkzvZrIgjg==
X-Google-Smtp-Source: AJdET5cX3gYfQL69sXf2c/l6hK0mER4QF5IhRImD1iTEv8swoY4pbOPcb/sWstV/0zhv3SH6VN/5SDPvD3I281oCxsI=
X-Received: by 2002:a67:60c7:: with SMTP id u190mr1714644vsb.85.1541008916764;
 Wed, 31 Oct 2018 11:01:56 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-2-olga.kornievskaia@gmail.com> <20181031165430.GA3377@fieldses.org>
 <CAN-5tyHTZV9LYnfD9Ag_pSdWA2Zs69JNvVBjHPQTMnDm2kRuEQ@mail.gmail.com> <20181031175409.GB3377@fieldses.org>
In-Reply-To: <20181031175409.GB3377@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 31 Oct 2018 14:01:45 -0400
Message-ID: <CAN-5tyGo8BeWtGPZTd=A19+ZG3yFcGu_uu=s1MRiF6F-c+0bFw@mail.gmail.com>
Subject: Re: [PATCH v1 01/13] fs: Don't copy beyond the end of the file
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 1:54 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Wed, Oct 31, 2018 at 01:07:11PM -0400, Olga Kornievskaia wrote:
> > On Wed, Oct 31, 2018 at 12:54 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Fri, Oct 19, 2018 at 11:28:53AM -0400, Olga Kornievskaia wrote:
> > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > >
> > > I have some idea we've had some discussion about this before, but if so
> > > I've forgotten the conclusion.  Could we have more of a changelog?:
> > >
> > >         - isn't there a race condition, or is there something preventing
> > >           the file size from changing here?
> >
> > No there is nothing preventing the size from changing. Just like there
> > is nothing that prevents the file from changing if you are doing a
> > traditional copy either.
> >
> > >         - why are we doing this?  Does this change the behavior of
> > >           copy_file_range()?
> >
> > We are doing this because 1. NFS spec and 2. copy_file_range semantics
> > mandate that too. There is a whole different discussion under the
> > client-side patch for this where the plan now is that VFS themselves
> > are interested in making sure they are indeed enforcing the check
> > stated by the documentation of copy_file_range call which states
> > "copying a range beyond the end of the file" is EINVAL. I recall you
> > argued for a "short" read instead of a EINVAL but unless VFS community
> > is convinced to change it it'll be enforced (soon).
>
> OK.  Let's just make sure the reasoning's mentioned in the changelog,
> whatever we do.

By the changelog, you mean the commit message?

>
> --b.
>
> > > --b.
> > >
> > > >
> > > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > ---
> > > >  fs/read_write.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > index 39b4a21..c60790f 100644
> > > > --- a/fs/read_write.c
> > > > +++ b/fs/read_write.c
> > > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > > >       if (unlikely(ret))
> > > >               return ret;
> > > >
> > > > +     if (pos_in >= i_size_read(inode_in))
> > > > +             return -EINVAL;
> > > > +
> > > >       if (!(file_in->f_mode & FMODE_READ) ||
> > > >           !(file_out->f_mode & FMODE_WRITE) ||
> > > >           (file_out->f_flags & O_APPEND))
> > > > --
> > > > 1.8.3.1
