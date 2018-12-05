Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B715FC04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 14:48:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 829AE20878
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 14:48:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 829AE20878
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727628AbeLEOr7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 09:47:59 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:35538 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727094AbeLEOr7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 09:47:59 -0500
Received: by mail-vs1-f66.google.com with SMTP id e7so12227676vsc.2;
        Wed, 05 Dec 2018 06:47:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=N4N2sZNH53i6D9yRmiCx9A+jnggLmHj8GKEOX/5FTrU=;
        b=syT0Cxd7iRsE6xxv81HldcaU5rcJwGRyThmoW1uaFEwCCS5GLOo0sUht3GViYaOlDQ
         ZG08GL4dKfbT30ZvwrHoetmxEi9f2MH672VbjGUQocW7rRNZH2TV4144pOKXUoeVQIfT
         votsd3vgZhMxnRJgR7G6m4YjD+Avxy+BDIxhL31mIR3wzRjAxiTV+tPVKQb+cpM8fRTB
         6p6hxgF/+/uVfqhoaR2v22nheRIvW8yw6Ot1laZS/9uPA0ZYGo0Adr8Hr+ayMEiYuvrc
         qtpdf+dCutSdTbeW9Y4oXisYfPaNn9xrldXr8WtWuJyDWt7ZIQ6fGGeqG0XJ9tLA66LF
         AyqQ==
X-Gm-Message-State: AA+aEWbyR8JtTLk47J4TusiJRd0cD3UnVJ+cGxCnD/huqxQKsseZXzq6
        /emScrQSSuyfLcHDRuHBuZN/hBwi/4Ewy1RiGTz9Kw==
X-Google-Smtp-Source: AFSGD/Uy+i6JE9+hiJGclbeIZTeGcdjkd4MCajWCRvlYpZr8AXZ0fXFsHNvyQb/TGAszNCY9o2NxiJlfS3SKFXdg5vA=
X-Received: by 2002:a67:f43:: with SMTP id 64mr10935737vsp.166.1544021277718;
 Wed, 05 Dec 2018 06:47:57 -0800 (PST)
MIME-Version: 1.0
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
 <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp> <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
 <92ce4b8c2b2d53e27ed5bc0e5af3fee4bc17b4dc.camel@hammerspace.com>
In-Reply-To: <92ce4b8c2b2d53e27ed5bc0e5af3fee4bc17b4dc.camel@hammerspace.com>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Wed, 5 Dec 2018 15:47:45 +0100
Message-ID: <CAMuHMdXyfEVOWoBOx0Ywm6vw5oQ6eHNXFhQBKTfRSBOmPYGM6Q@mail.gmail.com>
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

On Wed, Dec 5, 2018 at 2:45 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
> On Wed, 2018-12-05 at 14:41 +0100, Geert Uytterhoeven wrote:
> > On Wed, Dec 5, 2018 at 2:11 PM Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> > wrote:
> > > On Tue, 4 Dec 2018 14:53:07 +0100, Geert Uytterhoeven <
> > > geert@linux-m68k.org> wrote:
> > > > I found similar crashes in a report from 2006, but of course the
> > > > code
> > > > has changed too much to apply the solution proposed there
> > > > (
> > > > https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html
> > > > ).
> > > >
> > > > Userland is Debian 8 (the last release supporting "old" MIPS).
> > > > My kernel is based on v4.20.0-rc5, but the issue happens with
> > > > v4.20-rc1,
> > > > too.
> > > >
> > > > However, I noticed it works in v4.19! Hence I've bisected this,
> > > > to commit
> > > > 277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by switching
> > > > to using
> > > > iterators").
> > > >
> > > > Dropping the ",tcp" part from the nfsroot parameter also fixes
> > > > the issue.
> > > >
> > > > Given RBTX4927 is little endian, just like my arm/arm64 boards,
> > > > it's probably
> > > > not an endianness issue.  Sparse didn't show anything suspicious
> > > > before/after
> > > > the guilty commit.
> > > >
> > > > Do you have a clue?
> > >
> > > If it was a cache issue, disabling i-cache or d-cache completely
> > > might
> > > help understanding the problem.  I added TXx9 specific "icdisable"
> > > and
> > > "dcdisable" kernel options for debugging long ago.
> > >
> > > I hope these options still works correctly with recent kernel but
> > > not
> > > sure.
> > >
> > > Also, disabling i-cache makes your board VERY slow, of course.
> >
> > Thanks!
> >
> > When using these options, I do see a slowdown in early boot, but the
> > issue
> > is still there.
> >
> > My next guess is an unaligned access not using {get,put}_unaligned(),
> > which
> > doesn't seem to work on tx4927, but doesn't cause an exception
> > neither.
>
> Can you try my linux-next branch on git.linux-nfs.org? It contains a
> fixes for a hang that results from the above commit.
>
> git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next

Thanks for the suggestion, but unfortunately it doesn't help.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
