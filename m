Return-Path: <SRS0=0ybF=OQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D249C65BAF
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 16:19:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 518B82083D
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 16:19:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 518B82083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726110AbeLGQTa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Dec 2018 11:19:30 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:45811 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726041AbeLGQTa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2018 11:19:30 -0500
Received: by mail-vs1-f66.google.com with SMTP id v10so2743385vsv.12;
        Fri, 07 Dec 2018 08:19:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=sKCXhSF44P5ohZOwcfLrWgu0vOnSIZ5gKQA9e5j6l5Y=;
        b=X3iGtNS0KycW86yhNRYxQ/xUQU0tFcPk+86xcPoxQf4FQGQaxJ42VcLqfoX7KErvzV
         v6uRO2FoEFufp6I92GIR8RG1JOW/ihbPp+T8XDeDmiB0Q0SwIx3+DTYpz8GrTICX+cB+
         6Xrkx8CX2wo/KkWF4INNZ11qNyHuFTMqA7SW6xWZe4spwcmtSvR+ybYUk9EoqM+sXMAC
         60jeYvB9upcZKSLKjOkBN/r+MUnb7tZ5BSAtis4gHjN7N0qhgGHzKXCVhHsvVnQNSh9C
         uwfVDfKAley8141UWHWw6C8x4+w2LgHQFibC0bLFdOMV99byvAFkUPzfdvOiHWPp8QOa
         BodQ==
X-Gm-Message-State: AA+aEWZ7P26q3oMcNK4VnWSPdFc7Tc9/mQgfeQ/TCvBod0tU8PMXIXIk
        9DTic7794ehvrYN6e6Lsl3BbBrAuapS2MTqnJPBHFg==
X-Google-Smtp-Source: AFSGD/U8Hv5LkSN3xKFPIGm7iVrAT3AOBNWL2Tk84x7f30F9fCRTbTLR1MB8CV813THfv8L7Zb9N0y6lAzewBLMPOo8=
X-Received: by 2002:a67:3885:: with SMTP id n5mr1045428vsi.96.1544199567976;
 Fri, 07 Dec 2018 08:19:27 -0800 (PST)
MIME-Version: 1.0
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
 <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp> <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
 <20181207.235141.2138062629640003368.anemo@mba.ocn.ne.jp>
In-Reply-To: <20181207.235141.2138062629640003368.anemo@mba.ocn.ne.jp>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Fri, 7 Dec 2018 17:19:13 +0100
Message-ID: <CAMuHMdUHxO2aTf+ixnG_U=nzHp85eoPnoqvMUHFP+TJtAL_nEA@mail.gmail.com>
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

On Fri, Dec 7, 2018 at 3:51 PM Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> On Wed, 5 Dec 2018 14:41:30 +0100, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > My next guess is an unaligned access not using {get,put}_unaligned(), which
> > doesn't seem to work on tx4927, but doesn't cause an exception neither.
>
> IIRC, TX49 can raise an exception on unaligned access.

I thought so, too, but had verified that reading from an unaligned address
didn't raise an exception, but returned a corrupt value instead.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
