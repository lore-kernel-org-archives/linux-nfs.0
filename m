Return-Path: <SRS0=+NMN=PZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1C6BC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 17:03:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AC58320856
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 17:03:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JAgulY1e"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728515AbfAQRD2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jan 2019 12:03:28 -0500
Received: from mail-ua1-f65.google.com ([209.85.222.65]:42069 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728767AbfAQRD2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2019 12:03:28 -0500
Received: by mail-ua1-f65.google.com with SMTP id d21so3701669uap.9
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2019 09:03:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BmnOOLm+qPyN4h+EVc+h1Vc3ebUy84r6+LgO1056YY4=;
        b=JAgulY1eE28Sr3DKt2/TwQqxfFdfQnDf0Umda9EIZesAVEZfMP/tMZtx27ip3EET3K
         G3TE1xpiPj0gMO9gohkPlDhp8Xfvb7dFRJpEWvzVFhPL8XgL6ZE0IJjETz3DVAPcCKNt
         3Oj8xdskAz1nSJu0ONJF81VM4oiqlA1J8/tO0uIGBmNmqZmUzhPIgoh2knXLP21Y4pyI
         4EbYEAwuvO+aWRYgbxfyTPcvZOLAbawohYz41wrczcJsQoASEvR7sftGQIyETCDI+GRH
         1IipKr3EU3W9qIi3mBeLAlFnUtpcLOSUmGmYbt+wYDt7rFueqSZri/YVtVvB8U/i5v4x
         2c2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=BmnOOLm+qPyN4h+EVc+h1Vc3ebUy84r6+LgO1056YY4=;
        b=Fm59iIs1Crj6/CAjSrJ677xoEQy3KHgHnb1njXfFBS5drh2dop2ozXiTfv9JFrdT3C
         ww9lAnCfnVZzz1s4VQYVhTQXGLqgogbzFZmzJCSRN5X04uWaR9xwkqgbhbtCozVAY7qX
         uDi++Ti1xCZ++iMRS/A9WJsEt01IV4aZkdfca9XL/yOv0zz3KE+usrqRyLLWKJuo7Ni2
         hoI0yNVOa4wJecekMpnxlfRJ6YnYmfUAsyaJjlARcMBNJ5S3wOc03yCNuGBpapY2nQ0U
         I1AKagunrgi6megasiT48P8eeHeWGgy05lOrYl6pDFNn1w12kkHEJUEzj7dtWV26gmKO
         0rqg==
X-Gm-Message-State: AJcUukdD6Ab28eEbiFVdnnNGtOVNfbs0pKkR7eeBM1NEuWZGSRDSYjmf
        TnZooBznNzFl2r7VNVG58dRhwadYZsh7AAyD/A/tUQ==
X-Google-Smtp-Source: ALg8bN4DI2avOTohCi3eYtP8jSqt57xO/2PVT9/lt1ZppdXagHwyCi4DP9sXlZRe9UQzDHyTexu6Z5xUQjI9d1aZfGU=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr5960552uam.104.1547744606254;
 Thu, 17 Jan 2019 09:03:26 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com>
 <20181221190837.GB15842@parsley.fieldses.org> <CAN-5tyG6o2Zi61j=miGJpR-AmbzvAUm6x4wauzUC9JgQmpma+w@mail.gmail.com>
 <20190116220817.GA4499@parsley.fieldses.org>
In-Reply-To: <20190116220817.GA4499@parsley.fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 17 Jan 2019 12:03:15 -0500
Message-ID: <CAN-5tyHm7XNm4aUhDMEDw3RJDFb2EYOwc=2YsigQrsjmjLLBqg@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] server-side support for "inter" SSC copy
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 16, 2019 at 5:08 PM J. Bruce Fields <bfields@redhat.com> wrote:
>
> On Mon, Jan 14, 2019 at 09:53:10AM -0500, Olga Kornievskaia wrote:
> > On Fri, Dec 21, 2018 at 2:08 PM J. Bruce Fields <bfields@redhat.com> wrote:
> > >
> > > On Thu, Dec 20, 2018 at 01:42:27PM -0500, Olga Kornievskaia wrote:
> > > > On Fri, Nov 30, 2018 at 3:03 PM Olga Kornievskaia
> > > > <olga.kornievskaia@gmail.com> wrote:
> > > > > All the patches (client inter) and this patch series is available
> > > > > from git://linux-nfs.org/projects/aglo/linux.git under the "linux-ssc"
> > > > > branch
> > > > >
> > > >
> > > > Bruce,
> > > >
> > > > Do you have comments on this v2? Once VFS has the patches for the
> > > > generic copy_file_range() functionality, NFS should be all set to just
> > > > used it.
> > >
> > > Not yet, sorry.  I probably won't be able to give it a proper review
> > > till the second week in January, feel free to ping me again then.
> >
> > Any progress on this?
>
> I have some delegation patches I want to get debugged first, hopefully
> just a couple more days.
>
> Where does the VFS cross-superblock copy work stand?  I remember Dave
> Chinner sending some patches but don't see them in 5.0-rc1, on a quick
> look.

I don't know where it stands. Dave didn't reply my asking about it.

>
> --b.
>
> >
> > > --b.
> > >
> > > >
> > > > > Olga Kornievskaia (10):
> > > > >   VFS generic copy_file_range() support
> > > > >   NFS fallback to generic_copy_file_range
> > > > >   NFSD fill-in netloc4 structure
> > > > >   NFSD add ca_source_server<> to COPY
> > > > >   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
> > > > >   NFSD add COPY_NOTIFY operation
> > > > >   NFSD check stateids against copy stateids
> > > > >   NFSD generalize nfsd4_compound_state flag names
> > > > >   NFSD: allow inter server COPY to have a STALE source server fh
> > > > >   NFSD add nfs4 inter ssc to nfsd4_copy
> > > > >
> > > > >  fs/nfs/nfs4file.c    |   9 +-
> > > > >  fs/nfsd/Kconfig      |  10 ++
> > > > >  fs/nfsd/nfs4proc.c   | 406 ++++++++++++++++++++++++++++++++++++++++++++++-----
> > > > >  fs/nfsd/nfs4state.c  | 124 ++++++++++++++--
> > > > >  fs/nfsd/nfs4xdr.c    | 166 ++++++++++++++++++++-
> > > > >  fs/nfsd/nfsd.h       |  32 ++++
> > > > >  fs/nfsd/nfsfh.h      |   5 +-
> > > > >  fs/nfsd/nfssvc.c     |   6 +
> > > > >  fs/nfsd/state.h      |  21 ++-
> > > > >  fs/nfsd/xdr4.h       |  37 ++++-
> > > > >  fs/read_write.c      |  66 +++++++--
> > > > >  include/linux/fs.h   |   7 +
> > > > >  include/linux/nfs4.h |   1 +
> > > > >  mm/filemap.c         |   6 +-
> > > > >  14 files changed, 810 insertions(+), 86 deletions(-)
> > > > >
> > > > > --
> > > > > 1.8.3.1
> > > > >
