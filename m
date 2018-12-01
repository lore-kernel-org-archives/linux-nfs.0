Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E34AC04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 13:44:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 521CB20834
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 13:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mKGQuxnw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521CB20834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726577AbeLBA5L (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 19:57:11 -0500
Received: from mail-ua1-f65.google.com ([209.85.222.65]:43969 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726570AbeLBA5L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 19:57:11 -0500
Received: by mail-ua1-f65.google.com with SMTP id z11so2893707uaa.10;
        Sat, 01 Dec 2018 05:44:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9pS5m9VoQ+7WBp4GcBl6hQGrOzYF9btHAWGbH+/zH4w=;
        b=mKGQuxnwf6NanBJ4KrX9R/LBbpNprR+PB8LU9VbwwzuRa7yOUHzHOSWAk/jdzBJUXr
         JpR2TWCaVz7Zhx4BOR8+BHg7oQsl3+n06WYIo2VFRj3dfOErtA6Vn105yDOh5dQ4Tdh6
         G8Pcx7axd+a2xbT3C00+XyCd3x1Lg5faUQtAyBWvLW2SKKC46EUBshKURaOWm/+6pFt0
         qZXYAIOjce4gt5cEbbG/WeRvs4P7hSBL9mJ/oYtesaMyPEtCVsv5lY3oMFZnqBLYUfza
         Ap2uBty1Sh5hYhUFD6tNYPEM/A3d+ipKVDllVnptJI2h1du8TlRaBNdNM38dnsfDcqYn
         7Q5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9pS5m9VoQ+7WBp4GcBl6hQGrOzYF9btHAWGbH+/zH4w=;
        b=JuDLzX6Q503NIkIJ3Q2sTMnoyiIY8/i6UybserqQj3zVwSZrjFOEMD+V2jFFfev8PC
         0q0LVBd7X3bMypT63U+PnQWYESugKL0l0lrWOboWFOYkwhI71+PIKJlwWjOJZj7BRs9n
         vahGS3dOzWIJoWfIcrVl8NbFUv+YP1kqPSWvsSKq30+0kwFr9uKYCk71wSMQmMhd3dlj
         tUIXlbf5Xmgbue/DXqz6+uVdyNOcy/55fUM1W8JiMbCdLXULifHJL6mHZBDf9tzR9gj0
         nIrLRim6Izx8rEKlO4pNcaY6yDPb4Ih+MvmY7FyDOepAQcCTKcFWg4Y2abH3QvbVULeH
         AjWw==
X-Gm-Message-State: AA+aEWYSOnyLSgjAkUm6s/7u1Z7eEE0D5xLNrxloW4R1x6LdH/89xuNS
        fnGNp32iARlVzUUZlh3OOWz1O+re3ordX9n55VM=
X-Google-Smtp-Source: AFSGD/XNrAEshQtx+psNBlJyLyy0oNeI+lFPZEMHRRgKO+WXIU3JmS6BKVLF9tn+25gbl5hc0Lu2Ao6UnN0b3+QpT64=
X-Received: by 2002:ab0:5648:: with SMTP id z8mr4362739uaa.51.1543671876554;
 Sat, 01 Dec 2018 05:44:36 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com> <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
 <CAN-5tyGV1F6EAwN3e3dHyvfL6UJhJu1m=GKCT4iVMy6uprcS+w@mail.gmail.com>
In-Reply-To: <CAN-5tyGV1F6EAwN3e3dHyvfL6UJhJu1m=GKCT4iVMy6uprcS+w@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Sat, 1 Dec 2018 08:44:24 -0500
Message-ID: <CAN-5tyFwE=5K4vCfjVLsyjgOfmLwQU9c-gwJHKedAwOoVWmQ=A@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, david@fromorbit.com,
        willy@infradead.org, jlayton@kernel.org, stfrench@microsoft.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 1, 2018 at 8:23 AM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Sat, Dec 1, 2018 at 3:11 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > Relax the condition that input files must be from the same
> > > file systems.
> > >
> > > Add checks that input parameters adhere semantics.
> > >
> > > If no copy_file_range() support is found, then do generic
> > > checks for the unsupported page cache ranges, LFS, limits,
> > > and clear setuid/setgid if not running as root before calling
> > > do_splice_direct(). Update atime,ctime,mtime afterwards.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> >
> > This patch is either going to bring you down or make you stronger ;-)
> >
> > This is not how its done. Behavior change and refactoring mixed into
> > one patch is wrong for several reasons. And when you relax same sb
> > check you need to restrict it inside filesystems, like your previous patch
> > did.
> >
> > You already had v7 patch reviewed-by 4 developers.
> > What made you go and change it (and posted as v2)?
> >
> > Your intentions were good trying to fix the broken syscall, but
> > I hope you understood that Dave didn't mean that you *have* to
> > add the missing generic checks as part of your work. He just
> > pointed out how broken the current interface is in the context of
> > reviewing your patch.
> >
> > In any case, I hear that Dave is neck deep in fixing copy_file_range()
> > so changes to this function should be collaborated with him. Or better
> > yet, wait until he posts his fixes and carry on from there.
> >
> > If I were you, I would just go back to the reviewed v7 vfs patch.
>
> This is NOT a replacement to the v7 vfs patch??? This is a new patch
> on top of that one.
>
> I assume that v7 patch has been OK-ed by everybody and is ready to go in???
>
> As you recall, what was left is to provide the functionality to relax
> the check for the superblocks to be the same before calling the
> do_splice_direct(). This patch attempt do this. I was under the
> impression that to do so extra checks were needed to be added which I
> added.
>

To clarify, previously I had a VFS patch with the client-side series
to support "server to server" copy offload. It needed the
functionality to be able to call copy_file_range with different super
blocks.

This patch series is for the server side support for the "server to
server" copy offload. It requires ability to call copy_file_range()
and do a copy between NFS and a local file system. Thus it needs
generic_copy_file_range.

>
> >
> > Thanks,
> > Amir.
