Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E51BEECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:28:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA36220834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:28:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pM7nrLUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA36220834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727538AbeJZABs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:01:48 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:33057 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727367AbeJZABr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 20:01:47 -0400
Received: by mail-vs1-f67.google.com with SMTP id 125so430787vsi.0;
        Thu, 25 Oct 2018 08:28:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BqpuHSu8gC42lhCuQp4mq7e6j7qv1V1iCw8EUEW6qDM=;
        b=pM7nrLUYP+vAE9XgfK3JHnbTnLWVTb9Cm3JHtkpbSIIo0W+bsQL81xm/V+nFFwoUiB
         jEZfipDd/Kq4HUW50ZKX2O8PA9HPBva8FldIp/LHjEM1GjHbj8yKOELL9++RB0ZJezYR
         0vb+8zqam1Zgf8z5PGglFMzqTrsDWSXFYcFDqImnfO7bCTEKfLu3O+D1y+8l9jhTwSs1
         0JepiHs1eZdpkRVA5q1BETdhzwPbiHROXfruAdGye3iTmJCg2hghRWulH9dvZitSZKe3
         BXCbRSGK3VIMVmBtV06/Gg86P9fRA88jF2RnU22POKwu3YjR2AKfHwVmDlAhx+kTY0TJ
         su4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=BqpuHSu8gC42lhCuQp4mq7e6j7qv1V1iCw8EUEW6qDM=;
        b=qIQRbyWYk3l1oD4Z2NONq+fHaUQr7Yc4HBLSJEA076EN27pxo2J7fmMm8VtR0EYNOv
         lvEjP5e22p4V/F8uz6FZqwaMyOwOKMJ4fdJWd6DKtwL4Axqr128Yl80aE4nthOxxGGIJ
         hrMa+B4ECLo9QHG93HtplNfrZRTQgx/9w9OQvrwW6478/X4JX/3gFXJ4Es3Hm5idRjSR
         YhEg14ptI1Jq2KsKe8mAR7dgzYejHQLzJagW3MWQWe+rDrdgqU+4Qs3mb0WK/iCoTBKJ
         l+kPsWp67YkWsC6Curo+EnWP6cSY78mdeUy/F8yjoU6ahyTaFelKa0xmbbnjyksOm21b
         9yQw==
X-Gm-Message-State: AGRZ1gLUZUDzX0QsEReaDrw/49IzXCQm09DMxwzi2lqAk90v3hMWrn9F
        frrpnPvZSKIYHhFrmMgqz77rFpGZn++mZdXTh+k=
X-Google-Smtp-Source: AJdET5dEfhr+4nOWfc/T75fL8MKZddmZX17HEL+lUZOGTmCR9aI0qY/BC+K/W6M6rUa7OucTIjfNiRq/iqeY22rPF3o=
X-Received: by 2002:a67:ca9d:: with SMTP id a29mr923121vsl.194.1540481311052;
 Thu, 25 Oct 2018 08:28:31 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-6-olga.kornievskaia@gmail.com> <CAOQ4uxg4_eF2_uur7-S=SCc5QzyVUfqRBjr9yYDGLsq5Ai4GXA@mail.gmail.com>
In-Reply-To: <CAOQ4uxg4_eF2_uur7-S=SCc5QzyVUfqRBjr9yYDGLsq5Ai4GXA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 11:28:19 -0400
Message-ID: <CAN-5tyH2PiBUP0Si1pJsMbf8WARUG9rVoAr07oPbZ=CQuwg3Lw@mail.gmail.com>
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

On Thu, Oct 25, 2018 at 12:38 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > VFS copy_file_range was relaxed to allow for cross-device copy.
> > Add a check to disallow cross file systems copy offload, both
> > files are expected to be of NFS type.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs4file.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 4288a6e..7137e7b 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> >  {
> >         ssize_t ret;
> >
> > +       if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
> > +               return -EXDEV;
> > +
>
> You would need to doo  the patches in following order:
> 1. add same sb check in nfs
> 2. relax same sb check in vfs
> 3. implement cross fs copy in nfs
> 4. relax same sb to same sb type in nfs

Thank you, I will reorder the patches.

>
> Thanks,
> Amir.
