Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A75EC2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:41:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 229CA2082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:41:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cvXYE2ZS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 229CA2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726720AbeJ2Xab (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 19:30:31 -0400
Received: from mail-ua1-f66.google.com ([209.85.222.66]:36309 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726066AbeJ2Xaa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 19:30:30 -0400
Received: by mail-ua1-f66.google.com with SMTP id w19so3098582uaj.3;
        Mon, 29 Oct 2018 07:41:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7uvR9IxiZlzCAc322bVTmAH0o38WHMZL8t6blMCHeqU=;
        b=cvXYE2ZSqDu7pp6WJdygIEP5TuPNR4MqZ4BRy8+LZjk/FPEmzWsH3T/mi/yIkmE14K
         8+nPSkf8k4/OMSAPQk8RYQV/cYleaAW1WPhr1jMQMBeERifq3dmR8iwgZPzfJvZCRhX6
         e4P+dxbIo4C8/eKh3J7vkiE+mVTsL+bfdcW/yvGNlSQIm8SA/DE6o+YIX/cKqRfPkI8I
         dNidlPS/oMpQiUR8n8wpWeaa2KwFFBr0GYL2zq2rqYnPdBc2pHx98BfrON/tVOTy7BOQ
         Gj2kWlFqA9/Hxvdc9FX9hrm1p4Pn1B/Wo2LHTxk8683C4PSbCMoL4DI+G2M4NsPSDDGz
         nneQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7uvR9IxiZlzCAc322bVTmAH0o38WHMZL8t6blMCHeqU=;
        b=Blvvzu8lSpTQhoKTX4fVReMIZ1u0MrwZGHK1yCUT/u6Kma9XpPhRNuD8ekcz2KOHIg
         Iu/RlFXKT2vujJApU86QmGSn/tBFAKo0DWXs1MpEFbkgRDiOXe23VtLGFH2nsLKyghE0
         Azt348X/5XILEcsRa/taZ5FwQltX07tz9HMtmgNIB3wigNIfc/zKOfhoatLIheg4aPwV
         pH4HssLt+71HWIJtcONWcD/U1xNZ54ceu3+xeAKDb4BkW5zqFnN+8akoNElyG9JgZFAs
         1wRYFqLCrJuIKgVodplO5grK41n9QWM4pnjC2heb89GdGidm2NFdgxLlicFqQX+F8Sjc
         JhTg==
X-Gm-Message-State: AGRZ1gJrVxp+mJdlqCQeQbdI5oPK+Vura0ni8CsgGNQXEUJvALmggzvt
        GR+KDtnZh26nwZrZIXRw/zVezwjUtkjoSkjW9lo=
X-Google-Smtp-Source: AJdET5dj/M5re75kHuKkl5FlvFqPuh5OjEEeXrwMQ6xwNefw5P0nnWgbZ9mI08GrJBGk9o/dkdvPo8DTvelYzHcnwJ8=
X-Received: by 2002:a9f:3250:: with SMTP id y16mr6120505uad.120.1540824093486;
 Mon, 29 Oct 2018 07:41:33 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com> <20181027092750.GL6311@dastard>
In-Reply-To: <20181027092750.GL6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 10:41:22 -0400
Message-ID: <CAN-5tyEeMrRVUyP61Vv-dwFUvm7q55Q3=NVJkeZN+XoCcAOCDQ@mail.gmail.com>
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

On Sat, Oct 27, 2018 at 5:27 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Input source offset can't be beyond the end of the file.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/read_write.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index fb4ffca..b3b304e 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >               }
> >       }
> >
> > +     if (pos_in >= i_size_read(inode_in))
> > +             return -EINVAL;
> > +
>
> vfs_copy_file_range seems ot be missing a wide range of checks.
> rlimit, s_maxbytes, LFS file sizes, etc. This is a write, so all the
> checks in generic_write_checks() apply, right? And the same security
> issues like stripping setuid bits, etc? And we need to touch
> atime on the source file, too?

Yes sound like needed checks.

> We've just merged 5 or so patches in 4.19-rc8 and we're ready to
> merge another ~30 patch series to fix all the stuff missing from the
> clone/dedupe file range operations that make them safe and robust.
> It seems like copy_file_range is all the checks it needs, too?

Are you proposing to not do this check now in favor of the proper work
that will do all of those checks you listed above? I can not volunteer
to provide this comprehensive check. However if this is the path
community decides is the best then I can move this check into NFS for
now and remove it once VFS provides such check later.

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
