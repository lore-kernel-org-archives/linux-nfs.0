Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36051 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbcLEPgE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 10:36:04 -0500
Received: by mail-oi0-f67.google.com with SMTP id u15so37017127oie.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2016 07:36:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161205151933.GA17517@fieldses.org>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de> <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 5 Dec 2016 16:36:03 +0100
Message-ID: <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Patrick Plagwitz <Patrick_Plagwitz@web.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 5, 2016 at 4:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> Can NFS people comment on this?  Where does the nfs4_acl come from?
>
> This is the interface the NFS client provides for applications to modify
> NFSv4 ACLs on servers that support them.

Fine, but why are we seeing this xattr on exports where no xattrs are
set on the exported fs?

>> What can overlayfs do if it's a non-empty ACL?
>
> As little as possible.  You can't copy it up, can you?  So any attempt
> to support it is going to be incomplete.

Right.

>
>> Does knfsd translate posix ACL into NFS acl?  If so, we can translate
>> back.  Should we do a generic POSIX<->NFS acl translator?
>
> knsd does translate between POSIX and NFSv4 ACLs.  It's a complicated

This does explain the nfs4_acl xattr on the client.  Question: if it's
empty, why have it at all?

> algorithm, and lossy (in the NFSv4->POSIX direction).  The client
> developers have been understandably reluctant to have anything to do
> with it.
>
> So, I think listxattr should omit system.nfs4_acl, and attempts to
> set/get the attribute should error out.  The same should apply to any
> "system." attribute not supported by both filesystems, I think?

Basically that's what happens now.  The problem is that nfsv4 mounts
seem always have these xattrs, even when the exported fs doesn't have
anything.

We could do the copy up even if the NFS4->POSIX translation was
possible (which is the case with POSIX ACL translated by knfsd).  We'd
just get back the original ACL, so that's OK.  NFS is only supported
as lower (read-only) layer, so we don't care about changing the ACL on
the server.

Thanks,
Miklos
