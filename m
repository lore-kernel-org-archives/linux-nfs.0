Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B37EC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:23:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F28B521852
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:23:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729529AbeLTPX3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 10:23:29 -0500
Received: from mail-vs1-f45.google.com ([209.85.217.45]:41850 "EHLO
        mail-vs1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729211AbeLTPX2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2018 10:23:28 -0500
Received: by mail-vs1-f45.google.com with SMTP id t17so1298885vsc.8;
        Thu, 20 Dec 2018 07:23:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ATbPs0E59fZkFEPIRNAcxIyMAvKWNp3qaDirKrrdB10=;
        b=ZwWhTjEn+iRfsLZm42WoLmtZ5yyh45fdNN+eokd7kSQx4uYJWAkWxhs1VZY+ADYIew
         rjNNahIj0WgyN2BVRh2SFOgat3RsRnSMOVA+1VDqoOtvmsnRy9i6oG8BGgyHVVJWO8Gj
         4qzO6UvDr54/Mc/6mJeagAprmEp1e0VyTkQMg2/RaS/jGgSu/ZBF6hf0bN/T/RwpGjHT
         B51OuIqVmHBQRlALH/tFBysf8mArQo2e38wj3TOjziV3r4htg+9fog+cLVL9Fpg6MVdj
         XOa2eGIVZKZm/UibE3PeSYUEL9TKw56v28BAnm/7tkc/VSCFNV0r1PCpANFovV8TfdP1
         3Gqw==
X-Gm-Message-State: AA+aEWbE457LRV/78GgVjsBaDghAwERWkeR5H9VUfFFqdPh8S2hevySh
        LVxfehL5bJ7ndl66VXA4a9LPfSQi60jWrsxOwecwn7JufRg=
X-Google-Smtp-Source: AFSGD/USLSSY3Dli7YVtGhcazmUpZunWAaIYCvVWiZIl8H8URjut0GUJ7gp4TktMB79aoHa4hy3azamZm3mJO0g4p24=
X-Received: by 2002:a67:b60d:: with SMTP id d13mr12669228vsm.152.1545319407397;
 Thu, 20 Dec 2018 07:23:27 -0800 (PST)
MIME-Version: 1.0
References: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
In-Reply-To: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Thu, 20 Dec 2018 16:23:15 +0100
Message-ID: <CAMuHMdWufYg2rxw=sZmCsoQs7MxK=FW0HKaF58k-TDT8X0Zxiw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 19, 2018 at 9:28 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
> The following 3 patches fix a regression in the NFS/RPC TPC re-
> connection code which can cause the RPC transmission to hang. The issue
> was discovered by Dave Wysochanski last week.
>
> With this pull, we still have one more regression to fix. MIPS is
> seeing data corruption due to the fact that the iovec_iter code does
> not appear to call flush_dcache_page() after copying data into the bvec
> pages. We need guidance from Al as to how he wants this fixed.

FTR, the report for that issue is
https://lore.kernel.org/lkml/CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com/

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
