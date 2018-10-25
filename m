Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C297C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:12:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C59CE20834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:12:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E5E258nj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C59CE20834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727979AbeJZBqO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 21:46:14 -0400
Received: from mail-vk1-f194.google.com ([209.85.221.194]:39608 "EHLO
        mail-vk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727485AbeJZBqO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 21:46:14 -0400
Received: by mail-vk1-f194.google.com with SMTP id o10-v6so674860vki.6;
        Thu, 25 Oct 2018 10:12:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+40XgxDOQCsOSGyrXyGwwk5/M8CrxlrIvI3JLFcv5Sc=;
        b=E5E258njPwOBw/Fp0bmVtHFOofbbv5cqfgAV1S6oNnDqXWhsOUtfT51Q8Iehjmx9hp
         gvTWJ2E9sDovBYvmT/QMjeIXJjOoNbFn0nbk7MgAKAaLFGd7OROcwryR6It7j6jAWkAj
         XUB89WE4poNQQ96MO3TAOuCsuB6D4/yWcwQ1ZXz3x/nTQ/Lyf7VXRJsUP9reVi7VpcWw
         CRCJjjX2uSremLjippdjK1QNfR6Q6Fe8+bZRSHYtvvMpmqBUA6Wi32qYOFJi3aRHoUm/
         gOK0TTZAwLh89QzNz0DBzy1ARE8D0XOqqDJObgBpfeSOg4UTjmHh1zOmUHkWRALmzHsj
         BQvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+40XgxDOQCsOSGyrXyGwwk5/M8CrxlrIvI3JLFcv5Sc=;
        b=n8Eglv/ITWcbQJvQOBBM0jE83bgQK4V7KVymxhaBr+vrXhwQ8UpK6Q7wx1qhh6GrXi
         ikGESAHJ0WwIXj471KcCUDwoJ7MWIPNNUzXO1aRSar860t1FPehecZnG9eY1HOr6binO
         n+dZdWrWgdq/5cYotvr48PyRksQfI7Yp0Ow1V2WqeNUEU8RIk0P1YktGY5x/7F1/jUpJ
         FlqbjH4q9RNT0MvvlXm7ae2iU56bStYnzZ+EefixkkUjIxX714BiXahACk9p5bcrmhXb
         LIfXAkML3oQebvSv3SqSf/yvFyjTwU7JpCPb1L2p0XYbBzj3ISk94gnTKHeYc5TnoPmb
         oaHA==
X-Gm-Message-State: AGRZ1gJe4Ao5pJq82+TuCdXuNPg38XXZt65kVKghymjxSUUl+T8UudM1
        0XAPc4lcDUwuD3dtJBHlYmZlK378W9Qhzuf5Q7M=
X-Google-Smtp-Source: AJdET5d4UYdHVCHrjsYF3SEFvw9PPvue+7aZ1q1RqyRdz1odd0SVbXdG7Z3MGRv+j4dKKIpQEDfKczL/6P9Oc58x6mE=
X-Received: by 2002:a1f:d384:: with SMTP id k126-v6mr24299vkg.87.1540487552664;
 Thu, 25 Oct 2018 10:12:32 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-6-olga.kornievskaia@gmail.com> <CAOQ4uxg4_eF2_uur7-S=SCc5QzyVUfqRBjr9yYDGLsq5Ai4GXA@mail.gmail.com>
 <CAN-5tyH2PiBUP0Si1pJsMbf8WARUG9rVoAr07oPbZ=CQuwg3Lw@mail.gmail.com> <CAOQ4uxiUpLgoBP1hQuQkKptJiOTATm_C9u7w1-kvqaNuqAT_2Q@mail.gmail.com>
In-Reply-To: <CAOQ4uxiUpLgoBP1hQuQkKptJiOTATm_C9u7w1-kvqaNuqAT_2Q@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 13:12:20 -0400
Message-ID: <CAN-5tyHgfJLHW1zqpf4eU8OV1bn0wFuCn03rvzA=pe9giPJdUg@mail.gmail.com>
Subject: Re: [PATCH v2 04/13] NFS: add cross file system check for copy_file_range
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

On Thu, Oct 25, 2018 at 12:54 PM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Thu, Oct 25, 2018 at 6:28 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > On Thu, Oct 25, 2018 at 12:38 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > >
> > > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > > <olga.kornievskaia@gmail.com> wrote:
> > > >
> > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > >
> > > > VFS copy_file_range was relaxed to allow for cross-device copy.
> > > > Add a check to disallow cross file systems copy offload, both
> > > > files are expected to be of NFS type.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > > >  fs/nfs/nfs4file.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > > index 4288a6e..7137e7b 100644
> > > > --- a/fs/nfs/nfs4file.c
> > > > +++ b/fs/nfs/nfs4file.c
> > > > @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> > > >  {
> > > >         ssize_t ret;
> > > >
> > > > +       if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
> > > > +               return -EXDEV;
> > > > +
> > >
> > > You would need to doo  the patches in following order:
> > > 1. add same sb check in nfs
> > > 2. relax same sb check in vfs
> > > 3. implement cross fs copy in nfs
> > > 4. relax same sb to same sb type in nfs
> >
> > Thank you, I will reorder the patches.
> >
>
> On second thought, It's probably best to do #1 (for nfs, cifs, ovl) + #2
> in the same patch, to prevent someone from backporting just #2
> without #1.
>
> Let me know if this was too cryptic.

Thank you I think I understood.

In an unsubmitted version I had a single VFS patch that made the VFS
change and included the checks for the file systems. However, I
thought maybe it wasn't appropriate to have FS changes and VFS changes
in the same patch and thus I split them up. Since you say it's
actually preferred I will do so. Do I need to change the title from
just "VFS" to somehow indicate that it has NFS/CIFS/Overlayfs content?
Or is the current title ok?



>
> Thanks,
> Amir.
