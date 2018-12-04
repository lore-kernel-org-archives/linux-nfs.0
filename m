Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C03D5C04EBF
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 21:47:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 83E6D20850
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 21:47:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iWgi0zs7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83E6D20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726333AbeLDVrc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 16:47:32 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:42338 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725875AbeLDVrc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 16:47:32 -0500
Received: by mail-vs1-f66.google.com with SMTP id b74so10790720vsd.9;
        Tue, 04 Dec 2018 13:47:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ed41OLyGaB3hr4EoFGI15KQggEx+tY9zRtIsMSc7Nqk=;
        b=iWgi0zs7QeWvfBi7rb6UOV7svQaMRvIew8C8Isr78WH/g1t1ZP43p1khRkFDPegjX8
         Z8l6eIat/zzANPzqkpxvFRNiszmny+vIvbgFYjmUo0qn04AQIfDYam17hLQIrtBBTMcb
         u2IrIekeaqxrXTqQ+Z49Qug8zpzffamEtQOThKxpDZO9NCf4XUBVg4avlP1yn2lK3d4D
         xKwSjlX/Hz8ci/Qi5GHcbPotE2sb8JxliiAnvTrPhOkdG+VEkO73KlEA8tWH6+PpFdLa
         gk4AOfwD1nOda7McfL9Yso6AP+wk4EoQPRRKAaFc7+7HF9Kx/ee08MKEztx2v+RnWARb
         02xg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ed41OLyGaB3hr4EoFGI15KQggEx+tY9zRtIsMSc7Nqk=;
        b=OLyEUl1/t/3S6M/QP7H4kK8uUVlWVJxxbSy6BNouyLTleG+DoJaE2F3+64ecyf45nM
         lTKrRDq7PdRgR9aotuGQpIU00XcKuIbXlrGMFXVQYg2WDqKOUMOZBANn915otDS5BorO
         yAv0KReyie7CQO+kyHE2aWZfBBz3ms+p1oGS/RGb1sJtrGdJ8/WNcbfi3mTzFiK1SyDb
         rZlOIObVU/j28VkUGvF9qpySGpodghGMf60hPXvU77RZ3J7smQFvG9JlqcYfHsf8lfOc
         tfaQO+KYTHcc8hK8ECJbKD/VVfAZekwRGeKeCNKaylXDVI2qZObMFBzZqVjAFDb2CDI1
         ClbA==
X-Gm-Message-State: AA+aEWZt0dOvvBLfUanHsl32hwHx/6TJMrt/KnFd78PXRzBB39SdTNmS
        N+2I4Wh/T/GO9xbFoHFsp4eYUKAEPZwqNo5sHPM=
X-Google-Smtp-Source: AFSGD/Xa/t0Rj/kef1ALS5oHlqdBkNc5RhB3hDwtBi8hQMrhTF9xLz3z5Ww0+DsyBYfbXxLvrZ39AybW0N81m3lMAGE=
X-Received: by 2002:a67:a858:: with SMTP id r85mr9390819vse.215.1543960050045;
 Tue, 04 Dec 2018 13:47:30 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-2-david@fromorbit.com>
 <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
 <20181204151332.GA32245@infradead.org> <20181204212948.GO6311@dastard>
In-Reply-To: <20181204212948.GO6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 4 Dec 2018 16:47:18 -0500
Message-ID: <CAN-5tyGU=y5JO5UNcmn3rX1gRyK_UxjQvQ+kCsP34_NT2-mQ_A@mail.gmail.com>
Subject: Re: [PATCH 01/11] vfs: copy_file_range source range over EOF should fail
To:     david@fromorbit.com
Cc:     Christoph Hellwig <hch@infradead.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 4, 2018 at 4:35 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Dec 04, 2018 at 07:13:32AM -0800, Christoph Hellwig wrote:
> > On Mon, Dec 03, 2018 at 02:46:20PM +0200, Amir Goldstein wrote:
> > > > From: Dave Chinner <dchinner@redhat.com>
> > > >
> > > > The man page says:
> > > >
> > > > EINVAL Requested range extends beyond the end of the source file
> > > >
> > > > But the current behaviour is that copy_file_range does a short
> > > > copy up to the source file EOF. Fix the kernel behaviour to match
> > > > the behaviour described in the man page.
> >
> > I think the behavior implemented is a lot more useful than the one
> > documented..
>
> The current behaviour is really nasty. Because copy_file_range() can
> return short copies, the caller has to implement a loop to ensure
> the range hey want get copied.  When the source range you are
> trying to copy overlaps source EOF, this loop:
>
>         while (len > 0) {
>                 ret = copy_file_range(... len ...)
>                 ...
>                 off_in += ret;
>                 off_out += ret;
>                 len -= ret;
>         }
>
> Currently the fallback code copies up to the end of the source file
> on the first copy and then fails the second copy with EINVAL because
> the source range is now completely beyond EOF.
>
> So, from an application perspective, did the copy succeed or did it
> fail?
>
> Existing tools that exercise copy_file_range (like xfs_io) consider
> this a failure, because the second copy_file_range() call returns
> EINVAL and not some "there is no more to copy" marker like read()
> returning 0 bytes when attempting to read beyond EOF.
>
> IOWs, we cannot tell the difference between a real error and a short
> copy because the input range spans EOF and it was silently
> shortened. That's the API problem we need to fix here - the existing
> behaviour is really crappy for applications. Erroring out
> immmediately is one solution, and it's what the man page says should
> happen so that is what I implemented.
>
> Realistically, though, I think an attempt to read beyond EOF for the
> copy should result in behaviour like read() (i.e. return 0 bytes),
> not EINVAL. The existing behaviour needs to change, though.

There are two checks to consider
1. pos_in >= EOF should return EINVAL
2. however what's perhaps should be relaxed is pos_in+len >= EOF
should return a short copy.

Having check#1 enforced allows to us to differentiate between a real
error and a short copy.

>
> > > i_size_read()...
> > >
> > > Otherwise
> > > Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> >
> > Looks like this doesn't even compile?
>
> It's fixed in a later patch that consolidates the checks into a
> generic check function, but I'm not sure why my "compile every
> patch" script didn't catch this.
>
> Cheers,
>
> -Dave.
> --
> Dave Chinner
> david@fromorbit.com
