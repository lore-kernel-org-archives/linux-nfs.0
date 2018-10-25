Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C43C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:54:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5FE1920848
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:54:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LosZIFo2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FE1920848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727350AbeJZB14 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 21:27:56 -0400
Received: from mail-yw1-f68.google.com ([209.85.161.68]:38446 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727319AbeJZB1z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 21:27:55 -0400
Received: by mail-yw1-f68.google.com with SMTP id d126-v6so3889260ywa.5;
        Thu, 25 Oct 2018 09:54:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=U11z14oidh2OFN4iVLR571CVtYTWDI4xULdl0wNsRYs=;
        b=LosZIFo2gDCFs4RTLXWCUa/31LqfEqr0RY9SIjMm/wl7dxfrSNM1h46nryvrCYQT4u
         wHd2JZS8r05TA+IEsNR42hi6l0OPDej/s/Htja1irW1vCZuvsMGrOI6LDpTqIJML6Sx3
         9zVc/RNEQNs8VRrAIj+4Bs52CQBs7kchiXOxXpVcIrZ1AJJHdKaCrBE4ZbrAa+jfgq/I
         A4gxvoRcu/yGdAblj27JmhkdZD4qeWGwi4dN6o3Cdqnj0FTMwR7hn9+n4frEmJWchL3k
         2SIXmHHz92p7JU6hp08eSXM5f43UaKO1jK7fifRBrrPtJhdDhzxEzc6AZhpP+gOUs3mC
         kjvw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=U11z14oidh2OFN4iVLR571CVtYTWDI4xULdl0wNsRYs=;
        b=uXOHxU2TxkGxJNqgBnJ9FIJZKR/kyn1jBdiH6G+VIz/BgLWLvKpCIEsvMc0B/60uWG
         vip8sCY3pyphxkEASRZEUoxbr1Uftmx0JOEKou792KOCacEKYo8a/6dJt5F6TIEgL055
         tAzrz+xnTV7c6izXJTx/wahSNWTmle9SuyWDy6Ra6lEU1z6fDPAl7jUu5n8ldTT0FFDp
         MyVOobi0xVW9HoFzzhtmJ46kJ7jmhZ28UuNCphverVk7g3CNL1nIDXt0ym5tJ2s1iP8z
         tag8Zi+s7BLkXOpScDDs9Op5KU5uXK25l+lyGb6ZCrSUq4+9Vj7ZS/AiNlQRMwrOyRcc
         8+Vw==
X-Gm-Message-State: AGRZ1gKm9UWgru8Yu+KyhR4izi1KgrGPrZBXtmcUoUy9iufqJq8/TuE7
        +cfTSr8y79k4ehF8WvpOujz21zt2PygbjZOoyWmmGX2L
X-Google-Smtp-Source: AJdET5f/wxlRLDZcyEnIsl/y9ixs1PjeUadGKPd3QuVQilHgDKFYmqIw9TqqL807YHopUajplCZnCPSULKneU/3UKuA=
X-Received: by 2002:a0d:d181:: with SMTP id t123-v6mr2235117ywd.241.1540486458684;
 Thu, 25 Oct 2018 09:54:18 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-6-olga.kornievskaia@gmail.com> <CAOQ4uxg4_eF2_uur7-S=SCc5QzyVUfqRBjr9yYDGLsq5Ai4GXA@mail.gmail.com>
 <CAN-5tyH2PiBUP0Si1pJsMbf8WARUG9rVoAr07oPbZ=CQuwg3Lw@mail.gmail.com>
In-Reply-To: <CAN-5tyH2PiBUP0Si1pJsMbf8WARUG9rVoAr07oPbZ=CQuwg3Lw@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 19:54:07 +0300
Message-ID: <CAOQ4uxiUpLgoBP1hQuQkKptJiOTATm_C9u7w1-kvqaNuqAT_2Q@mail.gmail.com>
Subject: Re: [PATCH v2 04/13] NFS: add cross file system check for copy_file_range
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

On Thu, Oct 25, 2018 at 6:28 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Thu, Oct 25, 2018 at 12:38 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > VFS copy_file_range was relaxed to allow for cross-device copy.
> > > Add a check to disallow cross file systems copy offload, both
> > > files are expected to be of NFS type.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  fs/nfs/nfs4file.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > >
> > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > index 4288a6e..7137e7b 100644
> > > --- a/fs/nfs/nfs4file.c
> > > +++ b/fs/nfs/nfs4file.c
> > > @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> > >  {
> > >         ssize_t ret;
> > >
> > > +       if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
> > > +               return -EXDEV;
> > > +
> >
> > You would need to doo  the patches in following order:
> > 1. add same sb check in nfs
> > 2. relax same sb check in vfs
> > 3. implement cross fs copy in nfs
> > 4. relax same sb to same sb type in nfs
>
> Thank you, I will reorder the patches.
>

On second thought, It's probably best to do #1 (for nfs, cifs, ovl) + #2
in the same patch, to prevent someone from backporting just #2
without #1.

Let me know if this was too cryptic.

Thanks,
Amir.
