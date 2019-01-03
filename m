Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2985BC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 10:16:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F36C720815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 10:16:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726661AbfACKQn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 05:16:43 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:45789 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726003AbfACKQn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 05:16:43 -0500
Received: by mail-vs1-f66.google.com with SMTP id x28so20449623vsh.12
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 02:16:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=IFkn4CM95eQVnL9i5Ojbpi9mZRSaCjV3tX+nJEvnX3M=;
        b=epMIkq9a8DXTnV0a8VDP4fb+kt6jmlTvtogZgxQEXQk0HaBD+ErABinxekL57mQNhC
         VmUjBFdgOzD72vRvDVFDq8OtX7p5jvD6R6CY1JvN54v/AsZqS6N4/F4xloKLF7QM6kie
         9qB7lQaAkEPorMnikFpEpj+GuDUiat5fqnQAgu0RqD9gbhkZvKB2t3Ru83dNaaJafFXC
         hzCSUUgMsoUKP5uNDifNs96nVma1FHsrXsSbxaUbJjHvu2sCNIwLNEutxbCrg91PV19O
         aw6m4uVWPoveB/kCMWCAgqld04vyxVuj6vz349uP9ai95L/2qt21RigznRPGuSSbCz0a
         nGrA==
X-Gm-Message-State: AJcUuke6qQ2/5R7F7VnoF2rJo+p7l7pc92nyQ1dRiRuV4EWyUZ7wguKU
        Kf3bPr4a60B9eweTYKseNqA3kUELJvQ2dMEe50k=
X-Google-Smtp-Source: AFSGD/V3RiFi6tkguoTq7Gtgbn0LAB4pHN9waK1Aqr14GnqCnjYx+CI6V/WhOQAw9vJ9aAuZkMPmjWOBb1wZTCYUQ8Q=
X-Received: by 2002:a67:3885:: with SMTP id n5mr16328349vsi.96.1546510601445;
 Thu, 03 Jan 2019 02:16:41 -0800 (PST)
MIME-Version: 1.0
References: <20190103061324.16607-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20190103061324.16607-1-trond.myklebust@hammerspace.com>
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Thu, 3 Jan 2019 11:16:29 +0100
Message-ID: <CAMuHMdXpHLjJBMQWDaWKYQFfY4_3yVi9NdBYnWr6Xfzttrb5iA@mail.gmail.com>
Subject: Re: [PATCH v2] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Linux MIPS Mailing List <linux-mips@linux-mips.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On Thu, Jan 3, 2019 at 7:14 AM Trond Myklebust <trondmy@gmail.com> wrote:
> After receiving data into the page cache, we need to call flush_dcache_page()
> for the architectures that define it.
>
> Fixes: 277e4ab7d530b ("SUNRPC: Simplify TCP receive code by switching...")
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> Cc: stable@vger.kernel.org # v4.20

Thanks for your patch!

> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -48,6 +48,7 @@
>  #include <net/udp.h>
>  #include <net/tcp.h>
>  #include <linux/bvec.h>
> +#include <linux/highmem.h>
>  #include <linux/uio.h>
>
>  #include <trace/events/sunrpc.h>
> @@ -380,6 +381,27 @@ xs_read_discard(struct socket *sock, struct msghdr *msg, int flags,
>         return sock_recvmsg(sock, msg, flags);
>  }
>
> +#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
> +static void
> +xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
> +{
> +       struct bvec_iter bi, __start = {

As for_each_bvec() assigns __start to bi, and you don't need __start
afterwards, both variables can be merged into a single one.
But perhaps that would make too many assumptions about the
implementation of for_each_bvec()?

> +               .bi_size = count,
> +       };
> +       struct bio_vec bv;
> +
> +       bvec_iter_advance(bvec, &__start, seek & PAGE_MASK);
> +
> +       for_each_bvec(bv, bvec, bi, __start)
> +               flush_dcache_page(bv.bv_page);
> +}
> +#else
> +static inline void
> +xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
> +{
> +}
> +#endif
> +
>  static ssize_t
>  xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
>                 struct xdr_buf *buf, size_t count, size_t seek, size_t *read)
> @@ -413,6 +435,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
>                                 seek + buf->page_base);
>                 if (ret <= 0)
>                         goto sock_err;
> +               xs_flush_bvec(buf->bvec, ret, seek + buf->page_base);
>                 offset += ret - buf->page_base;
>                 if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
>                         goto out;

I don't understand the code well enough to see why the call to
xs_flush_bvec() is needed in this branch only, but it does fix TCP
NFS on RBTX4927, so
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
