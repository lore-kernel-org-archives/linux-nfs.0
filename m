Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35540 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdKSK65 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Nov 2017 05:58:57 -0500
MIME-Version: 1.0
In-Reply-To: <20171118185011.4729-1-trond.myklebust@primarydata.com>
References: <cce6f1be-0481-4ecc-85e2-a626cf381ce3@oracle.com> <20171118185011.4729-1-trond.myklebust@primarydata.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 19 Nov 2017 11:58:56 +0100
Message-ID: <CAMuHMdXF=n0Wy1PZi5smz-MS4JUbUBfnfeVO9NtJwj2sxUttSQ@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Ensure gcc 4.4.4 can compile initialiser for "invalid_stateid"
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        "linux-nfs @ vger . kernel . org" <linux-nfs@vger.kernel.org>,
        "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 18, 2017 at 7:50 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> gcc 4.4.4 is too old to have full C11 anonymous union support, so
> the current initialiser fails to compile.

Thanks! Works fine with gcc-4.1.2, too.

> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
