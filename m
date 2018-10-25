Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BF89C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:52:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AC28A207DD
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:52:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lCPnl1OL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC28A207DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727418AbeJZH1K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 03:27:10 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:39586 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726570AbeJZH1K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 03:27:10 -0400
Received: by mail-vs1-f67.google.com with SMTP id u21so5941839vsl.6;
        Thu, 25 Oct 2018 15:52:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/DJ7o0s+vOrODD17+qkd115V7kEN3Bagy3xeMJ9VpVA=;
        b=lCPnl1OLZLpLG9LmiGLYYhIDLkpnPuMxDg9xu4sVGD1dCCVRTYry+Dxs0GEunzEaQW
         PToeZuGo1TIZuArBpdMZcblrfXpDzs4DROnZjfD4bD7bZua4Gq5dcfbJLuMM8vtNISc2
         4GzOThAs7GGIuLG2D8mAJSyGyKbd0sTW0TgAuSSCDG3sh+BlrloxapOPYDr4hch3iyYD
         Qux6GxkvWmyoevEMP6a1cfAcSmysJDliYR6rCk1qw9glaUg/XB4SZFS5xH+EgdCwRwws
         nPV0xuDvU+ZvOXi8/SnwEqdEx6zjfc4V8/e4E26bXpJaRRdCKYfo5Xmey+yq1eP9MqkS
         3xkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=/DJ7o0s+vOrODD17+qkd115V7kEN3Bagy3xeMJ9VpVA=;
        b=BLn5w7bzFKR8og5dU1LUN6r16WWENtABLYlLr2cjft3BX3UShoTJBKVFj200tyPiO+
         S74TcyqQm3nSbVTsbDfnGY9MtzV5tuKlE9v6GtluDRAwgAJxJ3nX5tr/56udDyVwt1K1
         /6WYecNf/5fjIblwWEb5afTouQHbl1kX/tsBmJNCeRbrfA0lRuiVbC5FAUZrPrrqYXZ1
         g/zJSAvkBgWhJ8c4FXu/Q9xRhdKq64Web5EUg5DA/BtuXppck2mapOBQjSqWqmG8jjsR
         LupHEFjOgChH2iXbm5nH/jMfmRvRwSZZFhdeewmWd1MRPqHSEg3xfslJ0i5S2fkYrD0/
         b/VQ==
X-Gm-Message-State: AGRZ1gLb0NvV6WbwVZq/0OBBxPX9zN+HQe324Z4vTXqpEt8/xHe5N33p
        o74JJbN3Q1WCZmyrgpY7CZQEd2RViOcx35aaLiQ=
X-Google-Smtp-Source: AJdET5dA4cWRRdDGzZrRa4FDPn0kx0gL0Q3eIk/57d7aX7ypO71e0HADmE/Q42M4iFwbWMIH5rGwOj4dKLHcsFzmBOo=
X-Received: by 2002:a67:ca9d:: with SMTP id a29mr536576vsl.194.1540507956567;
 Thu, 25 Oct 2018 15:52:36 -0700 (PDT)
MIME-Version: 1.0
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
 <20181025215147.36248-2-olga.kornievskaia@gmail.com> <20181025221752.GM25444@bombadil.infradead.org>
In-Reply-To: <20181025221752.GM25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 18:52:24 -0400
Message-ID: <CAN-5tyFBy5DwY3vpLuCj6Ms2LU_+KQnJ+sq49d=4TjJPzZjoLQ@mail.gmail.com>
Subject: Re: [PATCH v3 01/11] VFS move cross device copy_file_range() check
 into filesystems
To:     willy@infradead.org
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

On Thu, Oct 25, 2018 at 6:17 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Oct 25, 2018 at 05:51:36PM -0400, Olga Kornievskaia wrote:
> > +--
> > +[mandatory]
> > +     ->copy_file_range() may now be passed files which belong to two
> > +     different superblocks of the same file system type or which belong
> > +     to two different filesystems types all together. As before, the
> > +        destination's copy_file_range() is the function which is called.
> > +     If it cannot copy ranges from the source, it should return -EXDEV.
>
> Something weird happened to the indentation here?

I will recheck my tabs. Thank you.
>
> > +++ b/Documentation/filesystems/vfs.txt
> > @@ -1,5 +1,6 @@
> >
> >             Overview of the Linux Virtual File System
> > +- [fs] nfs: Don't let readdirplus revalidate an inode that was marked as stale (Benjamin Coddington) [1429514 1416532]
> >
> >       Original author: Richard Gooch <rgooch@atnf.csiro.au>
> >
>
> This stray change slipped in.

Wow. Thank you. I have no idea how that got in. Will fix it.

>
> > @@ -958,7 +959,10 @@ otherwise noted.
> >
> >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> >
> > -  copy_file_range: called by the copy_file_range(2) system call.
> > +  copy_file_range: called by copy_file_range(2) system call. This method
> > +                works on two file descriptors that might reside on
> > +                different superblocks which might belong to file systems
> > +                of different types.
>
> I don't think you need this change at all.

Ok will remove it.

> The actual code looks good.

Thank you for the review.
