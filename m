Return-Path: <SRS0=O3Iw=PW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1728C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Jan 2019 14:53:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8CE3E2086D
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Jan 2019 14:53:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WrOBX+il"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726751AbfANOxW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Jan 2019 09:53:22 -0500
Received: from mail-ua1-f68.google.com ([209.85.222.68]:35250 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726542AbfANOxW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2019 09:53:22 -0500
Received: by mail-ua1-f68.google.com with SMTP id d2so7152885ual.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2019 06:53:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=argvRVf0sFruai4o7rPyeGb95MRpnXRphZIjHXyJH5A=;
        b=WrOBX+ilZTUvh70/+62FwOEa6GaRj/db5eNZDNp33624EEDYMizgcebGUfCjSMIoID
         xm74MTaj8ABQqJFbrL2X7yrXWX9jV8jhBRtkLGQSYhmBIeX1z91dbmy4Se6N5skwPLAu
         YHj9/KS+XbGYIDP++8hS6snQ/RKygfJfLXvnI5vjGIvlFd01heto7T+DfcqKgkU5XPd4
         hQvtxX4RMkjdxW8EK3mu2uxkQ/pcDlJ6lOhEfpkjNVxRaEiKxNkXi061HEqkRvfwlYyy
         6/vKPR4rFrKHUtPdq6NgnDpVsIHO1nzIAeUwxpqMjOMR+oJADYgLnKKPd0iB//lFR/IH
         XOzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=argvRVf0sFruai4o7rPyeGb95MRpnXRphZIjHXyJH5A=;
        b=drvrSsKbBzKbW5sf9qUewuiGYSH8AJ/TfLdOtzaUVLxZNiLNSkYCYwvnKVHHlYvRD+
         3Rl0EAQ5hnG164OxdsNnEGcUs9xbJjE/oyCUZ6gV/qd8bIQqaRv1Z4GHnPB0l7/DzJVJ
         Magd8erp4ajp2sq8rNAzpcAdW3n5MrjZqDsZjtfPOkVUXZgaXvaZv0bXNZQL5Eg2xcPP
         T9PRe1qe20q28LKCGGSn+SjYP+qpA9D3PG3J0AtfQwptEeHR+lr5PCshB6uMcb7IqXq0
         ncnemQgfaUUwklmYLl2vtmd9ujKGoees05ovoybNmuMbN0dZUJIAoLKBiaJO7kBCF0cY
         BohQ==
X-Gm-Message-State: AJcUukf7uulAVnSxn9zDXB28ZA+NZNRTKklKqPvCgQfst4TjE+hQQ7nm
        E8LZOyFVEtqKgUVR71ov7Ox8nTZykaARiZy7OMQk9A==
X-Google-Smtp-Source: ALg8bN68hgScefObrveRsveksyk9cyB/74S0Uk0ZdBdKKrMMMnt5PCO9ZtWzazjP7OsxcjTOdkVOVZPWdDybrKmDAQE=
X-Received: by 2002:ab0:2017:: with SMTP id v23mr9445831uak.5.1547477601617;
 Mon, 14 Jan 2019 06:53:21 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com> <20181221190837.GB15842@parsley.fieldses.org>
In-Reply-To: <20181221190837.GB15842@parsley.fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 14 Jan 2019 09:53:10 -0500
Message-ID: <CAN-5tyG6o2Zi61j=miGJpR-AmbzvAUm6x4wauzUC9JgQmpma+w@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] server-side support for "inter" SSC copy
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Dec 21, 2018 at 2:08 PM J. Bruce Fields <bfields@redhat.com> wrote:
>
> On Thu, Dec 20, 2018 at 01:42:27PM -0500, Olga Kornievskaia wrote:
> > On Fri, Nov 30, 2018 at 3:03 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > > All the patches (client inter) and this patch series is available
> > > from git://linux-nfs.org/projects/aglo/linux.git under the "linux-ssc"
> > > branch
> > >
> >
> > Bruce,
> >
> > Do you have comments on this v2? Once VFS has the patches for the
> > generic copy_file_range() functionality, NFS should be all set to just
> > used it.
>
> Not yet, sorry.  I probably won't be able to give it a proper review
> till the second week in January, feel free to ping me again then.
>

Hi Bruce,

Any progress on this?

> --b.
>
> >
> > > Olga Kornievskaia (10):
> > >   VFS generic copy_file_range() support
> > >   NFS fallback to generic_copy_file_range
> > >   NFSD fill-in netloc4 structure
> > >   NFSD add ca_source_server<> to COPY
> > >   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
> > >   NFSD add COPY_NOTIFY operation
> > >   NFSD check stateids against copy stateids
> > >   NFSD generalize nfsd4_compound_state flag names
> > >   NFSD: allow inter server COPY to have a STALE source server fh
> > >   NFSD add nfs4 inter ssc to nfsd4_copy
> > >
> > >  fs/nfs/nfs4file.c    |   9 +-
> > >  fs/nfsd/Kconfig      |  10 ++
> > >  fs/nfsd/nfs4proc.c   | 406 ++++++++++++++++++++++++++++++++++++++++++++++-----
> > >  fs/nfsd/nfs4state.c  | 124 ++++++++++++++--
> > >  fs/nfsd/nfs4xdr.c    | 166 ++++++++++++++++++++-
> > >  fs/nfsd/nfsd.h       |  32 ++++
> > >  fs/nfsd/nfsfh.h      |   5 +-
> > >  fs/nfsd/nfssvc.c     |   6 +
> > >  fs/nfsd/state.h      |  21 ++-
> > >  fs/nfsd/xdr4.h       |  37 ++++-
> > >  fs/read_write.c      |  66 +++++++--
> > >  include/linux/fs.h   |   7 +
> > >  include/linux/nfs4.h |   1 +
> > >  mm/filemap.c         |   6 +-
> > >  14 files changed, 810 insertions(+), 86 deletions(-)
> > >
> > > --
> > > 1.8.3.1
> > >
