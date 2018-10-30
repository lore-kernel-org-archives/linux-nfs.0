Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E2EC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 21:11:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F19CB20664
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 21:11:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s2v4S9PT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F19CB20664
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726059AbeJaGGR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 02:06:17 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:32796 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725743AbeJaGGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 02:06:16 -0400
Received: by mail-vs1-f68.google.com with SMTP id p74so1690415vsc.0;
        Tue, 30 Oct 2018 14:11:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wcZGifBpw/9IT/+0KZKI+2Y/u2gmMgj1HftzeaUb284=;
        b=s2v4S9PToGjYM7MA9oBWtxjrbhKMoWwf+alNiB0M1RPCbgieDfn1WM6AyewkK+uZAC
         AscqVjY/dt5S61/UryP7p8v835Z9a5zLfRCx4ulptLh3Yki+qTM9pbxqT1Fi/lgIH0Tp
         lr0HDxb7FP8ii1kYklRNpbJ26iPH8j5rO76ESDongQj+jAM4+tf5XHCITg6hNNw/DZfb
         yFqDKtWm4tlWRmDIF4eUJRkbknCUyrq7j5H/AB95yOi18WNyyVusK7w1sHqwst9kur8m
         3HBGp9SvB0VSLBj9VfzCS1R2L2yNjXWoBaO0J8awrVuUoMhTv5bMrak+x/TCALC6epML
         eP0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=wcZGifBpw/9IT/+0KZKI+2Y/u2gmMgj1HftzeaUb284=;
        b=iH98BtaXu+7vsDvx/pa8/2b5jfFGyq/D1UN8zl2OxlPQ5k2/5ungannVg/wuwQsHFa
         1LYmXputi/d4rsyR6PP8HAI+tL11R89HwyODBUUiagzueB+zdUKlOZc8t/bZcv5xMSvS
         ZVCjS/vZcr/uymfz/dO23ek0AcQ3x/O1t2QxF/dRHwtHDe3UkTq3+Y9M/CbXHtdk5CwM
         Yp9a5sPaBFlTUEPdZsXiBUpiE7jxVxhj9nHcIOgu9D11LbqykygxEK9Ohb3LSVGGn0p2
         lClni/QChr0dVA3D/q5iFSxX296MOJJI0Qm0nK4Tp6zEpXU2qtUExDG+O+A6HHlzvyo0
         /rTw==
X-Gm-Message-State: AGRZ1gL4Neq6G32trUHZF2jp1QbmWcKoprScGJ+lVSWlZYRiqmBtxYcB
        I2/2MVvpbsTfnpwJRGEeBjnXNwlj+HKJxC0mvyI=
X-Google-Smtp-Source: AJdET5eTasdlQATTGOTVEiwsgOYBTzzOPE+rMGDfJh2SqBP0crOk6Lcbt5di6b1eeQY48jqDd3kl7MMeUqrqsdm65SI=
X-Received: by 2002:a67:f441:: with SMTP id r1mr182116vsn.164.1540933869742;
 Tue, 30 Oct 2018 14:11:09 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com> <20181027092750.GL6311@dastard>
 <CAN-5tyEeMrRVUyP61Vv-dwFUvm7q55Q3=NVJkeZN+XoCcAOCDQ@mail.gmail.com> <20181030090344.GN6311@dastard>
In-Reply-To: <20181030090344.GN6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 30 Oct 2018 17:10:58 -0400
Message-ID: <CAN-5tyHhTQ8bZk+DUrU0o1ZK3k9uhipiLPeOA3dYuXUG542mNw@mail.gmail.com>
Subject: Re: [PATCH v4 02/11] VFS: copy_file_range check validity of input
 source offset
To:     david@fromorbit.com
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

On Tue, Oct 30, 2018 at 5:03 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Oct 29, 2018 at 10:41:22AM -0400, Olga Kornievskaia wrote:
> > On Sat, Oct 27, 2018 at 5:27 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > >
> > > > Input source offset can't be beyond the end of the file.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > > >  fs/read_write.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > index fb4ffca..b3b304e 100644
> > > > --- a/fs/read_write.c
> > > > +++ b/fs/read_write.c
> > > > @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > > >               }
> > > >       }
> > > >
> > > > +     if (pos_in >= i_size_read(inode_in))
> > > > +             return -EINVAL;
> > > > +
> > >
> > > vfs_copy_file_range seems ot be missing a wide range of checks.
> > > rlimit, s_maxbytes, LFS file sizes, etc. This is a write, so all the
> > > checks in generic_write_checks() apply, right? And the same security
> > > issues like stripping setuid bits, etc? And we need to touch
> > > atime on the source file, too?
> >
> > Yes sound like needed checks.
> >
> > > We've just merged 5 or so patches in 4.19-rc8 and we're ready to
> > > merge another ~30 patch series to fix all the stuff missing from the
> > > clone/dedupe file range operations that make them safe and robust.
> > > It seems like copy_file_range is all the checks it needs, too?
> >
> > Are you proposing to not do this check now in favor of the proper work
> > that will do all of those checks you listed above?
>
> No, I'm saying that if you're adding one check, there's a whole heap
> of checks that still need to be added, *especially* if this is going
> to fall back to page cache copy between superblocks that may have
> different limits and constraints.
>
> There's security issues in this API. They need to be fixed before we
> allow it to do more and potentially expose more problems due to it's
> wider capability.

Before I totally give up on this feature, can you help me understand
your concerns with allowing the generic copy_file_range via
do_splice().

I have mentioned I'm not a VFS expert thus I come from just looking at
the available documentation and the code.

I don't see any restrictions on the files being passed in the
do_splice_direct(). There are no restrictions that they must be from
the same filesystem or file system type. But perhaps this not the
concern you had but more about checking validity of arguments?

I have looked at Dave Wong's, if I'm not mistaken these 2 are the
relevant patches:
[PATCH 02/28] vfs: check file ranges before cloning files
 -- a couple but not all checks apply to copy_file_range() .
specifically, the offsets don't wrap and offset isn't past eof (as my
patch suggests). Other checks have to do with aligned memory which I
don't believe is needed or other dedup requirement that don't apply.

[PATCH 04/28] vfs: strengthen checking of file range inputs to
generic_remap_checks
 -- these checks apply to the code once we fall back to the
do_splice(). it looks to me that perhaps exporting
generic_access_check_limits()/generic_write_check_limits so that they
can be used by the copy_file_range when it get pulled in.

Also, can you elaborate one what "security issues" are present in this
API? Is it "stripping setuid bits" and so something like calling
file_remove_priv() that should be done when the fallback to the
do_splice_direct() happens?

As for the atime, wouldn't the ->copy_file_range() be updating the
file attributes? I guess for the fallback case, the attributes need to
be updated.

If those are checks/issues needed to be addressed and would then get
the generic copy_file_range() in, I could give a go at a patch (or 2).
>
> > I can not volunteer
> > to provide this comprehensive check.
>
> Why not?
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
