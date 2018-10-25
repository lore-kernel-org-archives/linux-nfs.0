Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B966C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:47:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6244A2082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:47:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m6nvRo3u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6244A2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727578AbeJZCVW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 22:21:22 -0400
Received: from mail-ua1-f67.google.com ([209.85.222.67]:38389 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727465AbeJZCVV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 22:21:21 -0400
Received: by mail-ua1-f67.google.com with SMTP id g10so2750978uak.5;
        Thu, 25 Oct 2018 10:47:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kwT3sEP7qpS/Iw0+ipH82Ud80dGv69SNcdjnymwLt4s=;
        b=m6nvRo3ueZN6LeMXbnSBL0TI+LvLsLMWaP8dPXB9tlZMegvMoQF6uf7SOsowZcHCMQ
         RIPN9CQz4pBVq/5Xqpw4xgBdqGnkKvYPfokdnG20q/1pKWfUTsHBjpTvAGvU0sBQ5/KV
         lQcnOpcNB69xgNfAWRo4Qr5nBcMWtmYau3x9+eDa7Y1z/GHzTWYczb1OdzEfC/6LO8+I
         r/o6YSnN46qqc+oz/dK59HJQc3jZjAVBS30FVNVYxWRoknMcQiRW/NpsHHopxUGj2bCA
         Qgra/H/ojRS0Ufx9DLDLAlFV7wtQ9eZVLZNk8yCNKY80yzZmkk8kQx9909cLhx+o2pMn
         VQoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=kwT3sEP7qpS/Iw0+ipH82Ud80dGv69SNcdjnymwLt4s=;
        b=jMbr9bQkLovr1iQ5lHKA+l38Le8sep+nRSVgPYoRY906h7s3us+c53Fqh4TDUOZ+Wy
         xILFdTaPm8PD/OQL+yA6QK95dKAFZv2TO/wsdmniwCEmMUcruCFXQbQf6vdPGaYf240E
         xtgVZYV4tkOakVjk0Ffz/iSA25Hg3lvTwVF9l0qO2pKQZ1JbdB97TAgxhZkJlxRNee7x
         VggPuLqpHmL87CtTicWbYo0NaRzGR2IHp5/yXDKFtrOhTWUjfI2ofbM8fe4SmliYsFBS
         8U8BCvctuQVuo5oZyz7Qj8mxPr/N47iH6/7pAvkJsfL2EPg1hSNqGsMh5+QT9D3CzN/E
         +CIg==
X-Gm-Message-State: AGRZ1gIyfls03cqX60Iia3kd0IijU3nuaJx11HNdUIwyM+o1w0WTDUzH
        5TVPSXNmZL9h7Lof0oeRn8t7b/6wEEwgqNUCLY0=
X-Google-Smtp-Source: AJdET5ce3ugK58LcUt8tB8HQr5rGnXrM7uuvzT5JzQ258WtRf+jYVoxVpPXE/G90Ty9uLIOKgHQhYGlnxSGTrbjHPqc=
X-Received: by 2002:ab0:918:: with SMTP id w24mr100399uag.51.1540489653868;
 Thu, 25 Oct 2018 10:47:33 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-3-olga.kornievskaia@gmail.com> <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
 <20181025172426.GI25444@bombadil.infradead.org>
In-Reply-To: <20181025172426.GI25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 13:47:21 -0400
Message-ID: <CAN-5tyHOk=h+5GdmrUrnTBhvOEeYkz34YXsaudHBiEhgt1o7gQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
To:     willy@infradead.org
Cc:     Amir Goldstein <amir73il@gmail.com>,
        trond.myklebust@hammerspace.com,
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

On Thu, Oct 25, 2018 at 1:24 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Oct 25, 2018 at 07:28:10AM +0300, Amir Goldstein wrote:
> > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > A proposed VFS change removes the check for the files to reside
> > > under the same file system. Instead, a file system driver implementation
> > > is allowed to perform a cross-device copy_file_range() and if
> > > the file system fails to support it instead fallback to doing
> > > a do_splice copy. Therefore, EXDEV is no longer a possible error.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  man2/copy_file_range.2 | 7 ++-----
> > >  1 file changed, 2 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> > > index 20374ab..723b2d0 100644
> > > --- a/man2/copy_file_range.2
> > > +++ b/man2/copy_file_range.2
> > > @@ -39,7 +39,8 @@ The
> > >  .BR copy_file_range ()
> > >  system call performs an in-kernel copy between two file descriptors
> > >  without the additional cost of transferring data from the kernel to user space
> > > -and then back into the kernel.
> > > +and then back into the kernel. Since kernel version 4.21(???) passed in
> > > +file descriptors are not required to be under the same mounted file system.
> > >  It copies up to
> > >  .I len
> > >  bytes of data from file descriptor
> > > @@ -128,10 +129,6 @@ Out of memory.
> > >  .B ENOSPC
> > >  There is not enough space on the target filesystem to complete the copy.
> > >  .TP
> > > -.B EXDEV
> > > -The files referred to by
> > > -.IR file_in " and " file_out
> > > -are not on the same mounted filesystem.
> >
> > Man page serves users of old kernels as well. You should not delete this
> > expected error, but you can add "... and kernel does not support cross
> > filesystem copy".
>
> I'd rather see this worded as:
>
>  .B EXDEV
>  The files referred to by
>  .IR file_in " and " file_out
> -are not on the same mounted filesystem.
> +cannot be copied due to being on incompatible filesystems

Why should this be changed to "incompatible filesystems". Existing
code doesn't support not only incompatibly filesystem but also cross
device of compatible file systems. And this error is only left for the
old kernels. In the new kernel, the error EXDEV will never be
returned.
