Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF16C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:16:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DDDD20693
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MJuKhN2X"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726538AbfDKRQW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 13:16:22 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:37367 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726391AbfDKRQV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 13:16:21 -0400
Received: by mail-vs1-f66.google.com with SMTP id w13so3942599vsc.4
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 10:16:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pz4PoSZoXxIgJlu7F3bSK+yLiebk7cTkraLz2VLFzD8=;
        b=MJuKhN2XfRs3dwTM/T4NjCYtHCNpOpJHEuqGzGNhsAsZ0xzCIyK/6XJAJpdWNnh6Lx
         YwmuXXtod9Z0zwO2wAcNHKvrHAYAkquRZSYY1R5DruFFpyWeMKxpLHbZQz8DAE3VUHM9
         kxInvAso0r1cq3sCM0cJaeItpNz5ojXbeKkOOEBc9IAYb2wQ1rZKrg01OotZ3VxkWDLs
         IGA5qPgQAwlP3Ck2h3QGEsBZRRYGJDWGTrW41ANAXrLDCOmX5/wcX45xxCXdoZMvKz0y
         TVbKabYKmLaEsTqnSUtfn9ZX1uOTYR5pkKYQP/8IpXOHeviny8qLAM3r4eFgf3kqTJTP
         A7Jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pz4PoSZoXxIgJlu7F3bSK+yLiebk7cTkraLz2VLFzD8=;
        b=HnULdsJBlD9a+jhonNV4kM7I5KSp7NgfYvgOCqFjmsw/H+IqWh+NQuFWrkGvoGBSaO
         I/aK4YWUY0s0v07m9sIx9JAzXw2VWlb5GxuTkQeQDJkpCUljJ5z0ZAwOgRxx+JDSLJFU
         xUsHKa12FAPy+Gx2m3sEQI8zN8sScVeLQ9vhMbxvFVcKLVpUg8E101NC+nHsWDEZHR3j
         FjdIncWDWBghvSsk5if4Bsuz/5Om6d+utm2gCQxTtk+A6U3seQM+uwVgNr6misHmfxkk
         BfMPxL8no4Vqu1Wp2ERa8H6CnCcDLz4y5aCCi0mCyOSqIGq8+r9nlbTCSwZsLzCTidkA
         8bWw==
X-Gm-Message-State: APjAAAVjQ1WhjS6Bq2EtStQtZb87go0onjjRjKlJD/gudZYKdgNsl9vC
        vyqyWRq92uHZkRzWnn/DJwSKGKui1r6zbHck0Co=
X-Google-Smtp-Source: APXvYqzLMkKlG+FIH9HTYLNpLJ2u2btTuYL/2OBFTIw6dtQYy2QbhffF0qS8Qx3uPnflXeOWG29sMN8nZsUJCU/r9Bk=
X-Received: by 2002:a67:db09:: with SMTP id z9mr29130151vsj.127.1555002980628;
 Thu, 11 Apr 2019 10:16:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
 <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
 <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com> <d7146ead1f35af97a8f107326904f13d4031b8fc.camel@hammerspace.com>
In-Reply-To: <d7146ead1f35af97a8f107326904f13d4031b8fc.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 11 Apr 2019 13:16:08 -0400
Message-ID: <CAN-5tyE_QvwirK70sf8=_M+rcn1MVFi33s8gn1RODzB4sJx_Og@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 11, 2019 at 1:06 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Thu, 2019-04-11 at 12:52 -0400, Olga Kornievskaia wrote:
> > On Thu, Apr 11, 2019 at 12:46 PM Trond Myklebust
> > <trondmy@hammerspace.com> wrote:
> > > On Thu, 2019-04-11 at 12:27 -0400, Olga Kornievskaia wrote:
> > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > >
> > > > When VFS calls copy_file_range on a 4.0 mount (and when in and
> > > > out
> > > > file is the same), we need to return ENOTSUPP instead of EINVAL.
> > > > Since no COPY operation is defined in 4.0, then like 3.0, it
> > > > should
> > > > fallback to doing do_splice_direct().
> > > >
> > > > Otherwise xfstest generic/075,091,112,263 fail.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > > >  fs/nfs/nfs4file.c | 6 ++++++
> > > >  1 file changed, 6 insertions(+)
> > > >
> > > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > > index 45b2322..9a222b0 100644
> > > > --- a/fs/nfs/nfs4file.c
> > > > +++ b/fs/nfs/nfs4file.c
> > > > @@ -133,6 +133,12 @@ static ssize_t nfs4_copy_file_range(struct
> > > > file
> > > > *file_in, loff_t pos_in,
> > > >                                   struct file *file_out, loff_t
> > > > pos_out,
> > > >                                   size_t count, unsigned int
> > > > flags)
> > > >  {
> > > > +     struct nfs_server *server = NFS_SERVER(file_inode(file_in);
> > > > +     struct nfs_client *client = server->nfs_client;
> > > > +
> > > > +     if (client->cl_minorversion < 1)
> > > > +             return -EOPNOTSUPP;
> > > > +
> > > >       if (file_inode(file_in) == file_inode(file_out))
> > > >               return -EINVAL;
> > > >       return nfs42_proc_copy(file_in, pos_in, file_out, pos_out,
> > > > count);
> > >
> > > Let's please just move the test for NFS_CAP_COPY from
> > > nfs42_proc_copy()
> > > into the above function.
> >
> > But the return order of errors here for different conditions matter.
> > For 4.1+ mounts, if in == out, we'd expect EINVAL even if server
> > isn't
> > capable. But we can't just put the in == out first because for 4.0,
> > we
> > need to always return EOPNOTSUPP.
> >
> > > BTW: Why do we return -EINVAL in the file_in == file_out case? Is
> > > there
> > > any reason why we shouldn't just return EOPNOTSUPP there too in
> > > order
> > > to let splice() fulfil the operation?
> >
> > Yes: in == out -> EINVAL is a spec requirement.
> >
>
> Returning NFS4ERR_INVAL when the files are identical is a requirement
> for the NFSv4.2 server.
>
> On the other hand, the requirement for the Linux file copy operation is
> that it should succeed in this situation. So as far as I can tell, we
> will continue to fail xfstests until we work around the discrepancy
> with the protocol requirement here. The simplest way to do so would
> appear to be to return EOPNOTSUPP.

Ok so you are arguing that those xfstest's for copy_file_range() on
the same file shouldn't fail for any of the NFS version regardless of
the NFSv4.2 req for not doing a copy on the same file. Let me send out
another version that addresses both then. I will change the "in ==
out" to return EOPNOTSUPP which will allow the fallback for 4.2+ and
check for the server capability before that.

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
