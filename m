Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6542DC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:25:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1FAD220657
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WU+XnHQy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FAD220657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726486AbeJ2XOX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 19:14:23 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:33174 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725967AbeJ2XOX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 19:14:23 -0400
Received: by mail-vs1-f67.google.com with SMTP id 125so5359589vsi.0;
        Mon, 29 Oct 2018 07:25:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OlohzHS72viQ7a+8IrEIrYZZMsIhSSGIUNnEv7WG4Gc=;
        b=WU+XnHQy4XBGZI4lbWUvUQ+xp0zR58GIKMzelM++9cx4Rg4yP0OOU2NLSum3HNn+kZ
         7Khr1Y7nyK7x1njbB3mBtBSqXjKM2pd+KtmdkWrv7fPd2csaftD7jCAdF5+mLUziaOKX
         oMCTAtGdiC+5s9JBjb5t6SmzZ4dwsAW8edQCAXX3UKc68s8jQObZHuFopAjB404gvEqq
         cVzT2y08Nftw2v13XmyepoyznG15nxolgtqQwiXWgYjDMaRf0geOsyOal8uuHtvO1MlH
         mevAEIA8buy3MKX06jcZeKblX7DIVqt39NBCPjrqkxXVgrgZVAdX3hL7cANvFOWryWa6
         OwBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=OlohzHS72viQ7a+8IrEIrYZZMsIhSSGIUNnEv7WG4Gc=;
        b=URw6FNtDB0qKhovPAwjej2uNmjNyNY+hNT4yrz35LWEBNu6EltEQTkeoQTU2oNexeh
         GnvjHM1OmzMaFMzHcfKVHX1qyc5+V+r8Nzpi8+iQCPzsQHBF+mQwsuDP5Jr8StZ7Lquk
         cbrpg0X4KD7vv88KDPXUOzR5DJFvqZRcN3Q3/GksVmPfN7RgglsBr13bMS+K6lK6CJ60
         dz1PGA0BAlszIjj9OCjTPkNVIqQYaeasd0bXjfFAhQt7/ZR/UKHboitPRjTyY+x9keT2
         /qSQNOo89rDUJodHmP5IIiDNZHO9pyQHmX7peXSV4ukezoGGf2V+w+bm58nj9cRwfzSU
         8Ckg==
X-Gm-Message-State: AGRZ1gJhdfCIH8JCzbW0aA/OS/s4xWwMAFNLBf4r0pGQCqqPHu6neYMl
        ONVxyZPsY7IiGHUSRRcL4Z36bkBo2EVjDekfvxw=
X-Google-Smtp-Source: AJdET5f+RKD5pXzatWHXHhQuy+rp54CO2HT233wpvFUleak/Lu/4ybUB12iqkr0F1YXz+IudGNT/0nQLUwAKhRTdfx4=
X-Received: by 2002:a67:ca9d:: with SMTP id a29mr6085388vsl.194.1540823130113;
 Mon, 29 Oct 2018 07:25:30 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-3-olga.kornievskaia@gmail.com> <20181027091240.GK6311@dastard>
 <20181027132339.GZ25444@bombadil.infradead.org> <20181028013307.GM6311@dastard>
In-Reply-To: <20181028013307.GM6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 10:25:18 -0400
Message-ID: <CAN-5tyHPT4oYgWJTJg2pMbKoKCoqkf+dow1FXayD+r9gMZnh=Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
To:     david@fromorbit.com
Cc:     willy@infradead.org, trond.myklebust@hammerspace.com,
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

On Sat, Oct 27, 2018 at 9:33 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Sat, Oct 27, 2018 at 06:23:39AM -0700, Matthew Wilcox wrote:
> > On Sat, Oct 27, 2018 at 08:12:40PM +1100, Dave Chinner wrote:
> > > > @@ -131,7 +132,8 @@ There is not enough space on the target filesystem to complete the copy.
> > > >  .B EXDEV
> > > >  The files referred to by
> > > >  .IR file_in " and " file_out
> > > > -are not on the same mounted filesystem.
> > > > +are not on the same mounted filesystem when the kernel does not support
> > > > +cross device file copy.
> > >
> > > Kernel can support cross device file copy, the filesystem may not.
> > >
> > > EXDEV
> > >     One of the files specified by file_in and file_out are on a
> > >     filesystem that does not support cross device copies.
> >
> > I mentioned this in my last review, and Olga pointed out that one of
> > the changes in this patch means the kernel will do the copy using
> > do_splice_direct if the filesystem doesn't support cross-device copying.
> > We should keep this error documented for those on old kernels, but the
> > kernel will never return -EXDEV any more.
>
> Uh, wot? Where's the patch named "VFS: enable copy_file_range() for
> all filesystems"? That shoul dnot be a detail hidden inside some
> other patch that multiple people completely miss during review.

The fact that cross-device check was moved is what allowed for all
filesystems to use copy_file_range(). I think choosing the words of
"moving cross device check" was also appropriate title for the VFS
patch.

To other what you thought was the main change was a side-effect or at
least that's not where the discussion was centered. The discussion was
focused on the fact that there is cross device of same and different
file systems and such discussion deemed appropriate to be noted
clearly in the commit message. The proposed commit message below
doesn't capture it.

I'm fine with the commit message below as well. If that's acceptable
to others. I can change the commit to the wording below.

When I started reading the message I thought your comments where about
the "man-page" patch that it lacked the wording including in the VFS
patch. So to clarify, do you have any objections to the wording in the
man-page patch or was this just about the VFS patch?

> If we are completely changing the kernel's behaviour, the patch
> should be explicitly named to call out the change of behaviour, and
> the commit message should clearly explain the change being made and
> why.
>
> /me goes looking.
>
> Yup, it is only mentione din passing as a side-effect of an
> implementation change. That's back to front. Describe the behaviour
> change, what users will see and the reasons for making the change,
> leave the code to describe exactly what the change is. Then you can
> describe the actions needed to make the new functionality work. e.g.
> The first patch shoul dbe described as:
>
> VFS: generic cross-device copy_file_range() support for all filesystems

> From: ....
>
> In preparation for enabling cross-device offloading of
> copy_file_range() functionality, first enable generic cross-device
> support by allowing copy_file_range() to fall back to a page cache
> based physical data copy. This means the copy_file_range() syscall
> will never fail with EXDEV, and so in future userspace will not need
> to detect or provide a fallback for failed cross-device copies
> anymore.
>
> This requires pushing the cross device support checks down into the
> filesystem ->copy_file_range methods and falling back to the page
> cache copy if they return EXDEV.
>
> Further, clone_file_range() is only supported within a filesystem,
> so we must also check that the files belong to the same superblock
> before calling ->clone_file_range(). If they are on different
> superblocks, skip the attempt to clone the file and instead try to
> copy the file.
>
> S-o-B: .....

>
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
