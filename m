Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D7BAC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:57:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 46D7D204FD
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:57:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HLhehdRW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D7D204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727955AbeJ3Cqj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:46:39 -0400
Received: from mail-ua1-f67.google.com ([209.85.222.67]:46861 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726919AbeJ3Cqi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:46:38 -0400
Received: by mail-ua1-f67.google.com with SMTP id z8so3372557uap.13;
        Mon, 29 Oct 2018 10:56:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o8ZGdB3Xc1cDSZGC7sOLE+3utzZVnGDazwW6kv6MSA0=;
        b=HLhehdRWpp2RP/YxzDlAovbrMlgiy+qYd+dk7o/LX42MiN5rf8yHmt+pVSiyXIGJ13
         jmEBnq+S4JB0sTLlarhSXnimTNnkEbLWFPgo/kJfMCfLA8K0eTv7cZk8qvStWZGZKtIa
         BDVdIejL7HKTy6b6gGM3ObsZkiWxHcdzYU1GMGcUWwn8KQXz2srPH94Gl+ivyw8yg+b2
         PYPYwoSiz9AetoaLlgVN1eXziP3xlrPe6oBgxFsd3ynKNVTlXB0AR1M3nlc2OBqfAZvy
         TzNMiEGfRNiaB9RT9SwK8VFQ4Yy5slNflRWEI7rs9wxcp6U4NzBR6KaB9OL11T2dIdvc
         iYrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=o8ZGdB3Xc1cDSZGC7sOLE+3utzZVnGDazwW6kv6MSA0=;
        b=dDah6CcN6Mv60Uog8EvTbA9oksOvc4PYXdlY3ORaXZUhTLsyNnzLlkQhNIlblTTu70
         n8JA3e1SoeXFPNYpcDKFD65NWUkv+xZqI6wZi/2d2diDcFLxxtaDBrKy8ELCwsp1lai+
         a/DI3q55JVZfLrM57eMC0LwZPhVEBCxfIf6ohX7mkOfu4cHZRPIWuVaM1tmEtFWTPzGG
         GXT1aKyp2qbLLxGnVCl1tisyWZl4YwuivYoSPeL7oQHZaCKS6ggOYaHwpArmYelclcGd
         2d1MS3s+xFPEAlgLRFxPV236ykr+hIafX4GYUk5si5/RAS3zL16a2DnpP92Csyymfrr/
         wp9g==
X-Gm-Message-State: AGRZ1gKvZz2FDs2bwDxBq3szEXcpHy74y0CkmRZH/JKpK7IK5vUElMHR
        Nd6LKsx3iawqyE3QbBkcWjV8spbe/5RUHul9DZo=
X-Google-Smtp-Source: AJdET5dOdmZhlDFa4dmTPLPUELyoFokreW9OUrU8tNO/zGcdhMOMljWwMO01E1sazrfAimpZytP6HU6sl1XAuuKqu4U=
X-Received: by 2002:a9f:3250:: with SMTP id y16mr6479601uad.120.1540835817615;
 Mon, 29 Oct 2018 10:56:57 -0700 (PDT)
MIME-Version: 1.0
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
 <20181029174059.38326-14-olga.kornievskaia@gmail.com> <20181029175114.GJ28520@bombadil.infradead.org>
 <20181029175239.GK28520@bombadil.infradead.org>
In-Reply-To: <20181029175239.GK28520@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 13:56:46 -0400
Message-ID: <CAN-5tyF+TGjYw3S1VkBUfNFyJgQrdT8DCnE6T0Puh=LbqX5nhA@mail.gmail.com>
Subject: Re: [PATCH v5 12/12] NFS: replace cross device check in copy_file_range
To:     willy@infradead.org
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 29, 2018 at 1:52 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Oct 29, 2018 at 10:51:14AM -0700, Matthew Wilcox wrote:
> > On Mon, Oct 29, 2018 at 01:40:59PM -0400, Olga Kornievskaia wrote:
> > > +   c_in = (NFS_SERVER(file_inode(file_in)))->nfs_client;
> >
> > Seems to be an unnecessary pair of brackets there, given existing code:
> >
> > fs/nfs/delegation.c:    struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
> > fs/nfs/dir.c:                                     NFS_SERVER(inode)->dtsize, desc->plus);
> > fs/nfs/file.c:  if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL)
> > (etc)
> >
> > > +   if (c_in->cl_minorversion < 2)
> >
> > in fact, can't you make this even simpler ...
> >
> >       if (NFS_SERVER(inode)->nfs_client->cl_minorversion < 2)
>
> Oops.  Typed too fast:
>
>         if (NFS_SERVER(file_inode(file_in)))->nfs_client->cl_minorversion < 2)
>
> > I thought you needed to cast it, but code like this:
> >
> > fs/nfs/nfs4proc.c: NFS_SERVER(dir)->nfs_client->cl_hostname);
> >
> > would indicate not.

You are right. Then no declaration is needed. I'll change it. Thank you.
