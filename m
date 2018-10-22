Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F552C004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 17:48:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 56F7420652
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 17:48:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V4Ss3D7B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56F7420652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728030AbeJWCID (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 22:08:03 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:41306 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727590AbeJWCID (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 22:08:03 -0400
Received: by mail-vs1-f68.google.com with SMTP id w1so30158642vsj.8
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 10:48:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iZF93aJraJ8Sp0N7Rr6C/r4v9egm0F4dZ84pQ9aj4xE=;
        b=V4Ss3D7BMsH9l7Dvrs6GKmQQ9SVzTgqOnTajgSabbqZf8n+V5jorglMw28H6XN3FxA
         3Gqz8YObEX7eoIJVkMrjXlQ/EJG4CFb5Ush8il8nG448rl88D/f0kWYYN6d2UsyjmAJ2
         z6dOHS/yOhd4G0aLeVNNMtSaEm9UGc/V7HbrD5kkGwaPH3nsGiYVfhUMB1a1QEP0PrKN
         gNEmZY06c4keCpzoRtf5zgCMapPUGY8nua+fet2Scngc3lfdjndICAiZNtiV4RA+u4e1
         4po5OVzo2v7LuGSpnRtIc65SSjd92KE7UJ7ooe69XAEvj3FzmU5tPr+xkH3jc/rsnfi9
         QjOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=iZF93aJraJ8Sp0N7Rr6C/r4v9egm0F4dZ84pQ9aj4xE=;
        b=G4JavI+bI6RwVc2qV9PNWw0W5wbAORQao41PQq2eCbMP5RVrsWlFnvv/QN/uoutzny
         JwREU68rQNkKr551P2sphE/beIJvOrFwaifP4udhOD0WFu7JxgCu/cPWM+pxtNgUfDW9
         uDKuGS8sbIDP6VkygMD0x6FRXjdF8CuE2IcQTZEbPmmagskLScQkkI2F+bR0AsUOYt76
         C61jwWUBluuI9MYFoRIEp+wIMRYe4dxjk4zCN9wIceHGZZO2WcvquoEQwTdb6jeP/3ro
         gevg8RWN0ck94xOozXJ/Df51DeL8njs18zXaI2YPUjIp8mPzDjy6N4SPfazOSboJpE4E
         09Cw==
X-Gm-Message-State: ABuFfoitO4jv02qVHpyEzj8EYeGWg9B7KXQKwsF6f9PO4RLj2T3umGIx
        vHuU8NgZ7FUtvY/u8h4Z80u9NLoCi5rwr+08Z/Q=
X-Google-Smtp-Source: ACcGV63a7YOa6i1CDjv5ArIEhXMA3A1fXfnTou0K9d2f+o0IC9H2kT+h9BxRFq7zKCKUX6CaHU4MZE1dRxbHLG9h6N8=
X-Received: by 2002:a67:ca81:: with SMTP id a1mr19511809vsl.194.1540230513351;
 Mon, 22 Oct 2018 10:48:33 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-4-olga.kornievskaia@gmail.com> <4e5c759108926983cdbbdedf24995db84779ef2e.camel@kernel.org>
In-Reply-To: <4e5c759108926983cdbbdedf24995db84779ef2e.camel@kernel.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 22 Oct 2018 13:48:20 -0400
Message-ID: <CAN-5tyH7qmW_W3PvenFHic867AY=Z887eh95YgSjxtH2Ofj-NA@mail.gmail.com>
Subject: Re: [PATCH v1 03/11] NFS test for intra vs inter COPY
To:     jlayton@kernel.org
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Oct 21, 2018 at 10:44 AM Jeff Layton <jlayton@kernel.org> wrote:
>
> On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs42.h | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> >
> > diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> > index 19ec38f8..5abff4d 100644
> > --- a/fs/nfs/nfs42.h
> > +++ b/fs/nfs/nfs42.h
> > @@ -6,6 +6,7 @@
> >  #ifndef __LINUX_FS_NFS_NFS4_2_H
> >  #define __LINUX_FS_NFS_NFS4_2_H
> >
> > +#include <linux/sunrpc/addr.h>
> >  /*
> >   * FIXME:  four LAYOUTSTATS calls per compound at most! Do we need to support
> >   * more? Need to consider not to pre-alloc too much for a compound.
> > @@ -21,4 +22,14 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
> >                                  struct nfs42_layoutstat_data *);
> >  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
> >
> > +static inline bool nfs42_files_from_same_server(struct file *in,
> > +                                             struct file *out)
> > +{
> > +     struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
> > +     struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
> > +
> > +     return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
> > +                             (struct sockaddr *)&c_out->cl_addr);
> > +}
> > +
> >  #endif /* __LINUX_FS_NFS_NFS4_2_H */
>
> What about trunking? If the addresses don't match, should you compare
> cl_serverowner or something too? Or maybe just do that instead of
> testing addresses?
>
> It's usually best to add infrastructure like this in the same patch with
> an initial caller so we can see how it's intended to be used.

Thanks, I will change it to use nfs4_check_serverowner_major_id()
instead and merge it with one of the callers.

> --
> Jeff Layton <jlayton@kernel.org>
>
