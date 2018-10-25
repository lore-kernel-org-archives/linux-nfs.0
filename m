Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC173ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 18:14:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D7D920834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 18:14:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SuVnGAFk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7D920834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727705AbeJZCsn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 22:48:43 -0400
Received: from mail-ua1-f68.google.com ([209.85.222.68]:45790 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727636AbeJZCsn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 22:48:43 -0400
Received: by mail-ua1-f68.google.com with SMTP id x3so211063ual.12;
        Thu, 25 Oct 2018 11:14:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kJFw6EP75Qlz6HF0Nmw65rrqPMvwjMd8wjftDnK8aig=;
        b=SuVnGAFkvMsIhFKlT68rznwJGGv0jkCENPuAywczc1RxoyXbqeUwMjFrEdgmSDWNv/
         LO931CA/OuoA7w2HhB0dfIrlj9DdvWh719v+OsTWegjVEDYhBprZDbhYDOK90z/43Hmf
         yF/SxtaOn7m1ZXuTUdK+xG2kRjD6rxqU0RERmRWiDbi6cBx8kP5eq4nbks+9V5g+vGcz
         LR3KyXxQKot3eTTQ+5jvL73HcYQLUqjdrHyHAOgn0pR+pbv5C00+t5YMUtUwU2pJwlSw
         wt/40V4bqoGPbKoK+E36bAIGVfZNh0xhm+xQEMh39DjDwKEt6CcDFvFoQkF78L2nm9LA
         E6Fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=kJFw6EP75Qlz6HF0Nmw65rrqPMvwjMd8wjftDnK8aig=;
        b=tWUMcgX+gxK3F5aeSI3FrwZ/GGiD30sKOVYqWzCU7t+aknXwz5T9lD+q2NA42VTyXP
         y2eI3Haf6Ttv6qFTqDvYCKbPU63zFR1dfbk7kHQFGzeMmhG1T/H33jUpUTlhjVKE9C3A
         3f8/6IGQgM9zZZWrlycQ0KpQneYbSkI/NmVrMrDt3JFEjwHzEihZOHmOSK4E5mwTJXr/
         3QZriFroH59H/vieW52XO59Hxvpysza9i/8AWg8jSRFCfrnCDnLlLvMOGp9OUDL9mo66
         SIrzvpuNg4D24kMSBErzz2i9XZ7dRmigz1Sf0kErsN7KNWee1inL2IVZ9Th8aqSr1Bln
         XvXQ==
X-Gm-Message-State: AGRZ1gKEsz9NEnWrLFLObH+P6os0i26Nm9IZOINwwfN6RrZhOyxj5Jyh
        0C3QzKzV2GzjtLvFIDASamCMVFsIy1dnlPFPVas=
X-Google-Smtp-Source: AJdET5fpsppzE8n8KSnF1g52ukagNbXjcw9ofyCL2urElzIJW8TkJwttUrfo0uuqCrJ3yFYABt3OIE1/m7F1g/9BpFA=
X-Received: by 2002:a9f:35cd:: with SMTP id u13mr154066uad.5.1540491291759;
 Thu, 25 Oct 2018 11:14:51 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-3-olga.kornievskaia@gmail.com> <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
 <20181025172426.GI25444@bombadil.infradead.org> <CAN-5tyHOk=h+5GdmrUrnTBhvOEeYkz34YXsaudHBiEhgt1o7gQ@mail.gmail.com>
 <20181025180800.GJ25444@bombadil.infradead.org>
In-Reply-To: <20181025180800.GJ25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 14:14:39 -0400
Message-ID: <CAN-5tyE1inR6SOP3RSFEB+Pk-A7uan_c3Hi_oK47zL9Drvvh1w@mail.gmail.com>
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

On Thu, Oct 25, 2018 at 2:08 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Oct 25, 2018 at 01:47:21PM -0400, Olga Kornievskaia wrote:
> > On Thu, Oct 25, 2018 at 1:24 PM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Thu, Oct 25, 2018 at 07:28:10AM +0300, Amir Goldstein wrote:
> > > > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > > > <olga.kornievskaia@gmail.com> wrote:
> > > > >
> > > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > > >
> > > > > A proposed VFS change removes the check for the files to reside
> > > > > under the same file system. Instead, a file system driver implementation
> > > > > is allowed to perform a cross-device copy_file_range() and if
> > > > > the file system fails to support it instead fallback to doing
> > > > > a do_splice copy. Therefore, EXDEV is no longer a possible error.
> > > > >
> > > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > > ---
> > > > >  man2/copy_file_range.2 | 7 ++-----
> > > > >  1 file changed, 2 insertions(+), 5 deletions(-)
> > > > >
> > > > > diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> > > > > index 20374ab..723b2d0 100644
> > > > > --- a/man2/copy_file_range.2
> > > > > +++ b/man2/copy_file_range.2
> > > > > @@ -39,7 +39,8 @@ The
> > > > >  .BR copy_file_range ()
> > > > >  system call performs an in-kernel copy between two file descriptors
> > > > >  without the additional cost of transferring data from the kernel to user space
> > > > > -and then back into the kernel.
> > > > > +and then back into the kernel. Since kernel version 4.21(???) passed in
> > > > > +file descriptors are not required to be under the same mounted file system.
> > > > >  It copies up to
> > > > >  .I len
> > > > >  bytes of data from file descriptor
> > > > > @@ -128,10 +129,6 @@ Out of memory.
> > > > >  .B ENOSPC
> > > > >  There is not enough space on the target filesystem to complete the copy.
> > > > >  .TP
> > > > > -.B EXDEV
> > > > > -The files referred to by
> > > > > -.IR file_in " and " file_out
> > > > > -are not on the same mounted filesystem.
> > > >
> > > > Man page serves users of old kernels as well. You should not delete this
> > > > expected error, but you can add "... and kernel does not support cross
> > > > filesystem copy".
> > >
> > > I'd rather see this worded as:
> > >
> > >  .B EXDEV
> > >  The files referred to by
> > >  .IR file_in " and " file_out
> > > -are not on the same mounted filesystem.
> > > +cannot be copied due to being on incompatible filesystems
> >
> > Why should this be changed to "incompatible filesystems". Existing
> > code doesn't support not only incompatibly filesystem but also cross
> > device of compatible file systems. And this error is only left for the
> > old kernels. In the new kernel, the error EXDEV will never be
> > returned.
>
> If I try to copy_file_range() between an NFS filesystem and a CIFS
> filesystem with a new kernel, what error do I get?

It is my understanding that you will not get an error instead a
do_splice_direct() will do that copy.
