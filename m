Return-Path: <SRS0=azzX=QQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D5DC282C4
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 04:04:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AAF9320857
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 04:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hSOW511h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726244AbfBIEEe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 23:04:34 -0500
Received: from mail-yb1-f194.google.com ([209.85.219.194]:42801 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726222AbfBIEEe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 23:04:34 -0500
Received: by mail-yb1-f194.google.com with SMTP id j189so2255984ybj.9;
        Fri, 08 Feb 2019 20:04:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=enIybAefhAuE9P35ixCkg8FjG9snV/i8l1p/1gt6y/U=;
        b=hSOW511hc0WACiMRgmtpSZqmAHfdPwTkugFlDsa3ahdAfZj2Itfze4kU7vf82QUeCZ
         UUYMJcHzWmG2hQv+/9DSRm9WXTv5PrqqhS8uraQzwW2v9ug4RCx8r7bDvI+aHf2EiVB6
         TwtBmHszRQf9ORUUu4E+mMrz8nMLOxVnLkGQj2C5xjEBwNVk6WJwszrRDceF33S2zGWK
         8T5IzjkBmkyzlT+0CjXjmwZjqR61f1tKcgbgjbzG697frZcvJCBiXnLeiYFbxzr19Xlj
         iuchInEZziF24ifs1fvx3nxVwzYFlTvdQZvZSEQxSAmlZQESr970GTb+WnDX5fTcrA79
         P+bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=enIybAefhAuE9P35ixCkg8FjG9snV/i8l1p/1gt6y/U=;
        b=UnhtIlZKKaaf6w2a5HoWmN1RWARpraNVXGwDt7u5rCcPvivJ4EK98bhVftsdCWIkkv
         38gf2SFngESYtXj4ZEu7uWSf3mUq9Xa7kInm/2B4QWjfqiI5mymy/Jk2W7iidZ/mqFpJ
         l1gmOnbInpncBb+kG0COfhPAXQSM7WBTuzR2uKX+dSPVUQ6Gig8+jFF9s/v/5B1Th9RZ
         lFxF3oKWrdpH0kqL3ortw07qGhBN8F0OwC2oQc4nNZpT6Cqc5LZwNsyXt8X1b2PVUozl
         nxV4g4fSxcdCztP0v1CR+S88nJL2ThU32bD2ytsbBkYOsrOGHKmKufGXg9Daaljh4g4q
         f6Fw==
X-Gm-Message-State: AHQUAubB9mA1rpudoDLEhCsH+SwblgIR9rp/8lFlQzVq//sKFnyFZjkF
        T8E+IdqTai3qKrO5Ruo7akjaQcOqd5jPSaMH5GHyrr2O
X-Google-Smtp-Source: AHgI3IYqIp9tOZgPrv9aJ3DK/TRmoVoGROhXRQxcf8OToVlUpeYnPyoO1NrjQlMgI8787Us09NwvTZERTIFjJh6pZ6s=
X-Received: by 2002:a25:374f:: with SMTP id e76mr20671660yba.337.1549685073638;
 Fri, 08 Feb 2019 20:04:33 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
In-Reply-To: <20190208221239.GA199180@jra3>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Sat, 9 Feb 2019 06:04:22 +0200
Message-ID: <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     Jeremy Allison <jra@samba.org>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, Jeff Layton <jlayton@kernel.org>,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Feb 9, 2019 at 12:12 AM Jeremy Allison <jra@samba.org> wrote:
>
> On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein via samba-technical wrote:
> > On Fri, Feb 8, 2019 at 5:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Fri, Feb 08, 2019 at 04:45:46PM +0200, Amir Goldstein wrote:
> > > > - check_conflicting_open() is changed to use inode_is_open_for_read()
> > > >   instead of checking d_count and i_count.
> > >
> > > Independently of the rest, I'd love to do away with those
> > > d_count/i_count checks.  What's inode_is_open_for_read()?
> > >
> >
> > It would look maybe something like this:
> >
> > static inline bool file_is_open_for_read(const struct inode *file)
> > {
> >         struct inode *inode = file_inode(file);
> >         int countself = (file->f_mode & (FMODE_READ | FMODE_WRITE)) ==
> > FMODE_READ) ? 1 : 0;
> >
> >         return atomic_read(&inode->i_readcount) > countself;
> > }
> >
> > And it would allow for acquiring F_WRLCK lease if other
> > instances of inode are open O_PATH.
> > A slight change of semantics that seems harmless(?)
> > and will allow some flexibility.
> >
> > But if samba can't figure out a way to keep a single open file
> > descriptor for oplocks per client-file, then this model doesn't
> > help us make any progress.
>
> Samba uses a single file descriptor per SMB2 open file
> handle. Is this what you meant ? We need this to keep
> the per-handle OFD locks around.

I understand now there are several cases when smbd has
several open file descriptors for the same client.
Is that related to this comment in samba wiki about kernel oplocks?

"Linux kernel oplocks don't provide the needed features.
(They don't even work correctly for oplocks...)"

Can you elaborate on that? is that because a samba oplock
is per client and therefore other file opens from same client
should not break its own lease?
If that is the case, than Bruce's work on the "delegations"
flavor of kernel oplocks could make them a good fit for samba.

As Bruce wrote, we could export the "delegations" flavor
to user space for samba, just after we figure out it matches
samba requirements.

Thanks,
Amir.

[1] https://wiki.samba.org/index.php/Samba3/SMB2#locking.2Fopen_files_.28fs_layer.29
[2] https://lore.kernel.org/lkml/1549656647-25115-1-git-send-email-bfields@redhat.com/
