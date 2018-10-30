Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C684BC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 13:40:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BFB3205F4
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 13:40:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="blzwiX9g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BFB3205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727870AbeJ3Wdy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 18:33:54 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:34992 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727450AbeJ3Wdy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2018 18:33:54 -0400
Received: by mail-vs1-f66.google.com with SMTP id d62so5927995vsd.2;
        Tue, 30 Oct 2018 06:40:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=E6dFq1HvBydx2LIgrQe4HHVaz0tF3FIaDF1esNIA3sU=;
        b=blzwiX9gCE+Xs3u/wLxAAH8TyNNN6cKsFq5WyiFwQaQMyaVYZU0o5Kv/yLAwfm/0Bn
         9Hpg2BpsHxC5l4qhpI6WWejTbJQJKt4/CaiPfJ3P4PXfIC1iuz6GNgkQc3ecnvbCTEA+
         q/+OgRk4FXbJCh9XAvX3qkqL+9FYRVYmXvBja76TxECJ8/pCbmNDqjNWAL7Isu/W6RRk
         T3MY1iirdVV1pdAC+FCOCeGZ4cDD+44wWFUpjZ6Rk8FJhlICdBYey4BlhXXy6YYyn3bx
         /ilL4FUO5CPz8K8mmvcfMxW4mE02g0/72Jr6Qvv51dfqHH8VWYNM0DyPRkinc+vGz8sf
         Of8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=E6dFq1HvBydx2LIgrQe4HHVaz0tF3FIaDF1esNIA3sU=;
        b=B4S6MUvyNr88XOZDPZ2AtTtGmN1TAV0TObi49Vmh3P24vMIpyWnVL2Kulcchz7dBoU
         i50WmS6KoVlN6eynZSLKbnl1LWThfaopF/0nNdbYBk7lSclY09+iL8UvIy0tSO+zLHzp
         2ctqlqIP8SdUZu4WxsVIzLNjxscD04mSY/28Ph1UmIJihZeiwuIGJ0dz4UupL7Ng1/Hx
         GJgd0EdmjH4E8j+DWxyptfzWGLIhUlqDYvfwiNnayL1W9oXJXpjdSA9HXiLaEmjJyoHg
         ZWOPTUjNejuNnt2vEFbv/F2LnbZCM5K8X8inSovtD9//lk7rul/7mF/MwnfwkROBK8qJ
         XdXg==
X-Gm-Message-State: AGRZ1gJwgGEHeqoZY+Mryz5QT4U/He2b1IN98fTdIh+/IGvdLBtmhSYl
        RZ/bx2D7hrYNJWOBwyNJ7BJlS+o1OwivgLpF6YRr4TN8
X-Google-Smtp-Source: AJdET5frRn4wysuFJ6gCP1y+nJZoV3/WdG1SZcgNlkKc/tCDhagijFxjudnv1SEFsBQ5gq0rCNSAeIKB3vh1XiJgmVk=
X-Received: by 2002:a67:a858:: with SMTP id r85mr7755791vse.215.1540906821055;
 Tue, 30 Oct 2018 06:40:21 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com> <20181027092750.GL6311@dastard>
 <CAN-5tyEeMrRVUyP61Vv-dwFUvm7q55Q3=NVJkeZN+XoCcAOCDQ@mail.gmail.com> <20181030090344.GN6311@dastard>
In-Reply-To: <20181030090344.GN6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 30 Oct 2018 09:40:09 -0400
Message-ID: <CAN-5tyEfYcSvgzhftM7r8YoB7KQDiJnJXQPTE9pcML6BRSbbYA@mail.gmail.com>
Subject: Re: [PATCH v4 02/11] VFS: copy_file_range check validity of input
 source offset
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

On Tue, Oct 30, 2018 at 5:03 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Oct 29, 2018 at 10:41:22AM -0400, Olga Kornievskaia wrote:
> > On Sat, Oct 27, 2018 at 5:27 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > >
> > > > Input source offset can't be beyond the end of the file.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > > >  fs/read_write.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > index fb4ffca..b3b304e 100644
> > > > --- a/fs/read_write.c
> > > > +++ b/fs/read_write.c
> > > > @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > > >               }
> > > >       }
> > > >
> > > > +     if (pos_in >= i_size_read(inode_in))
> > > > +             return -EINVAL;
> > > > +
> > >
> > > vfs_copy_file_range seems ot be missing a wide range of checks.
> > > rlimit, s_maxbytes, LFS file sizes, etc. This is a write, so all the
> > > checks in generic_write_checks() apply, right? And the same security
> > > issues like stripping setuid bits, etc? And we need to touch
> > > atime on the source file, too?
> >
> > Yes sound like needed checks.
> >
> > > We've just merged 5 or so patches in 4.19-rc8 and we're ready to
> > > merge another ~30 patch series to fix all the stuff missing from the
> > > clone/dedupe file range operations that make them safe and robust.
> > > It seems like copy_file_range is all the checks it needs, too?
> >
> > Are you proposing to not do this check now in favor of the proper work
> > that will do all of those checks you listed above?
>
> No, I'm saying that if you're adding one check, there's a whole heap
> of checks that still need to be added, *especially* if this is going
> to fall back to page cache copy between superblocks that may have
> different limits and constraints.
>
> There's security issues in this API. They need to be fixed before we
> allow it to do more and potentially expose more problems due to it's
> wider capability.

Sounds like you are arguing that enabling generic copy_file_range()
via do_splice() isn't a good thing without those checks. I'm totally
OK with removing this functionality. As I mentioned earlier I added it
as I thought it was beneficial and I assumed that do_splice() was a
generic enough API to handle what was needed.

What this patch series was intended for was removing/relocating the
cross device check and it sounds like I should be keeping it just to
that.

> > I can not volunteer
> > to provide this comprehensive check.
>
> Why not?

I don't have the expertise in the VFS code.

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
