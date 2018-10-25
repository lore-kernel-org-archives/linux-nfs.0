Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95619C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:27:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B37C2082D
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:27:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fpVskous"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B37C2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727542AbeJZAA2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:00:28 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:37294 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727400AbeJZAA2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 20:00:28 -0400
Received: by mail-vs1-f67.google.com with SMTP id r83so5766560vsc.4;
        Thu, 25 Oct 2018 08:27:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9Uup25R5I3Xcc/nk9RL9fhGTGzQE2YGW3Z0KxAHX2go=;
        b=fpVskous6ocx3MJeUUxGI/gPZW0zi96fsu582fG8zwGVfOKTpCYSImhshHIy4nNtCb
         BFAXXfb4PTSumAypeG7llmmMLnFk1ghCGJMfAdyOYQtQG18ONzDm1t8ioRETP9gurypt
         i+DFtWN4LLx94YG3ln8GMma6DnCWzD3hB1lgf49Q2/+YRh1tH9aYhPxxJuzIqJ0KN6SH
         LiUkwhNQrecWd5R+73886UpEXsQFzmE0hu6xzOK2N3t2EMfM9aogGPRN3PhW5MLxGN11
         4WGhcGpHz7/XIS5fotUrc/VYM/g4BI7ZdpFm2QKgGH91cJdFahwsCRZe8+LvgY9OWlbN
         bD5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9Uup25R5I3Xcc/nk9RL9fhGTGzQE2YGW3Z0KxAHX2go=;
        b=e3wqS5bdP1FrIaNl52C5r5pkvmtvLqU+Lp3p1d6f6Ty7FEY+3b5KlWQO2tdJHzKOtL
         OXHWIKjy/ewqgGtuFLb4YOxMH5OuhIvhJ7TLVSDWvayZ1gJg2CrVL7WtW53afO29T3Oz
         WNYwybNfGcLnK91KS05YwXVBzMCWWjMqPB5GDnRMV0gEfnea75Lp0MvsOjcb9NjfiwGm
         dbBgj0A/9oGNsvk9MGmruWVXw/j50OHBWIXqD6sUeOPdgN4rNWQS12FwxioBat17OnbJ
         4MGFN41CvCw/KUQ5tosNu6wXdb3spMVvpBzjLIg+bTIE8SJlTSdEXK8qd6q79cGIU2Wc
         LO7Q==
X-Gm-Message-State: AGRZ1gJ+Kj7vAYE4LQrM9bBX+DB0frJp3iRFydUHiDBFqPq+gVkkRmbv
        kdR84OHz5KdNn6SqwkISEVF1rnDOLOLeZ9GSvLk=
X-Google-Smtp-Source: AJdET5fquk9fM2RY2FrDtOy22tFwtryEUmzGHAA4K1uNY4fm2sXCBDNGmjVqxT5WbQNjmp7lV1bCQYN0c4hPGp/ihq0=
X-Received: by 2002:a67:4282:: with SMTP id p124mr914233vsa.134.1540481231316;
 Thu, 25 Oct 2018 08:27:11 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-3-olga.kornievskaia@gmail.com> <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
In-Reply-To: <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 11:26:59 -0400
Message-ID: <CAN-5tyE1PsKkxZEQwHpd3HvBvFPFUpcJ5=F7-DQKAHpQp3T3=A@mail.gmail.com>
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
To:     Amir Goldstein <amir73il@gmail.com>
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

On Thu, Oct 25, 2018 at 12:28 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > A proposed VFS change removes the check for the files to reside
> > under the same file system. Instead, a file system driver implementation
> > is allowed to perform a cross-device copy_file_range() and if
> > the file system fails to support it instead fallback to doing
> > a do_splice copy. Therefore, EXDEV is no longer a possible error.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  man2/copy_file_range.2 | 7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> >
> > diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> > index 20374ab..723b2d0 100644
> > --- a/man2/copy_file_range.2
> > +++ b/man2/copy_file_range.2
> > @@ -39,7 +39,8 @@ The
> >  .BR copy_file_range ()
> >  system call performs an in-kernel copy between two file descriptors
> >  without the additional cost of transferring data from the kernel to user space
> > -and then back into the kernel.
> > +and then back into the kernel. Since kernel version 4.21(???) passed in
> > +file descriptors are not required to be under the same mounted file system.
> >  It copies up to
> >  .I len
> >  bytes of data from file descriptor
> > @@ -128,10 +129,6 @@ Out of memory.
> >  .B ENOSPC
> >  There is not enough space on the target filesystem to complete the copy.
> >  .TP
> > -.B EXDEV
> > -The files referred to by
> > -.IR file_in " and " file_out
> > -are not on the same mounted filesystem.
>
> Man page serves users of old kernels as well. You should not delete this
> expected error, but you can add "... and kernel does not support cross
> filesystem copy".

Thank you, will do.
>
> Thanks,
> Amir.
