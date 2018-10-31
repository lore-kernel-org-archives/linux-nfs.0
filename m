Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9FEEC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 17:07:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5B5212080A
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 17:07:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LldWePEY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B5212080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729383AbeKACGR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 22:06:17 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:41508 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729107AbeKACGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 22:06:16 -0400
Received: by mail-ua1-f65.google.com with SMTP id o17so6185052uad.8
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 10:07:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=avMUd+m4omDY5tHB4y5hU8/AKqakvTZfOxdXiosGlQM=;
        b=LldWePEYZlWI75oqyRKbZbPT0ug+S86EZOv2Yf2M/es22bxyEMCweOmwwM851LJYRT
         wwRXT3WL0tT+Uqwa2ZCEIrBKFGAEnjBfHXYcyaoD21gK7uubSTlfcqMzhu/635xxW1/1
         KtNCjSCA7x3Naq2trN6x5MKgE8sHMpG0X9iQhIT5PqMaY75sFaH7Hork1PaB1cBhIVBg
         LowrN2hvd1uisv9vJMHBRQd/HI+eOXABbisFWaQzpwePuha3D95NMTqT4pGecaPegkOP
         iEwgWjkvOjQ+MnW2+BwRcKhbGd48y221yL6i2J3NejwJ21RDXqwbPt0ALb5oQ2lH39wx
         JnXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=avMUd+m4omDY5tHB4y5hU8/AKqakvTZfOxdXiosGlQM=;
        b=ovEWV47yGINkWOjQypEHvoIHb8NtFGFHU/CttJC7fgtUPDJubfyW3LSz501rPRYemu
         v83UuZaPpJQjfmUXpBGB6clgleUaVJE5TsoA6rTKUcfU5dqIVjqcaBmQmnN6bzqZ+GRR
         QunuOfZ8kQBXNWVJgau/FXMX6JBo8K0kOLyuDxFKl/r5XD96ue66D6EiEuq/swZux/iw
         K4i3HBl1C4P3QBiq9NBS4s6LpYTRlmQbCHeA4mXC9Bq1MVHOMBizw2y9pyjZe52NJ27k
         PvKz+nzlOWi/fafbypIM38jGsz5vDgAixUchifqX0kblzPbR71RtvRD+xXnHaXbx8oeg
         SKUg==
X-Gm-Message-State: AGRZ1gIBpfW8M8aM5Yhcfbv1yQxpl5G77zYc2n+JI7JhlRCmWYsy+y/c
        aT4LWARYvZJPQeF0luuKjQU76fZ9C/xKvm0Ase8=
X-Google-Smtp-Source: AJdET5epCeHeyBwrlE+dpjrIEm4nl2tgiUq3rEy9A6nHbPkbzjWvO2o54sXtvorqBqen8QGvz/A6e/iv3/2Ox2thJj4=
X-Received: by 2002:a9f:35cd:: with SMTP id u13mr1799819uad.5.1541005642860;
 Wed, 31 Oct 2018 10:07:22 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-2-olga.kornievskaia@gmail.com> <20181031165430.GA3377@fieldses.org>
In-Reply-To: <20181031165430.GA3377@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 31 Oct 2018 13:07:11 -0400
Message-ID: <CAN-5tyHTZV9LYnfD9Ag_pSdWA2Zs69JNvVBjHPQTMnDm2kRuEQ@mail.gmail.com>
Subject: Re: [PATCH v1 01/13] fs: Don't copy beyond the end of the file
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 12:54 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:53AM -0400, Olga Kornievskaia wrote:
> > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>
> I have some idea we've had some discussion about this before, but if so
> I've forgotten the conclusion.  Could we have more of a changelog?:
>
>         - isn't there a race condition, or is there something preventing
>           the file size from changing here?

No there is nothing preventing the size from changing. Just like there
is nothing that prevents the file from changing if you are doing a
traditional copy either.

>         - why are we doing this?  Does this change the behavior of
>           copy_file_range()?

We are doing this because 1. NFS spec and 2. copy_file_range semantics
mandate that too. There is a whole different discussion under the
client-side patch for this where the plan now is that VFS themselves
are interested in making sure they are indeed enforcing the check
stated by the documentation of copy_file_range call which states
"copying a range beyond the end of the file" is EINVAL. I recall you
argued for a "short" read instead of a EINVAL but unless VFS community
is convinced to change it it'll be enforced (soon).

>
> --b.
>
> >
> > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > ---
> >  fs/read_write.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 39b4a21..c60790f 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >       if (unlikely(ret))
> >               return ret;
> >
> > +     if (pos_in >= i_size_read(inode_in))
> > +             return -EINVAL;
> > +
> >       if (!(file_in->f_mode & FMODE_READ) ||
> >           !(file_out->f_mode & FMODE_WRITE) ||
> >           (file_out->f_flags & O_APPEND))
> > --
> > 1.8.3.1
