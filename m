Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF1AC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:49:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFC802080A
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:49:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZbunElN3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFC802080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727787AbeJ3Cjf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:39:35 -0400
Received: from mail-yb1-f195.google.com ([209.85.219.195]:46357 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726205AbeJ3Cjf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:39:35 -0400
Received: by mail-yb1-f195.google.com with SMTP id f15-v6so3318072ybq.13;
        Mon, 29 Oct 2018 10:49:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mF5WKZE+AEPndDjrWcVQbOKMNjDBr6DZWGkdyesGcBM=;
        b=ZbunElN3VwhcI0JT9HNXFBvgsr/8DQFAAvWmKrECNpCDLapcETdf01SXzqtskcbEx5
         Tm88tYxix2miXptwbFmJid2sWL5zDOQMR3SAxo5auHTpn6TuyA3do0WSPvWP5ZM2P7rA
         daVfpKBeey/qVgyFNS72kcCbd/XlCoM32EmYHzDMuO77KlWKeodbykttewsnuQxdc/H3
         TMKYPo3NXzWqeAjbqfbYAs2iw5Onj5/nZGiukU+DSBkw9dF0KxGljGWQbsN+8vMmBKWF
         0Gg0vNWx81yvhixrqGFfVgxbxEtCB0dFhpiPSNC7+HSecGIUTf9eN+hhKHDvIxIv5mOs
         G35A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mF5WKZE+AEPndDjrWcVQbOKMNjDBr6DZWGkdyesGcBM=;
        b=pfQ2H3e0T8XLWpi+5O0uU0aqMUU9fncOVIYhj2ArafcXbyo3mRWbRWYwRPVBcGFlQ3
         Bgfcy0WTA7Ap3Gb4R+eDPsHIZrbzgKAl+A6Wp0Sv3IIDXvyyy+jG5bH9hmrnkTtZ7B1W
         pmMLprUUF1KaLRvQtXgJObfY4aufDGlinK/3mPTZmBlB2YL5/hZji2bP8IaePjQCN37F
         1sC7IpfyoKYTs+zfplUTmIDGocOPYs9THQwE4rXqDPca3nxJrP1Qoqe/UXux9z3vLRCa
         jraX5UzthLUgitl6zCMBV1gcGqaOoDBE9C3i/JQnba5w4Fz3GvRi980gKX4inKJNNvcK
         PuaQ==
X-Gm-Message-State: AGRZ1gKwtQJpUAX1XxCE465wkV1k5K1aY/4HHwp1v51RO77O+YyE5AmR
        wd0cH0X/mL2QZdtpGtzJWGcUQzIic9ZOQjHJ+Nc=
X-Google-Smtp-Source: AJdET5fEUpdntiTc5EMOGrPp8RsBcCsYIEe4d+QrUIHHf5W37mqTdkQdV0qsunSNQORVaYBYBCe0zBq3RTaqHFLH2sg=
X-Received: by 2002:a25:fc0d:: with SMTP id v13-v6mr15177461ybd.320.1540835395598;
 Mon, 29 Oct 2018 10:49:55 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-3-olga.kornievskaia@gmail.com> <20181027091240.GK6311@dastard>
 <20181027132339.GZ25444@bombadil.infradead.org> <20181028013307.GM6311@dastard>
 <CAN-5tyHPT4oYgWJTJg2pMbKoKCoqkf+dow1FXayD+r9gMZnh=Q@mail.gmail.com> <CAN-5tyEGoDma_mn3srk8pKR65Aq4EGWgmNU4oRML_aA9Enk72Q@mail.gmail.com>
In-Reply-To: <CAN-5tyEGoDma_mn3srk8pKR65Aq4EGWgmNU4oRML_aA9Enk72Q@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 29 Oct 2018 19:49:43 +0200
Message-ID: <CAOQ4uxiWWzAB1M5EVK6+a+ncPKMk2q-LZr-m3snPQyV+rfOwDg@mail.gmail.com>
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        Matthew Wilcox <willy@infradead.org>,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        overlayfs <linux-unionfs@vger.kernel.org>,
        linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 29, 2018 at 5:52 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Mon, Oct 29, 2018 at 10:25 AM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > On Sat, Oct 27, 2018 at 9:33 PM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Sat, Oct 27, 2018 at 06:23:39AM -0700, Matthew Wilcox wrote:
> > > > On Sat, Oct 27, 2018 at 08:12:40PM +1100, Dave Chinner wrote:
> > > > > > @@ -131,7 +132,8 @@ There is not enough space on the target filesystem to complete the copy.
> > > > > >  .B EXDEV
> > > > > >  The files referred to by
> > > > > >  .IR file_in " and " file_out
> > > > > > -are not on the same mounted filesystem.
> > > > > > +are not on the same mounted filesystem when the kernel does not support
> > > > > > +cross device file copy.
> > > > >
> > > > > Kernel can support cross device file copy, the filesystem may not.
> > > > >
> > > > > EXDEV
> > > > >     One of the files specified by file_in and file_out are on a
> > > > >     filesystem that does not support cross device copies.
> > > >
> > > > I mentioned this in my last review, and Olga pointed out that one of
> > > > the changes in this patch means the kernel will do the copy using
> > > > do_splice_direct if the filesystem doesn't support cross-device copying.
> > > > We should keep this error documented for those on old kernels, but the
> > > > kernel will never return -EXDEV any more.
> > >
> > > Uh, wot? Where's the patch named "VFS: enable copy_file_range() for
> > > all filesystems"? That shoul dnot be a detail hidden inside some
> > > other patch that multiple people completely miss during review.
> >
> > The fact that cross-device check was moved is what allowed for all
> > filesystems to use copy_file_range(). I think choosing the words of
> > "moving cross device check" was also appropriate title for the VFS
> > patch.
>
> I wasn't completely correct. It was the check removal and then also
> allowing for -EXDEV error to keep going with the  do_splice_direct().
> I could have left EXDEV being an error but thought it would be
> beneficial to add such ability. One reason to keep all the changes in
> one patch was said to be so that porting back all of this
> functionality is included.
>

Olga,

There are many details in this patch series and repeated miscommunications
about the details. Accuracy is important - "the reason to keep all changes" -
that was a commetn of mine referring *only* to the move of same sb check
from VFS to different filesystems.

The *extra* change of do_splice_direct cross fs was a very nice low
hanging fruit, but completely unrelated to your original  motivation.
I completely agree with Dave that it should be in a separate patch.
I also side with Dave that it would make sense as the first patch of the series.

> So one option would be keep EXDEV as an error if that's what folks
> want then this side-effect would not be a problem and the focus would
> be on what it was in the first place : removal (or relocation) of the
> cross device check into the filesystems.
>

This is up to you. It's an extra change and not related to your NFS work
and you may submit it or not. I think it will be nice if you did submit it.
There was no objection to this change, only objection was to bundle it together
with a different unrelated patch.

Thanks,
Amir.
