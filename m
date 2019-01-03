Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50353C43612
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:00:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F7902070C
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:00:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730040AbfACOAZ convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 09:00:25 -0500
Received: from mail-vs1-f65.google.com ([209.85.217.65]:43705 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726858AbfACOAZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 09:00:25 -0500
Received: by mail-vs1-f65.google.com with SMTP id x1so20749660vsc.10;
        Thu, 03 Jan 2019 06:00:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=pw1CsK4x3m356v8m/ubFb8NHeLPyILOsgcnHAe+IkJo=;
        b=Aa10fO0SgmLD2v1wCFEzhjxLXAZOhSslsnaguVhR4V1O3d9D4UGQpc8WDmnfqWie0P
         mHj2IlqCbzWGRg9mdzSnvPF5Fzvmf0sHIqx8lWccfPU91fRyJRSx3dlEjDJhPJOdCsvZ
         yHsdb9B6kk3oKEseiUaIq1lOANyr/yLA0A2anOtfq9/+s9iU1cAWoIsVy2Bfh3slKVON
         dqH+KHSZorgnWMI1w7YtyXSCueeX+k+nwAg/iF4CEkfmcDl5O3bguS8Je+zAED2AGeCD
         PM3pMv4Jy7n1S916y6jK5uByUVYD6MIaxQ4up7dZRD+4ZkakECDOS/15OaGurB0AoXo9
         fIXA==
X-Gm-Message-State: AA+aEWar+nyytx3BxSN9AmTaWGlcglYdbdcx/5Uxk4CxFhGv+iqPcbre
        BRjdzzWH8fc12BA4DZWnP+6/EAPc/PEiYs5xjL/Eurim
X-Google-Smtp-Source: AFSGD/Vj9hHx6N9yxaFdqpp/ONw4PVzYEmv6lsWcBiD8Zti1jaDwVxvBuFzHGtWwybqpGX0BltNKp1GewuB/qi+8WaA=
X-Received: by 2002:a67:c202:: with SMTP id i2mr17241065vsj.11.1546524023732;
 Thu, 03 Jan 2019 06:00:23 -0800 (PST)
MIME-Version: 1.0
References: <20190103004211.12404-1-trond.myklebust@hammerspace.com> <20190103135226.7D5F2217F5@mail.kernel.org>
In-Reply-To: <20190103135226.7D5F2217F5@mail.kernel.org>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Thu, 3 Jan 2019 15:00:10 +0100
Message-ID: <CAMuHMdXTMod81YP5Vtv4KdWVMG3yLO4dR45CO1W4TfDSfg8LmQ@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
To:     Sasha Levin <sashal@kernel.org>
Cc:     Trond Myklebust <trondmy@gmail.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Sasha,

On Thu, Jan 3, 2019 at 2:52 PM Sasha Levin <sashal@kernel.org> wrote:
> [This is an automated email]
>
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 277e4ab7d530 SUNRPC: Simplify TCP receive code by switching to using iterators.
>
> The bot has tested the following trees: v4.20.0,
>
> v4.20.0: Build failed! Errors:
>     net/sunrpc/xprtsock.c:396:24: error: ‘struct bio_vec’ has no member named ‘page’; did you mean ‘bv_page’?
>
>
> How should we proceed with this patch?

Please drop it, as it was superseded by v2.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
