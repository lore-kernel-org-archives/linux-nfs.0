Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C32C004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:39:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DD3DC20652
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:39:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tHx+0qf8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD3DC20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728773AbeJWC6x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 22:58:53 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:36322 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728308AbeJWC6x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 22:58:53 -0400
Received: by mail-vs1-f65.google.com with SMTP id c205so30275135vsd.3;
        Mon, 22 Oct 2018 11:39:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DYthPL4MkIUa2rSgy1drY3N3trC5UKvdnTNT7j11x8U=;
        b=tHx+0qf80QB8dGWgQ64RBCSQDlsWAb2MviIlyp9iLsRB/YyWyzGLgbxMH67my+eueu
         3/EL24ATKyX8uZKda/D6liklIY2zllPNA/PurJOF6LMte/eBuhvbW5oclCOqL+qcC5b+
         EMENmhssM3coXcDoh5FQ5/YdY4PM1qF0VHmNQHneLQxWBUr1f3YQMo/uN0Qm9dvC5rt6
         h3gIGH+iRW3Ap/+Lmk/NczAKcVp4nsTWQ2dSWN3tHozcvQUHnbwDTT0aru8E+/BSr38K
         PNmANc8jHAGRlQd3ZgXY4o9dAAUwYSBX4X3aE+RkJqTll8jjqnVDL+xKr+Rc+jwtTz8C
         Fs+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DYthPL4MkIUa2rSgy1drY3N3trC5UKvdnTNT7j11x8U=;
        b=csHeYIe7++mHXOqAG+OQqxTeu5SXfqWDRb8bRb0UXk8+Rx9nzy4spFZT4dOI7S/6cU
         35P4Y7N/l2+T7tPe3ejUZlJL0GLpC7gCr17y2ZpDZUdRvWBFUrROeFnbd9eGBvMgarlb
         uf7YSXO8SZSBsUxIyh3fsHwTvZijysUkdow0Gbxj+J0PnJDo7+uBvLxwue64R25iukNX
         GSa8GGQKEmqMTzgIunp9UT+fwoM+LqILzMaAbFFLZvwPWrksLtfz764tJErC3OfIJ0pF
         OQFXCnoENCqHI/pHti2YpImwOXER+r+IJkxN3pY7Dnqueqj0mV2XS6JzVWXhRgEVGmqm
         ESyQ==
X-Gm-Message-State: ABuFfogy5ZAfJzs2lwRvm4IZuJOvAqVF66TPwFLZN/C6vTW7XymR7mGT
        oRrJvexCbGSqwVFo0J5PlxlVs8oz/fVaWPQcR+8=
X-Google-Smtp-Source: ACcGV60ow4Oqly6x1ayLnlIuc9TzZ5/ebNIBPNqx2uh9oeeI5LPmxDkQfgrjSy7X5ND+UiHWprc90GjXN/S0uhNH528=
X-Received: by 2002:a67:f458:: with SMTP id r24mr19565615vsn.164.1540233553099;
 Mon, 22 Oct 2018 11:39:13 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181019175822.GB28891@bombadil.infradead.org>
 <CAN-5tyHvJQc+mPSvgX09F71otoZEoxRXdKLB=F=bGTzmEnt_eA@mail.gmail.com> <20181019190630.GC28891@bombadil.infradead.org>
In-Reply-To: <20181019190630.GC28891@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 22 Oct 2018 14:39:01 -0400
Message-ID: <CAN-5tyFTD+37ikPjCM=NwwJWyHhdJZ3XtN5jFD9Fs_RkZo=8Sw@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     willy@infradead.org
Cc:     linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Oct 19, 2018 at 02:47:42PM -0400, Olga Kornievskaia wrote:
> > On Fri, Oct 19, 2018 at 1:58 PM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > > > +++ b/Documentation/filesystems/vfs.txt
> > > > @@ -958,7 +958,9 @@ otherwise noted.
> > > >
> > > >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> > > >
> > > > -  copy_file_range: called by the copy_file_range(2) system call.
> > > > +  copy_file_range: called by copy_file_range(2) system call. This method
> > > > +                works on two file descriptors that might reside on
> > > > +                different superblocks of the same type of file system.
> > >
> > > I don't think this text is explicit enough about what has changed,
> >
> > Can you suggest a different wording that would be stronger? I can't
> > say any more clear that copy is allowed between different superblock
> > which wasn't the case before.
>
> I would leave this file alone.
>
> > > and I
> > > think this is the wrong place for it.  I think there should be a paragraph
> > > in Documentation/filesystems/porting and it should follow the current style
> > > in there.
> >
> > I have looked at the "porting" file and it's cryptic. I don't
> > understand what [mandatory] [recommended] stanzas are. There is
> > currently no copy_file_range. Is this just a "changelog" and you are
> > looking for something like
> > [mandatory]
> > copy_file_range() now allows copying between different superblocks.
> >
> > I can add this wording to the "porting" file.
>
> The porting file is written from the point of view of someone who's trying
> to port an old filesystem to current Linux.
>
> Maybe something like
>
> [mandatory]
>         ->copy_file_range() may now be passed files which belong to two
>         different filesystems.  The destination's copy_file_range() is the
>         function which is called.  If it cannot copy ranges from the source,
>         it should return -EXDEV.

Thank you I can add this to the porting file.

>
> > > > -     if (file_out->f_op->copy_file_range) {
> > > > +     if (file_out->f_op->copy_file_range &&
> > > > +                     (file_in->f_op->copy_file_range ==
> > > > +                             file_out->f_op->copy_file_range)) {
> > >
> > > Can we avoid this extra test here?  I know the various stamdards groups
> > > including T10 and the IETF have been trying to define a universal
> > > identifier for the same blob of storage, no matter how it's accessed;
> > > potentially allowing access to the same storage across iSCSI, CIFS
> > > and NFS.  If we ever get to a point where we support that (and I am
> > > dubious), we'd want to remove this test again, and have to revalidate
> > > all the filesystems.
> >
> > Well from previous submissions I was explicitly asked to add this check.
>
> I'm not sure that's exactly what Jeff was asking for.  Or maybe it was
> and my argument above will change his mind.  Jeff, what do you think?
>
> If we do do this, cifs will need a modification as part of this patch to
> reject non-CIFS files as it currently assumes that src_file->private_data
> is a pointer to a struct cifsFileInfo.
