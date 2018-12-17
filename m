Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E2B7C43612
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:03:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37CF12145D
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:03:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732217AbeLQODz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 09:03:55 -0500
Received: from mail-ua1-f66.google.com ([209.85.222.66]:42561 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727384AbeLQODz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 09:03:55 -0500
Received: by mail-ua1-f66.google.com with SMTP id d21so4443964uap.9;
        Mon, 17 Dec 2018 06:03:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=IyySPFQR501jnuyrqlTBkAENA+JvMUdw4OsdFoys3rU=;
        b=ZLx2lP6ZNkZHfLcxs0BEYB4a1NX8wUvppf1brWcbDWHPe7VfGonHfEpNbv835nDvO9
         JdFnX+tyiTQEDorFjm9UM6iAVn/h7bAotMCDNMWHsQLm9Z/IFZSDmvm3NmJrJt6xWa00
         eOmANSrFMU/xKhnwdsJz2mDhrDBeSp0pTWxyGz7DAa5OVbrEzn5E8G74FgSyfMfUe+JP
         HEthYp0JwGXQKnRjNcyuv3Iwq18+s9E9RTlJMPeoS1Y5VpvRWHIHal8oEA0eK0M0K6AM
         f8nF+VgtPI8cAh4HHCYfziC1Qec7XMeCajTcJE+uNFLNIP7NLb61/1qbvQn5cVMU4tUc
         JA+Q==
X-Gm-Message-State: AA+aEWb9dh4LUhAlewiW9DE/cVdoZPYDTFs4RjPTslbJ7Ej8VIrXtS7G
        dM/d7Gf+nSMhNutXvsBs9YkGoU5HraKHi45ECUA=
X-Google-Smtp-Source: AFSGD/XHOkyPl9wjRgjxJqbMLdZ4TZbyrFYS7eEaqX7VHMXvZ4gtNEhnWD/TynJ6lmJHKoWWwt/iZWaJAgP5cJngddQ=
X-Received: by 2002:ab0:210e:: with SMTP id d14mr6327048ual.20.1545055428920;
 Mon, 17 Dec 2018 06:03:48 -0800 (PST)
MIME-Version: 1.0
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
 <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp> <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
 <92ce4b8c2b2d53e27ed5bc0e5af3fee4bc17b4dc.camel@hammerspace.com> <CAMuHMdXyfEVOWoBOx0Ywm6vw5oQ6eHNXFhQBKTfRSBOmPYGM6Q@mail.gmail.com>
In-Reply-To: <CAMuHMdXyfEVOWoBOx0Ywm6vw5oQ6eHNXFhQBKTfRSBOmPYGM6Q@mail.gmail.com>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Mon, 17 Dec 2018 15:03:35 +0100
Message-ID: <CAMuHMdXT_25_64w88KTnAYDwmLnMACua=s2PgAxDv=1ZaBmB7A@mail.gmail.com>
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
To:     trondmy@hammerspace.com
Cc:     Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        linux-mips@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On Wed, Dec 5, 2018 at 3:47 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Wed, Dec 5, 2018 at 2:45 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
> > On Wed, 2018-12-05 at 14:41 +0100, Geert Uytterhoeven wrote:
> > > On Wed, Dec 5, 2018 at 2:11 PM Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> > > wrote:
> > > > On Tue, 4 Dec 2018 14:53:07 +0100, Geert Uytterhoeven <
> > > > geert@linux-m68k.org> wrote:
> > > > > I found similar crashes in a report from 2006, but of course the
> > > > > code
> > > > > has changed too much to apply the solution proposed there
> > > > > (
> > > > > https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html
> > > > > ).
> > > > >
> > > > > Userland is Debian 8 (the last release supporting "old" MIPS).
> > > > > My kernel is based on v4.20.0-rc5, but the issue happens with
> > > > > v4.20-rc1,
> > > > > too.
> > > > >
> > > > > However, I noticed it works in v4.19! Hence I've bisected this,
> > > > > to commit
> > > > > 277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by switching
> > > > > to using
> > > > > iterators").
> > > > >
> > > > > Dropping the ",tcp" part from the nfsroot parameter also fixes
> > > > > the issue.
> > > > >
> > > > > Given RBTX4927 is little endian, just like my arm/arm64 boards,
> > > > > it's probably
> > > > > not an endianness issue.  Sparse didn't show anything suspicious
> > > > > before/after
> > > > > the guilty commit.
> > > > >
> > > > > Do you have a clue?
> > > >
> > > > If it was a cache issue, disabling i-cache or d-cache completely
> > > > might
> > > > help understanding the problem.  I added TXx9 specific "icdisable"
> > > > and
> > > > "dcdisable" kernel options for debugging long ago.
> > > >
> > > > I hope these options still works correctly with recent kernel but
> > > > not
> > > > sure.
> > > >
> > > > Also, disabling i-cache makes your board VERY slow, of course.
> > >
> > > Thanks!
> > >
> > > When using these options, I do see a slowdown in early boot, but the
> > > issue
> > > is still there.
> > >
> > > My next guess is an unaligned access not using {get,put}_unaligned(),
> > > which
> > > doesn't seem to work on tx4927, but doesn't cause an exception
> > > neither.
> >
> > Can you try my linux-next branch on git.linux-nfs.org? It contains a
> > fixes for a hang that results from the above commit.
> >
> > git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
>
> Thanks for the suggestion, but unfortunately it doesn't help.

In the mean time, I tried your newer linux-next, no change.
I tried several other things:
  - remove the packed attribute (why did you add that?),
  - verify (at runtime) that all accesses to fraghdr, xid, and calldir
are aligned,
  - enable RPC_DEBUG_DATA, nothing fishy seen at first sight.

Is anyone else seeing this on MIPS, or any other platform?
Does mounting NFS with -o nfsvers=3,tcp work on other MIPS platforms?

Thanks!


Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
