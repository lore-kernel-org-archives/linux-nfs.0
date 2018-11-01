Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F20C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:55:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB39520657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:55:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jrMEzgE2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB39520657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726259AbeKBGAN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 02:00:13 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:43192 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725963AbeKBGAM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 02:00:12 -0400
Received: by mail-vs1-f65.google.com with SMTP id k14so12991403vsm.10
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 13:55:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DszOXWL9LILCpGndlzhMw+lCzdMsX0M47kR6lz6Zu6Y=;
        b=jrMEzgE22EPX70qIypJWzLPSjBC678dOP9QJdWQFaQbgz4yZ1KXUQmzMOqHSjal/PT
         GbHWQ70sEbepg6oTATIehaI7/r6pg4fokWeFeGt78HCFmW+8KyWHf1rRg7Rw0vqKhfB1
         DNVa9ZQ4/Eroa7X4bMFt1TeL2QkhqglSgLVJu1wdzJ5Ni52BbhuVaeoGZeQOEcS5m6oW
         VGKN7PSWvBGjsanjwaCo/IhJIc9DunZS1Wg29Zm/F+GbP+l0z12W8kgEl2r8HlKVGPuL
         aAUEYgCHqHYGtKPcUH/eRSYwITAGiwWxqzb15NE1Lb2EZCJpgaQe8VxlYRq2KzebgpPY
         g9mA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DszOXWL9LILCpGndlzhMw+lCzdMsX0M47kR6lz6Zu6Y=;
        b=Q7uFxLklrhzSI4RKdvPeUHu64DoJ+5eAG938E/Q/A+3lglyWLa6LCfpf0i/tHWOX6j
         W8GmKPUFIEew/slvQx77OQtHSaQhx1in5B2Bb4WJAnBHYI3ex/OyJ+mZOrJ94p4WmZWZ
         2TvHjk6iHI7yrl2zcJokR2tsINQfoM/pXPc3ZWvDWDyzDeB9bCDf9qnJUlK5vhiJtTyF
         x5k+6DkcMfBeIbykYAyAkRZ6vzaQpUofqJlgkmS21FL0Q0A487TbxEALj9lDJHnhrSrw
         AbGxIaTP2GmjUdbMG3tDMz6lyiEVCu88nHMYEedbM/FvkfPL/2qHRwh6v28SGjDl/lgF
         oL7A==
X-Gm-Message-State: AGRZ1gKVUHjYrP05M7XgV2x37drfEHjzTz0y6vqnF9tGdnGt9GBfJUaF
        XUv1gSkxDFCFrT3+BzR4ijK15EuFkqfKAF+fZVUrvg==
X-Google-Smtp-Source: AJdET5cZ0CfFdonVKS1ggxoWG8g4k4U9GXJoq0x5TXEWVIWtB/QpCdfaMjUvRMiKfq5HsEcroRIUCXGF7KcEkAYwAow=
X-Received: by 2002:a67:f441:: with SMTP id r1mr3965438vsn.164.1541105736330;
 Thu, 01 Nov 2018 13:55:36 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-7-olga.kornievskaia@gmail.com> <20181101203727.GC12930@fieldses.org>
In-Reply-To: <20181101203727.GC12930@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 1 Nov 2018 16:55:24 -0400
Message-ID: <CAN-5tyEbjhKLH5yp8gTvJn9Ua0Vrq5Eep6kRuUgX7S2MDjO-Fw@mail.gmail.com>
Subject: Re: [PATCH v1 06/13] NFSD fill-in netloc4 structure
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 1, 2018 at 4:37 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:58AM -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > nfs.4 defines nfs42_netaddr structure that represents netloc4.
> >
> > Populate needed fields from the sockaddr structure.
> >
> > This will be used by flexfiles and 4.2 inter copy
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfsd/nfsd.h | 31 ++++++++++++++++++++++++++++++-
> >  1 file changed, 30 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> > index 0668999..030fccb 100644
> > --- a/fs/nfsd/nfsd.h
> > +++ b/fs/nfsd/nfsd.h
> > @@ -18,7 +18,7 @@
> >  #include <linux/nfs4.h>
> >  #include <linux/sunrpc/svc.h>
> >  #include <linux/sunrpc/msg_prot.h>
> > -
> > +#include <linux/sunrpc/addr.h>
> >  #include <uapi/linux/nfsd/debug.h>
> >
> >  #include "stats.h"
> > @@ -366,6 +366,35 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
> >
> >  extern const u32 nfsd_suppattrs[3][3];
> >
> > +static inline u32 nfsd4_set_netaddr(struct sockaddr *addr, struct nfs42_netaddr *netaddr)
> > +{
> > +     struct sockaddr_in *sin = (struct sockaddr_in *)addr;
> > +     struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
> > +     unsigned int port;
> > +     size_t ret;
> > +
> > +     switch (addr->sa_family) {
> > +     case AF_INET:
> > +             port = ntohs(sin->sin_port);
> > +             sprintf(netaddr->netid, "tcp");
> > +             netaddr->netid_len = 3;
> > +             break;
> > +     case AF_INET6:
> > +             port = ntohs(sin6->sin6_port);
> > +             sprintf(netaddr->netid, "tcp6");
> > +             netaddr->netid_len = 4;
> > +             break;
> > +     default:
> > +             return nfserrno(-EINVAL);
>
> Let's just write that nfserr_inval;

Ok will do.

>
> > +     }
> > +     ret = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
> > +     netaddr->addr_len = ret + snprintf(netaddr->addr + ret,
> > +                                  RPCBIND_MAXUADDRLEN + 1,
> > +                                  ".%u.%u", port >> 8, port & 0xff);
>
> Isn't the remaining space RPCBIND_MAXUADDRLEN + 1 - ret ?

You are right.

> But really I think we're depending on RPCBIND_MAXUADDRLEN being large
> enough that there will never be overlow, in which case we may as well
> just use sprintf.
>
> And maybe add a WARN_ON() in case of overflow, if we want to be
> paranoid about it.

Are you proposing to first get the output from snprintf() and see if
there was an overflow because it returned more than the supplied size
and then print WARN_ON()? How do I detect an overflow with just a
sprintf()?

>
> --b.
>
> > +
> > +     return 0;
> > +}
> > +
> >  static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
> >  {
> >       return !((bm1[0] & ~bm2[0]) ||
> > --
> > 1.8.3.1
