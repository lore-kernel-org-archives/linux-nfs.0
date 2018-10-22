Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B226C004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:48:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B04D2064C
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:48:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gac6uBHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B04D2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726863AbeJWEIQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 00:08:16 -0400
Received: from mail-yb1-f194.google.com ([209.85.219.194]:41943 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726457AbeJWEIQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 00:08:16 -0400
Received: by mail-yb1-f194.google.com with SMTP id e16-v6so16686324ybk.8;
        Mon, 22 Oct 2018 12:48:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+OBcrsWB5o8C33bR+eKjTiYPpRpJfv3MgT9Nt30oq0Q=;
        b=Gac6uBHn4d2oiES9Y15vzCTkCP3U6fj/+zqU+DLO3whPaM2hNS+TXIagi80bU4mNVE
         KlBmikndZqYhkTPBEth+0DE0OHWeTLrYQK/3zSC5+g3JZRqpts1r4Uu+ZlMGG1yX3zgH
         LgqhWJ+YYjqiuVigwrVGnIX01XvmQusAODPwJvTkRlWIR/bVb3u22eVPUosUz/tXZ/Dt
         AZkpP81E9t24dHmrb85eb3jJPw1HEdkM78MxXz+wPB7SlEtnFFuEXOCiTpKQfrKhy54W
         AXRWk4hSDWgp51y8UtJAeW/bsxnmTAvqjToAvm/VJHw19jO9HIT7uzpXMbwqk9myIVO9
         jbqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+OBcrsWB5o8C33bR+eKjTiYPpRpJfv3MgT9Nt30oq0Q=;
        b=GMZaOTwQddr7bJWPRy0sL8oNn/EZfxuhGukpv8G5eOHlOG05/fM3UJmPA+3MTO//hR
         j67gLxcZAYDYOLzENeX/XQMJjupvzRRQn1+Wy8Og6o+NnGa0QjJ9SM7AO/Hw7BxBSXxd
         CJC1XxkuqzrbFKLWgSmieSGKQruSMkN4d2TwDv1sYDAnJOePxKbP9UMR9U1nxnSAB3k5
         vePcT1/WTvYrKisqatAgkbOG1sqgFOhWnQTDf9fYgGK4jR2+VIEqU4cxEbTStq0KlpIY
         WF137B5X40/dF+r/F6/LLPYVSy4/ebMBIM3md8O97Fe0RUR3ksempPNG4YyirdFmEk0l
         PuuA==
X-Gm-Message-State: ABuFfogm/U+q1nPb8AbiTih3h/EcdwnPxhElnasZmZCFyG0orZ3fFAZt
        O/fJAYePgLEF+vGN84+h+nEhtZbDi9Uv3IWfg64=
X-Google-Smtp-Source: ACcGV613t92/obW8aE0qqxFrqp6ZzsUPWPXGKqUFqksmrkpIr1+eIk9tQcbNfQzw8EtSwdSfnIRPNZqQG3bksQYfWf8=
X-Received: by 2002:a25:198a:: with SMTP id 132-v6mr33911916ybz.325.1540237702618;
 Mon, 22 Oct 2018 12:48:22 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
In-Reply-To: <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 22 Oct 2018 22:48:10 +0300
Message-ID: <CAOQ4uxjJgghh48LUsqCofS0uiuA35CQT-zEMvMESkqniLfv2fA@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Matthew Wilcox <willy@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 10:35 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Mon, Oct 22, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> > > On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > > > Another thing is the commit message claims to:
> > > > "Allow copy_file_range to copy between different superblocks but only
> > > > of the same file system types"
> > > >
> > > > But what the patch actually does is:
> > > > "Allow copy_file_range() syscall to copy between different filesystems
> > > > AND allow calling the filesystems' copy_file_range() method
> > > > between different superblocks but only of the same file system types"
> > > >
> > > > It's probably OK and quite useful to do the former, but maybe man page
> > > > should be fixed to explicitly mention that the copy is expected to work
> > > > across filesystems since kernel version XXX (?)
> > > >
> > > > If you don't wish to change cross filesystem type behavior and only
> > > > relax cross super block limitation, then you should replace the
> > > > same inode->i_sb check above with same inode->i_sb->s_type
> > > > check instead of doing the check only for calling the filesystem
> > > > copy_file_range() method.
> > >
> > > Thank you for the feedback. In the next version, I will remove the
> > > check for the functions and instead check for the same file system
> > > types.
> >
> > Jeff and I agree that this is the wrong way to go.  Instead, the
> > cross-device check should be in the individual instances, not the top
> > level code.
>
> So remove the check all together for the VFS (that was my original
> patch to begin with (like #1 not this one). So am I missing the point
> again, I keep getting different corrections every time.

Because there are different opinions... although you did get the opinion
of the VFS maintainer, which was: compare i_sb->s_type.

Jeff, Matthew, really, what's the use of "allowing" cross fs type copy inside
filesystem code? and which method is going to be called?
file_out->f_op->copy_file_range()?
file_in->f_op->copy_file_range()?
Do we need to check if both are implemented? either?
This is just confusing Olga and gives no real value to anyone.
If we ever have a filesystem copy_file_range() method that can deal
with cross fs type copy, we can change it then when we know the
required semantics of that future call.

That is not to say that we cannot relax same fs type from copy_file_range()
syscall. That has already been done with the current patch, just not officially
declared in commit message.

Thanks,
Amir.
