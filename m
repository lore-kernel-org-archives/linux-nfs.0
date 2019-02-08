Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B918C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:31:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44FDE20844
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:31:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vktwl23/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726020AbfBHUbU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:31:20 -0500
Received: from mail-yb1-f193.google.com ([209.85.219.193]:33812 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726601AbfBHUbU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 15:31:20 -0500
Received: by mail-yb1-f193.google.com with SMTP id k9so1954017ybg.1;
        Fri, 08 Feb 2019 12:31:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uvvFWCc6vN9VzZMdz2W92zCLPitNQG3Ja+kmqXqI2Lw=;
        b=Vktwl23/BJFe2p3EzWw+qAcfZoVw8dLV6J0KWLPAKpYwHdnWiXyqvdU+BU0qojZH/R
         AZDmXOSoSOIkZwnNptD/eMhHKrvNNV/ILBjEySsStdLg8FRLvYkAqaEy5EF9aHCiaznr
         38OQAKBUZeODnS1fCDIOsyyHGBiPIawJoK0hh8rWEef07bNF2eesqb1KGHQtsq3wxvg9
         7CpBLPwxbR5RZaiXR7yUCFgbiMzShqskcT4rUV5EHFQu+FDiS+4JkMTC3xAWAOxeM8lo
         gI2ZJcZt44DrwaESQkZO5thmJrAPjKMEhSEYXAAQ7GAP7FcvytqLEOMohra8hcj2bLzC
         r4dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=uvvFWCc6vN9VzZMdz2W92zCLPitNQG3Ja+kmqXqI2Lw=;
        b=hvWKNdpVAk89QR1RGNSC0QRPerAxvcffw8X/D+VT9eZUaBL1eCjJSKoCwknBX8/b17
         dSYHmWW9oVWLFWSDAgnpMWdZPuJlAwkbsrNzHU7uCdMuKqyPNuzMG//0Q3eLKiL7nHKC
         XAnEKxJTft40xwImVp2bKdtw5MJwgR4tBbjpd+I/nDkK7cWX6rDRNVb7r48SjzJDJWrN
         ohhwm5Rr/LwZx5qZLR0Bipbppa3H/2shPNSi3afUpLKCb/O9SmTPQlGew9NSg/hu3S8/
         UyKyC8U+Yf6OLNOFFauCJojaenadS4Kl4rbRXHlys+7KHw/vNV+CPLl9Zu8bCdSI+ykv
         +COA==
X-Gm-Message-State: AHQUAubUSYWTBvQ51AJLH6qw1FAW1o7ZXTX9/chL1NcyRpb1OlnqXhlW
        cmmOVEO0QHANy3TVdZK5Rze0PbtGpWPPTnfu4qAHXdAh
X-Google-Smtp-Source: AHgI3IbKFyVqlMEaupsfyRSNF57uD7bbg/Twf15VkSek1q94Ja1ID7aCY5vIvP78bZk6GrNgKOZoOOZy3kiQ8/7S5gY=
X-Received: by 2002:a25:8242:: with SMTP id d2mr19987542ybn.507.1549657878880;
 Fri, 08 Feb 2019 12:31:18 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208201649.GA23657@fieldses.org>
In-Reply-To: <20190208201649.GA23657@fieldses.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Fri, 8 Feb 2019 22:31:07 +0200
Message-ID: <CAOQ4uxjV2FahWEtESJJRwz0kkBZxkKosCnURzj2HtuKNwhscng@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Jeff Layton <jlayton@kernel.org>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 8, 2019 at 10:17 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein wrote:
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
>
> How did I not know about i_readcount?  (Looking)  I guess it would mean
> adding some dependence on CONFIG_IMA, hm.
>

Yes, or we remove ifdef CONFIG_IMA from i_readcount.
I am not sure if the concern was size of struct inode
(shouldn't increase on 64bit arch) or the accounting on
open/close. The impact doesn't look significant (?)..

Thanks,
Amir.
