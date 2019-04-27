Return-Path: <SRS0=TJwb=S5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB359C43218
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 20:16:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78A082077B
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 20:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YTdcDCKF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726198AbfD0UQz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Apr 2019 16:16:55 -0400
Received: from mail-yw1-f68.google.com ([209.85.161.68]:43064 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726088AbfD0UQz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Apr 2019 16:16:55 -0400
Received: by mail-yw1-f68.google.com with SMTP id w196so2378189ywd.10;
        Sat, 27 Apr 2019 13:16:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=X7nIKq30gmNteOhuVTtXwzawEY+p5Z4tJsssF9WMYtM=;
        b=YTdcDCKFP8Wusps0xQ2BYOOkrKX2CrNRaEUAoW3pFyzoE7aVcc7edu59oCKcG24nJ+
         t/Me5myN59chQFA34FhFOmQG1fmH2ZOk3fofbvgNKEyfaxIvAbNrYBj6cWNXoAUlfTdU
         GLEsxehnNKqlNZKGcakxWNaPTWq+XZkgb6nFap4fcoBc3bN3Odds9I+xneLqT9cnmcq5
         Glw9qWjpfwvK1tfe4ib6jpxC0U3l8BlRPcjo7OaDrS0qH5diX6o86iZAbSaLPRGsBlnR
         OlLgPppHxBGwjqbWnEeA5Bx7lZcjiD93pss3FBIie8vu6FpVnjFO9uuib+AigfiW1t2H
         yroQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=X7nIKq30gmNteOhuVTtXwzawEY+p5Z4tJsssF9WMYtM=;
        b=YyPMC2DOdHXFw9pkNVN+IYEYCpoYickWd+FWIhj15QS4cYyTuww+ww+enRldKZaOJF
         lJ++S6FppRVyWoIyUAQE4rJxvjE6lWHjT65C91YZgGfdIlSryqNVlnBCX6nF4gb9xYW7
         ZPd/uCgMvcHIrvz0sV7mXawmbeb5WAZlDBE2Z1rPaQMKqazMsyg1MrWiuGlmQ2IuZGh+
         7BFmj2slqO4BjiLGDONmrACs5NTCBLqIciQvOVZJ0idr4gZUse7yGyESvJrX/HfmKT5/
         pz1sFUJfbWaDG0zhXAXmmEsUWMxTnzD4RSgoD4E4AaAGjO0CGYNkFCuc7iLilQK7RO+A
         BiiQ==
X-Gm-Message-State: APjAAAWUNzP/KV+qq1XgAtNHymO3NwfGpoTbuN5VhyCSFSKK51aMeONK
        r97Gb15//6c1VGtQv89TB+Uq4MxYj8qhGy4ZrTQ=
X-Google-Smtp-Source: APXvYqyMiv4Q75Gsfnaru5UqCRjb6WzLYfjr5aY84foN+Agu0n9ANzxebHWhVCwNu6rZLZknxtXrOi9aQoQvPkCGksc=
X-Received: by 2002:a81:7c4:: with SMTP id 187mr44913328ywh.176.1556396214239;
 Sat, 27 Apr 2019 13:16:54 -0700 (PDT)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <930108f76b89c93b2f1847003d9e060f09ba1a17.camel@kernel.org>
 <CAOQ4uxgQsRaEOxz1aYzP1_1fzRpQbOm2-wuzG=ABAphPB=7Mxg@mail.gmail.com>
 <20190426140023.GB25827@fieldses.org> <CAOQ4uxhuxoEsoBbvenJ8eLGstPc4AH-msrxDC-tBFRhvDxRSNg@mail.gmail.com>
 <20190426145006.GD25827@fieldses.org> <e69d149c80187b84833fec369ad8a51247871f26.camel@kernel.org>
In-Reply-To: <e69d149c80187b84833fec369ad8a51247871f26.camel@kernel.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Sat, 27 Apr 2019 16:16:42 -0400
Message-ID: <CAOQ4uxjt+MkufaJWoqWSYZbejWa1nJEe8YYRroEBSb1jHjzkwQ@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     Jeff Layton <jlayton@kernel.org>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Volker.Lendecke@sernet.de,
        samba-technical <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[adding back samba/nfs and fsdevel]

On Fri, Apr 26, 2019 at 6:22 PM Jeff Layton <jlayton@kernel.org> wrote:
>
> On Fri, 2019-04-26 at 10:50 -0400, J. Bruce Fields wrote:
> > On Fri, Apr 26, 2019 at 04:11:00PM +0200, Amir Goldstein wrote:
> > > On Fri, Apr 26, 2019, 4:00 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > > On Fri, Apr 26, 2019 at 03:50:46PM +0200, Amir Goldstein wrote:
> > > > > On Fri, Feb 8, 2019, 5:03 PM Jeff Layton <jlayton@kernel.org> wrote:
> > > > > > Share/deny open semantics are pretty similar across NFS and SMB (by
> > > > > > design, really). If you intend to solve that use-case, what you really
> > > > > > want is whole-file, shared/exclusive locks that are set atomically with
> > > > > > the open call. O_EXLOCK and O_SHLOCK seem like a reasonable fit there.
> > > > > >
> > > > > > Then you could have SMB and NFS servers set these flags when opening
> > > > > > files, and deal with the occasional denial at open time. Other
> > > > > > applications won't be aware of them of course, but that's probably fine
> > > > > > for most use-cases where you want this sort of protocol interop.
> > > > >
> > > > > Sorry for posting off list. Airport emails...
> > > > > I looked at implemeting O_EXLOCK and O_SHLOCK and it looks doable.
> > > > >
> > > > > I was wondering if there is an inherent reason not to allow an exclusive
> > > > > lock on a file that is open read-only.
> > > > >
> > > > > Samba seems to need it and currently flock and ofd locks won't allow it.
> > > > > Do you thing it will be ok to allow it with O_EXLOCK?
> > > >
> > > > Somebody could deny everyone access to a shared resource that everyone
> > > > needs to make progress, like /etc/passwd or a shared library.
> > > >
> > > > Have you looked at Pavel Shilovsky's O_DENY patches?  He had the feature
> > > > off by default, with a mount option provided to turn it on.
> > > >
> > >
> > > O_EXLOCK is advisory. It only aquired flock or ofd lock atomically with
> > > open.
> >
> > Whoops, got it.
> >
> > Is that really adequate for open share locks, though?
> >
> > I assumed that Windows apps depend on the assumption that they're
> > mandatory.  So e.g. if you can get a DENY_READ open on a shared library
> > then you know you can update it without the risk of making someone else
> > crash.
> >
>
> I think this is (slightly) better than doing it internally like we do
> today and would give you coherent locking between NFS and SMB. Other
> applications wouldn't see them, but for a NAS-style deployment, that's
> probably ok.
>

We can do a little bit better.
We can make sure that O_DENY_WRITE (named for convenience) fails
if file is currently open for write by anyone and similarly for O_DENY_READ.
But if we cannot deny future non-cooperative opens what's the point?....

> Any open by samba or nfsd would need to start setting O_SHLOCK, and deny
> mode opens would have to set O_EXLOCK. We would actually need 2 per
> inode though (one for read and one for write).
>

...the point is that O_DENY_NONE does not need to be implemented with
a new type of lock object (O_WR_SHLOCK) its enough that it checks there
are no relevant exclusive locks and the then inode->i_writecount and
inode->i_readcount already provide enough context to cooperate with
O_DENY_WRITE and O_DENY_READ.

I need to see if incrementing inode->i_readcount on O_RDWR opens is
possible (right now it only counts O_RDONLY opens).

> I think these should probably be in their own "namespace" too. They
> could use the same semantics as flock, but should sit on their own list
> in file_lock_context.
>

I would much rather that they didn't. The reason is that new open flags
are a backward compat problem. The way I want to solve it is this API:

// On new kernel this will acquire OFD F_WRLCK atomically...
fd = open(..., O_RDWR | O_EXLOCK);
// ...check if it did acquire OFD lock
fcntl(fd,  F_OFD_GETLK, ...);

We'd need at least one new l_type F_EX_RDLCK and maybe also a new
semantic F_EX_RDWRLCK, although similar in conflicts to F_WRLCK it can be
acquired without FMODE_WRITE. Though I personally thing we can do without
it if the only way to acquire F_WRLCK on readonly file is via new open flag.

> That said, we could also look at a vfs-level mount option that would
> make the kernel enforce these for any opener. That could also be useful,
> and shouldn't be too hard to implement. Maybe even make it a vfsmount-
> level option (like -o ro is).
>

Yeh, I am humbly going to leave this struggle to someone else.
Not important enough IMO and completely independent effort to the
advisory atomic open&lock API.

> If you're denied, what error should you get back when you try to open
> it? It should be something distinct. We may even want to add new error
> codes for this.

IMO EBUSY does the job. Its distinct because open is not expected
to return EBUSY for regular files/dirs and when open is expected to
return EBUSY for blockdev its for the exact same use case (i.e.
exclusive write open is acquired by userspace tools).

Thanks,
Amir.
