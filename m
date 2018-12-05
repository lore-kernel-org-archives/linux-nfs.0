Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BB95C07E85
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:41:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5AC3620850
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:41:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC3620850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727142AbeLENln (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 08:41:43 -0500
Received: from mail-vk1-f193.google.com ([209.85.221.193]:35716 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727025AbeLENln (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 08:41:43 -0500
Received: by mail-vk1-f193.google.com with SMTP id b18so4656839vke.2;
        Wed, 05 Dec 2018 05:41:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=EGK1Cc1IT+4U8/m30kOf91EPSOF+4KfsAR6smtke9ew=;
        b=Kd0R6fOCTM6cwRcUqhSkmRNePRP5MVlvOFEM2CamleyTQI95BN23W87am33kk097CN
         vGfB25gSaQMvUF1it008P6Ien6zsztr6+w8TwvZvqcO1lRH5dsm0TgJQ12nzN5tc0HrA
         dAIl4RhgjeF74eP33jMIdMO3MIpKhrrs4J4yqjGUpzbz68bAAzwA3Z5kz0kA/5lB8BqU
         MBt3TgNJmBNhpYwHlKRuf+5vQ1jMuqoRl8LcUyx8fNINXDar/GLof8opildTuLvoQuPI
         tKnbVknG/3vgAHGE6pTY4Qzry3ooFSWRnjsp1M4Vbz/QNrPgQK2tkhbZdmELMAd9B6cn
         9L3Q==
X-Gm-Message-State: AA+aEWYJ4BcAJcSSi8UD26rj2MRZ2TFyIDuM+sp7obLVv8zElAr6aEfr
        U5flFI6soUP5wesxnTKEZfKqVm6Dr+D1FdMbptHn8g==
X-Google-Smtp-Source: AFSGD/UZxgwhoo3/ppSmWmzsZH+UyBcxsNlADfgaaKBa1qo6XfRz9WxR6+aOWzoKr77RmzzncZKUDHu4KJGSKnRIxHI=
X-Received: by 2002:a1f:91cb:: with SMTP id t194mr10817554vkd.74.1544017302275;
 Wed, 05 Dec 2018 05:41:42 -0800 (PST)
MIME-Version: 1.0
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
 <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
In-Reply-To: <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Wed, 5 Dec 2018 14:41:30 +0100
Message-ID: <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
To:     Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        linux-mips@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Nemoto-san,

On Wed, Dec 5, 2018 at 2:11 PM Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> On Tue, 4 Dec 2018 14:53:07 +0100, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > I found similar crashes in a report from 2006, but of course the code
> > has changed too much to apply the solution proposed there
> > (https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html).
> >
> > Userland is Debian 8 (the last release supporting "old" MIPS).
> > My kernel is based on v4.20.0-rc5, but the issue happens with v4.20-rc1,
> > too.
> >
> > However, I noticed it works in v4.19! Hence I've bisected this, to commit
> > 277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by switching to using
> > iterators").
> >
> > Dropping the ",tcp" part from the nfsroot parameter also fixes the issue.
> >
> > Given RBTX4927 is little endian, just like my arm/arm64 boards, it's probably
> > not an endianness issue.  Sparse didn't show anything suspicious before/after
> > the guilty commit.
> >
> > Do you have a clue?
>
> If it was a cache issue, disabling i-cache or d-cache completely might
> help understanding the problem.  I added TXx9 specific "icdisable" and
> "dcdisable" kernel options for debugging long ago.
>
> I hope these options still works correctly with recent kernel but not
> sure.
>
> Also, disabling i-cache makes your board VERY slow, of course.

Thanks!

When using these options, I do see a slowdown in early boot, but the issue
is still there.

My next guess is an unaligned access not using {get,put}_unaligned(), which
doesn't seem to work on tx4927, but doesn't cause an exception neither.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
