Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C14D0C04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 16:59:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 73A1D2082F
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 16:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N++wWiZQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73A1D2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726895AbeLBEMS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 23:12:18 -0500
Received: from mail-yb1-f193.google.com ([209.85.219.193]:40204 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726826AbeLBEMS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 23:12:18 -0500
Received: by mail-yb1-f193.google.com with SMTP id c15so253653ybf.7;
        Sat, 01 Dec 2018 08:59:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Em4piUW/0hURhVgM0vws0JD3tdCTsbzBiN+MdhVbZQU=;
        b=N++wWiZQtnmVCJXRpxlMXxtMTPVknXoHa+piEajp/kHugjhnnVKgnuvrqUOy0CF1rs
         qxG10UbViwCH88IxKlwW1Gxm+tIJJZ82q0nn6UPEz5YlEwVlgF0PyZzRADF2kwZoQKJ2
         MdKYnoDoCDLfH6rTIikQaDXmOZMJy9e3EuDpS1Z8quA4PnrIRDwsaTGmQ85dcbNL31Hd
         OfVnY1+5eoTVzNSQBOyZZ+h5x1pH3+EgNznJYx+dB1gqnDnw+Rd6MkWI9sposynvG+7q
         LuCKHCnUi88sv1fp9NBHf5HlO9XlQMSK1xlb08XJs3lEgJDln8PL9NTiEEV3I2jEMK2W
         2lSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Em4piUW/0hURhVgM0vws0JD3tdCTsbzBiN+MdhVbZQU=;
        b=tuNfE6DhEEEMRGJuB0hzMIc7XzJRW1ozzjP9VMRyOiK13tmiSYA2LMDll/pyD/JDgq
         Gc5viHR0bMyZelxiFCZS/U2XyXuNQJw2LeKDUPab/5lznncgpqnQyq4yHE68flSLGLYC
         JxC4vfralvC1lgrzkRCm7Fspthgo9tDrBseBf6E9nHA6h2DKfh47w6esRFyfIdSiuRhq
         5HlWh+1og5HDaXbPvd//mC3PWDVgmQ9uA3dI3JdjOzRg7FsbAekFzB0QtheHgcnTRVc4
         hIZo0jTYI1EaKXPxyFmCY7YNOS3XCeL9SSBIoYUeINlLIHGf7HXTHbAOAheD+okRacqu
         6bYg==
X-Gm-Message-State: AA+aEWYVc1bMB+xSeTe+BIO6U4NJskA9ux7s53lOaK+FcT5ao1/NMd/A
        /Mc4ebo0z8R/CBZThERdmw5EyXoCBRSMjS2yyZE=
X-Google-Smtp-Source: AFSGD/VagwRxLgao6dOpAI6jeigGc1G0MIbWM/PH/fmC/HdQcLO8Gkpew0b0BzpstrC8GS7QyV7rN4d0GaeNFFuorFM=
X-Received: by 2002:a25:d80c:: with SMTP id p12mr808600ybg.507.1543683560686;
 Sat, 01 Dec 2018 08:59:20 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com> <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
 <CAN-5tyGV1F6EAwN3e3dHyvfL6UJhJu1m=GKCT4iVMy6uprcS+w@mail.gmail.com>
 <CAN-5tyFwE=5K4vCfjVLsyjgOfmLwQU9c-gwJHKedAwOoVWmQ=A@mail.gmail.com>
 <CAOQ4uxgENLCDH7QwtBPxA60dKEXvLVknBMY_Lgoetq_uQ=7gwA@mail.gmail.com> <CAN-5tyFGV=fUCbAG5mSvy=LXDpdp8VG9Sh1aGMkBHQAG1Rp1sQ@mail.gmail.com>
In-Reply-To: <CAN-5tyFGV=fUCbAG5mSvy=LXDpdp8VG9Sh1aGMkBHQAG1Rp1sQ@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Sat, 1 Dec 2018 18:59:09 +0200
Message-ID: <CAOQ4uxjAq6Hj-MOh7AzGbUXn6KYpPzpEU=C4aOEySJ=O721cjg@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, Dave Chinner <david@fromorbit.com>,
        Jeff Layton <jlayton@kernel.org>,
        Matthew Wilcox <willy@infradead.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 1, 2018 at 5:57 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Sat, Dec 1, 2018 at 9:03 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> >
> >
> > On Sat, Dec 1, 2018, 3:44 PM Olga Kornievskaia <olga.kornievskaia@gmail.com wrote:
> >>
> >> On Sat, Dec 1, 2018 at 8:23 AM Olga Kornievskaia
> >> <olga.kornievskaia@gmail.com> wrote:
> >> >
> >> > On Sat, Dec 1, 2018 at 3:11 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >> > >
> >> > > On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> >> > > <olga.kornievskaia@gmail.com> wrote:
> >> > > >
> >> > > > Relax the condition that input files must be from the same
> >> > > > file systems.
> >> > > >
> >> > > > Add checks that input parameters adhere semantics.
> >> > > >
> >> > > > If no copy_file_range() support is found, then do generic
> >> > > > checks for the unsupported page cache ranges, LFS, limits,
> >> > > > and clear setuid/setgid if not running as root before calling
> >> > > > do_splice_direct(). Update atime,ctime,mtime afterwards.
> >> > > >
> >> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> > > > ---
> >> > >
> >> > > This patch is either going to bring you down or make you stronger ;-)
> >> > >
> >> > > This is not how its done. Behavior change and refactoring mixed into
> >> > > one patch is wrong for several reasons. And when you relax same sb
> >> > > check you need to restrict it inside filesystems, like your previous patch
> >> > > did.
> >> > >
> >> > > You already had v7 patch reviewed-by 4 developers.
> >> > > What made you go and change it (and posted as v2)?
> >> > >
> >> > > Your intentions were good trying to fix the broken syscall, but
> >> > > I hope you understood that Dave didn't mean that you *have* to
> >> > > add the missing generic checks as part of your work. He just
> >> > > pointed out how broken the current interface is in the context of
> >> > > reviewing your patch.
> >> > >
> >> > > In any case, I hear that Dave is neck deep in fixing copy_file_range()
> >> > > so changes to this function should be collaborated with him. Or better
> >> > > yet, wait until he posts his fixes and carry on from there.
> >> > >
> >> > > If I were you, I would just go back to the reviewed v7 vfs patch.
> >> >
> >> > This is NOT a replacement to the v7 vfs patch??? This is a new patch
> >> > on top of that one.
> >> >
> >> > I assume that v7 patch has been OK-ed by everybody and is ready to go in???
> >> >
> >> > As you recall, what was left is to provide the functionality to relax
> >> > the check for the superblocks to be the same before calling the
> >> > do_splice_direct(). This patch attempt do this. I was under the
> >> > impression that to do so extra checks were needed to be added which I
> >> > added.
> >> >
> >>
> >> To clarify, previously I had a VFS patch with the client-side series
> >> to support "server to server" copy offload. It needed the
> >> functionality to be able to call copy_file_range with different super
> >> blocks.
> >>
> >> This patch series is for the server side support for the "server to
> >> server" copy offload. It requires ability to call copy_file_range()
> >> and do a copy between NFS and a local file system. Thus it needs
> >> generic_copy_file_range.
> >
> >
> > Ah. Sorry for the confusion.
> > My comment on change of behavior and refactoring in same patch still hold.
> > My comment about coordinate your work with Dave Chinner still hold.
>
> Understood. I will email Dave directly and coordinate.
>
> > Raise that with a comment about adding test coverage to the new
> > generic cross fs copy API to xfstest.
>
> What kind of extra coverage are you envisioning? Something that
> requires two different file systems mounted and then does a fs copy?
>

Yes, if you add this functionality you should add test coverage for the
added functionality. It's not going to be trivial to add cross fs type tests
to xfstests, but adding cross fs (same type) should be relatively easy
(copy_file_range from test fs to scratch fs).

> > Am I mistaken that this change affects any cross fs copy file range
> > by userspace and not only by kernel nfsd?
>
> That's correct, any cross fs copy is what I'm going for here.
>

Forgive me for being thick. After briefly going over the patches, I still don't
understand if you *need* to add generic cross fs copy to implement
server side copy support in nfsd? Or if you are adding it as an added bonus
to the community along with your SSC patch set?

The first two patches of the series seem unrelated to the rest, but maybe
I'm just not getting the connection?

Thanks,
Amir.
