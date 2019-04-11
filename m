Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D15C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:52:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8CCA2133D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sgF8+j5N"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726676AbfDKQwk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 12:52:40 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:44625 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726646AbfDKQwk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 12:52:40 -0400
Received: by mail-vs1-f65.google.com with SMTP id j184so3876509vsd.11
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 09:52:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pyHOh83wo1cBcBW2HQGgqN8IVapr0vvg3eoW52U4L0c=;
        b=sgF8+j5NC2S4+pISCuLPfLuoFzMJ83VCPdfJKiLHmqeRqocavLRvhVhxlZvNIMdKdI
         CJxa0yl3AVUZia4IdnzP58GmnrdNwpYyM0K5HnxY2KMC+P68BR4zyB57cbTZyajdXqUB
         zuSUKjcuobAL85j5cAHuKFNlj3iVq1rxEI8UHNkuQWNMTxmGkUru8YN/hnSvxlHW4eIo
         KbRKaBmYF4t1Lhn1DJNZ5PirRrRhZJKFtKvKpp34d18uIX84xg41dmoZI1rkG6UDMglh
         Zl7DQgn4B2D/Pkl/CChHZRWJz/GnNldL6HnGh1/MfeUTrOIHciJAL6wmmy63awfTV26L
         71WA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pyHOh83wo1cBcBW2HQGgqN8IVapr0vvg3eoW52U4L0c=;
        b=mpCWpcnfwwJFBKTQzWw0EluV0ex5jYu+TFTqNfdIAE0ofc25gDZz/KKcMlk5OfCmhP
         AG+W/antdtZ6vG4l71SK98CxzMkhXrm8GRnJbr4ewQRNAfqkS+PminM+6AdtEAfBAkEQ
         v7hyLrraEKgxooM+vLUAG5TyhryLAHy1oh2u36c4kzMQFzAmoFSHNN81GOI5r0iAtDbO
         QpSSjx58RV1+z2uUcnz7aQ898woSJWyd0BUP8FoEttA7hyRBoD2fqYiHAFctwkUHofcu
         MNOSv7mUroOhfc7LZzm935CsIa2fwYpNrJ1J8gvEJ9986ZN4OnRYFvBjSIe5iBosjhqb
         0sjQ==
X-Gm-Message-State: APjAAAUyjp0bC+d3seFcLYUEGsSN7BIq64+peuxT8HzwRr6kgAoJjYwj
        GZP94lp50d3QlE/wfHSlWwhIF1wg6sZ/t4Q/Om3Ivg==
X-Google-Smtp-Source: APXvYqw/iYgXH38+jk721/WqWo38PnWRJ/3DhgOqIZO8ShxR9WttWMCnu2zUoABiLmDzSfq1+MCsiioiED9mCxMvMXk=
X-Received: by 2002:a67:7f44:: with SMTP id a65mr8738363vsd.179.1555001558965;
 Thu, 11 Apr 2019 09:52:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com> <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
In-Reply-To: <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 11 Apr 2019 12:52:27 -0400
Message-ID: <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 11, 2019 at 12:46 PM Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Thu, 2019-04-11 at 12:27 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > When VFS calls copy_file_range on a 4.0 mount (and when in and out
> > file is the same), we need to return ENOTSUPP instead of EINVAL.
> > Since no COPY operation is defined in 4.0, then like 3.0, it should
> > fallback to doing do_splice_direct().
> >
> > Otherwise xfstest generic/075,091,112,263 fail.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs4file.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> >
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 45b2322..9a222b0 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -133,6 +133,12 @@ static ssize_t nfs4_copy_file_range(struct file
> > *file_in, loff_t pos_in,
> >                                   struct file *file_out, loff_t
> > pos_out,
> >                                   size_t count, unsigned int flags)
> >  {
> > +     struct nfs_server *server = NFS_SERVER(file_inode(file_in);
> > +     struct nfs_client *client = server->nfs_client;
> > +
> > +     if (client->cl_minorversion < 1)
> > +             return -EOPNOTSUPP;
> > +
> >       if (file_inode(file_in) == file_inode(file_out))
> >               return -EINVAL;
> >       return nfs42_proc_copy(file_in, pos_in, file_out, pos_out,
> > count);
>
> Let's please just move the test for NFS_CAP_COPY from nfs42_proc_copy()
> into the above function.

But the return order of errors here for different conditions matter.
For 4.1+ mounts, if in == out, we'd expect EINVAL even if server isn't
capable. But we can't just put the in == out first because for 4.0, we
need to always return EOPNOTSUPP.

> BTW: Why do we return -EINVAL in the file_in == file_out case? Is there
> any reason why we shouldn't just return EOPNOTSUPP there too in order
> to let splice() fulfil the operation?

Yes: in == out -> EINVAL is a spec requirement.

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
