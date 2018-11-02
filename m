Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9E77C65C22
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:36:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 711E22081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:36:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mLC8umnm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711E22081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726828AbeKCBn6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 21:43:58 -0400
Received: from mail-ua1-f67.google.com ([209.85.222.67]:38203 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727848AbeKCBn6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 21:43:58 -0400
Received: by mail-ua1-f67.google.com with SMTP id g10so869961uak.5
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 09:36:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PEjgRhYa0ZP6E/Mf7TTn4vRfJP/xTzH9cJZVW5X/NzI=;
        b=mLC8umnm6vQec4jPnE757uYyq6j5dYSdO6BZouq6PN1PMom4XWDmqqaZnm7ugQRd3q
         n2QUV/RBM/ewZUw5o7Ok0X9Kv2WsBSWq6jLf6mg1myOh7e2ODeB2Nzr73k4kTWYVulh9
         ScaK0oHp6sonxYsPmHghNh8K/Q4l55pi1mLH+WbhcXoXG3oNdJarJTrKf3wfFUQPdcYc
         /LL2OZq7m6Nl3Vy7d5QA+zV/l3FdsnCf8LeUoI+aKCw7WyvGBHaBowLKLv+393uHcCLO
         cYoSY+WXR8R1MWSjiQgltQEqTUS+ASJ4z/zV2g2KZ9liyLPV1XjpqQF4cWkGq8ZOwehl
         g3iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=PEjgRhYa0ZP6E/Mf7TTn4vRfJP/xTzH9cJZVW5X/NzI=;
        b=BmRUCCzTR6lUOfOf/PvWkIaBbOD5r9ru96a/hM0zoNpPEZFriTRwVXkDEnUPjGWR/c
         8QppW2yHp7nkPDlIxaNsJz2jAQZ/lAV2wl1sleeWPBi9kl4fZAAgZNJC7HwEbgAhz8ir
         9cZWvVmde2I6/MWG4ORNCXwokaghgJ0a4PyKS/h9j+PWR4e8wfMDtlsVYswEVD0Ah4qK
         vTQ51wyrOFocyRuYbu3BLWBMGrBP+fo/y+HkHDs1DbVtFzO0cL9j5RyXwEuKRebn9EMS
         i0tmpEBj9Jif/vI4qJoAi3gCVNRejNJ+ybat++mBW7daGyY/pNKyHioTeSBQ6afLI175
         uLYg==
X-Gm-Message-State: AGRZ1gJxwWUDt5BLhRLuwNAcaqpJ4gJyGaapjEuzZBrCzKsCE9y0upTh
        IhMj6p61r41Te5EHVDxQIJ+Oxwe+kG2QwkuQhcE=
X-Google-Smtp-Source: AJdET5eD7vuvLlqIjmaAXXWCUZyqwWlsMaZL1kiNgOd+uqLlQAhIW0gfNlh81115oxJNV5TXkXNxRh9AdiynOOqjTjE=
X-Received: by 2002:ab0:918:: with SMTP id w24mr5779459uag.51.1541176574941;
 Fri, 02 Nov 2018 09:36:14 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-8-olga.kornievskaia@gmail.com> <20181102140336.GB19655@fieldses.org>
In-Reply-To: <20181102140336.GB19655@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 2 Nov 2018 12:36:03 -0400
Message-ID: <CAN-5tyFifYcHe5e5PLERBsZxgrbcPjV=DrQu4u=+N16XK2=3wA@mail.gmail.com>
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 2, 2018 at 10:04 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:59AM -0400, Olga Kornievskaia wrote:
> > @@ -1762,8 +1810,24 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
> >       p = xdr_decode_hyper(p, &copy->cp_count);
> >       p++; /* ca_consecutive: we always do consecutive copies */
> >       copy->cp_synchronous = be32_to_cpup(p++);
> > -     tmp = be32_to_cpup(p); /* Source server list not supported */
> > +     count = be32_to_cpup(p++);
> > +
> > +     if (count == 0) /* intra-server copy */
> > +             goto intra;
> >
> > +     /* decode all the supplied server addresses but use first */
> > +     copy->cp_src = kmalloc(count * sizeof(struct nl4_server), GFP_KERNEL);
>
> The client could pass an arbitrarily large count here.  I don't know if
> the ability to force the server to attempt a large kmalloc() is really
> useful to an attacker, but I'd definitely rather not allow it.
>
> Possibly more serious: if that multiplication overflows, then in theory
> it might be possible to make the kmalloc() succeed and allocate too
> little memory, after which the following loop could overwrite memory
> past the end of the allocation.
>
> As long as we're only using the first address, maybe it's simplest just
> not to bother allocating memory for the rest.  Just copy the first one,
> and for the rest call nfsd4_decode_nl4_server() with a dummy struct
> nl4_server.

Ok will try.

>
> --b.
>
> > +     if (copy->cp_src == NULL)
> > +             return nfserrno(-ENOMEM);
> > +
> > +     ns = copy->cp_src;
> > +     for (i = 0; i < count; i++) {
> > +             status = nfsd4_decode_nl4_server(argp, ns);
> > +             if (status)
> > +                     return status;
> > +             ns++;
> > +     }
> > +intra:
> >       DECODE_TAIL;
> >  }
> >
> > @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
> >       p = xdr_reserve_space(&resp->xdr, 4 + 4);
> >       *p++ = xdr_one; /* cr_consecutive */
> >       *p++ = cpu_to_be32(copy->cp_synchronous);
> > +
> > +     /* allocated in nfsd4_decode_copy */
> > +     kfree(copy->cp_src);
> >       return 0;
> >  }
> >
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index feeb6d4..b4d1140 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -521,6 +521,7 @@ struct nfsd4_copy {
> >       u64             cp_src_pos;
> >       u64             cp_dst_pos;
> >       u64             cp_count;
> > +     struct nl4_server *cp_src;
> >
> >       /* both */
> >       bool            cp_synchronous;
> > --
> > 1.8.3.1
