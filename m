Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3068AC004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:35:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E56A820663
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:35:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LYZUdH3J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E56A820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728360AbeJWDy4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 23:54:56 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:33237 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728435AbeJWDy4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 23:54:56 -0400
Received: by mail-ua1-f65.google.com with SMTP id j13so10421207ual.0;
        Mon, 22 Oct 2018 12:35:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KTv6+0V6q9mnXVoM4Ff+n7UzMsGxuryepPkAG7b5aks=;
        b=LYZUdH3JcLCX8BeXKB3J6c5zsft1YRG+w5TQgwhdZVeWsQOtc1q1GqJZ8lknlhq9j4
         4I1i1BROAZ9pfzs6xM1U5zJiEPadVKmPbYFUgeC5NlSOaGgdhdGHjqjp4wwL4rcBTjtR
         GK9m+FUP5vs6Ltqdj7MjS8FvA9OZUepyUGr6op2QiYihwPrLuZjzeXe8Y7tmzmX0kX92
         JSqTLiIn2tN7NTZzN0RCz+SZRdcWSCf2z+NiXfw8oj0FTU8GpLAo8Z5116vD2g/nAY8T
         tLP/LPgHwYtaxUw79sQVDjd02GUC9rY9/fTWKPFBcDmg6HjfqZb3Uj9Qn3aRf14tvBPN
         QYNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=KTv6+0V6q9mnXVoM4Ff+n7UzMsGxuryepPkAG7b5aks=;
        b=mWgaBfz1jEZQFirdGsN9bGog71gf1UYW0YwT+6yeezLPnSFThhAZHQD0PMY783BNAo
         Dz9q2/is4mW4M/BRh882R6Ei6POkpDyov8TdB+g0O9/Yb6LDrYBumrfiB0oUe047ZQVH
         eqX6GI7oyjZ2sAq4Q78cPIUpcqVWqI7J/oYPENM1g6GUnen8wr4mZYHTn1Ro4xFYJ2I6
         Ym52uB+w7IK3LBdAux3uCn1qduGp0//mR5/gkPRovMpZ12D/dkezlY4Abbt2PJCVi6z2
         Ja1YMpV6+MrHhgM2kjUwYdcxkg6LEf809+N3139oIY1FRLtOxjM3Sa9t4K2OYO9RO5Bq
         SsMA==
X-Gm-Message-State: AGRZ1gK5eoks1+H3CGM+ivWOaYElBay0oTsC5lN9T5gD/1K+m/AI/DZd
        +OFNqYcOZzhqv/2O4l1RmD+VWaH/9tAPe4DGyy6Jkg==
X-Google-Smtp-Source: AJdET5dEk4edKrUpVmQ94QzAYf6uibDhVR+sgcQ+oMKYe1DmQhBnhLwPypkdOT8S9TFtk6Xr80UjdSMCMlXmOi6wshg=
X-Received: by 2002:ab0:24cb:: with SMTP id k11mr19158uan.104.1540236904492;
 Mon, 22 Oct 2018 12:35:04 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com> <20181022190620.GA8863@bombadil.infradead.org>
In-Reply-To: <20181022190620.GA8863@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 22 Oct 2018 15:34:52 -0400
Message-ID: <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     willy@infradead.org
Cc:     Amir Goldstein <amir73il@gmail.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> > On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > > Another thing is the commit message claims to:
> > > "Allow copy_file_range to copy between different superblocks but only
> > > of the same file system types"
> > >
> > > But what the patch actually does is:
> > > "Allow copy_file_range() syscall to copy between different filesystems
> > > AND allow calling the filesystems' copy_file_range() method
> > > between different superblocks but only of the same file system types"
> > >
> > > It's probably OK and quite useful to do the former, but maybe man page
> > > should be fixed to explicitly mention that the copy is expected to work
> > > across filesystems since kernel version XXX (?)
> > >
> > > If you don't wish to change cross filesystem type behavior and only
> > > relax cross super block limitation, then you should replace the
> > > same inode->i_sb check above with same inode->i_sb->s_type
> > > check instead of doing the check only for calling the filesystem
> > > copy_file_range() method.
> >
> > Thank you for the feedback. In the next version, I will remove the
> > check for the functions and instead check for the same file system
> > types.
>
> Jeff and I agree that this is the wrong way to go.  Instead, the
> cross-device check should be in the individual instances, not the top
> level code.

So remove the check all together for the VFS (that was my original
patch to begin with (like #1 not this one). So am I missing the point
again, I keep getting different corrections every time.
