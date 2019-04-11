Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9DA4C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:53:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B45632133D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:53:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XTteXNnK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbfDKQxv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 12:53:51 -0400
Received: from mail-vk1-f193.google.com ([209.85.221.193]:36619 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726603AbfDKQxv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 12:53:51 -0400
Received: by mail-vk1-f193.google.com with SMTP id w140so1527405vkd.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 09:53:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2CjcvI2FVcDcnBXA+EwMCHhCKlO4eovah90G5YkmvvY=;
        b=XTteXNnKkH3kuhMKOCZsgzPfIoOP2EuQy5rvlVSRqBCvyju+83MlO6K0H1B62aNeLw
         skDa49XnAJxSuIKMowXc87Y83RStS7+dgBSUO7Ok2Bw63aeyQTQzWXmKnsWpJSZO4Kgp
         TC4zYSADD7yzwR6akOtY3hNKwV92h/rw/rjpUWcx+XN+dDuhi0G12u4kN6ts3Oglff2T
         IrZe5zbtj1KKs/0VKDSBmFBBEFmqLwq+RhBiz36C6vBKNinEQXJX5EECKYbxF2iKbDJN
         QyOaiU2bglTXDy0FkcxXr+c9rvYJciI3BX1DvApQgxyQP28Qatqg0T37MleuNG4t3K23
         bNgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2CjcvI2FVcDcnBXA+EwMCHhCKlO4eovah90G5YkmvvY=;
        b=blP7Jd5ZnTGr+6kC4+0btqHWh6ClvajKtrh5v7wblv+CUfi5sKZh4LANuPrO6ClWvO
         vGV5IyxqsBAbHpoSJFUkdZgsKlHpnR7p+DY30wICxcN05ufTOajCDEhzQHE2/y85CzYj
         y7LrSHIxQNyqH6EYHKhabrd0nRE/ppn3edi1Q3QpP7zB2OkJ4ieGdZCEuBv1rq9qnnIM
         unvr/L48KwmyimZRM42BQQLH91p63dxX93YRkVTbzOep/p2PsGvBYkHGjIGSr7l/HKls
         I18DWANOUV81GXJyQYGa3j9dhbljkgcEOqeccwuLD4eLpLgy6GZ459x3RbLDjxM1725S
         2/og==
X-Gm-Message-State: APjAAAWqAJXyDx9j36lHpg27qc0xlzk86ffWh8aUJze4iE2DWy0mJcW6
        UhMVPENsFfAYU8QiMAi52a8buuutAKvsgy+/Gm8=
X-Google-Smtp-Source: APXvYqwa++suj5KAitIjVoHAlT7b5TVU83OYtD6hd+A/FY4FX6qSoQtY+UqTX0KR683yMQoc9Nyr8nlkISxyVPZ0iDU=
X-Received: by 2002:ac5:c383:: with SMTP id s3mr25616479vkk.65.1555001630034;
 Thu, 11 Apr 2019 09:53:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
 <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com> <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
In-Reply-To: <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 11 Apr 2019 12:53:39 -0400
Message-ID: <CAN-5tyGrqQLpwdLPsFofUeSCDHY0Spt80YBu0au5m16mi4yPAA@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 11, 2019 at 12:52 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Thu, Apr 11, 2019 at 12:46 PM Trond Myklebust
> <trondmy@hammerspace.com> wrote:
> >
> > On Thu, 2019-04-11 at 12:27 -0400, Olga Kornievskaia wrote:
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > When VFS calls copy_file_range on a 4.0 mount (and when in and out
> > > file is the same), we need to return ENOTSUPP instead of EINVAL.
> > > Since no COPY operation is defined in 4.0, then like 3.0, it should
> > > fallback to doing do_splice_direct().
> > >
> > > Otherwise xfstest generic/075,091,112,263 fail.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  fs/nfs/nfs4file.c | 6 ++++++
> > >  1 file changed, 6 insertions(+)
> > >
> > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > index 45b2322..9a222b0 100644
> > > --- a/fs/nfs/nfs4file.c
> > > +++ b/fs/nfs/nfs4file.c
> > > @@ -133,6 +133,12 @@ static ssize_t nfs4_copy_file_range(struct file
> > > *file_in, loff_t pos_in,
> > >                                   struct file *file_out, loff_t
> > > pos_out,
> > >                                   size_t count, unsigned int flags)
> > >  {
> > > +     struct nfs_server *server = NFS_SERVER(file_inode(file_in);
> > > +     struct nfs_client *client = server->nfs_client;
> > > +
> > > +     if (client->cl_minorversion < 1)
> > > +             return -EOPNOTSUPP;
> > > +
> > >       if (file_inode(file_in) == file_inode(file_out))
> > >               return -EINVAL;
> > >       return nfs42_proc_copy(file_in, pos_in, file_out, pos_out,
> > > count);
> >
> > Let's please just move the test for NFS_CAP_COPY from nfs42_proc_copy()
> > into the above function.
>
> But the return order of errors here for different conditions matter.
> For 4.1+ mounts, if in == out, we'd expect EINVAL even if server isn't
> capable. But we can't just put the in == out first because for 4.0, we
> need to always return EOPNOTSUPP.

Urgh, I just realized a problem in my own check. It needs to be < 2 as
there is no COPY in 4.1.

> > BTW: Why do we return -EINVAL in the file_in == file_out case? Is there
> > any reason why we shouldn't just return EOPNOTSUPP there too in order
> > to let splice() fulfil the operation?
>
> Yes: in == out -> EINVAL is a spec requirement.
>
> >
> > --
> > Trond Myklebust
> > Linux NFS client maintainer, Hammerspace
> > trond.myklebust@hammerspace.com
> >
> >
