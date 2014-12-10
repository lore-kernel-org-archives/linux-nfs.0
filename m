Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:60612 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319AbaLJT32 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:29:28 -0500
Received: by mail-vc0-f175.google.com with SMTP id hy10so1764332vcb.34
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:29:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210183112.GE20235@fieldses.org>
References: <20141210183112.GE20235@fieldses.org>
Date: Wed, 10 Dec 2014 14:29:27 -0500
Message-ID: <CAHQdGtS9nEsbVJx372x_Zdwff+uBJY0NAp9QMF2ikYQsBgV5hg@mail.gmail.com>
Subject: Re: NFSv4 ACLs and umasks
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2014 at 1:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> We've gotten complaints that the effect of NFSv4 ACL inheritance is
> often overridden by common umask settings.
>
> Options:
>
>         - Do nothing, make sure the behavior's documented.  I don't
>           think this will make people happy, but I haven't tried to
>           figure out exactly what any of them are trying to do.

POSIX documents exactly how open(O_CREATE) works. I'd say that if
anything, we'd need to document how inherited ACLs are supposed to
work in this situation.

>
>         - Do as in NFSv3 and teach the client to skip the umask in the
>           case the parent directory has inheritable ACEs.  The following
>           patch is a proof-of-concept with some bugs.  It requires
>           documenting what we mean by "parent directory has interitable
>           ACEs"--I'm taking it to mean that the ACL has some ACE with
>           inheritance bits set, as that's simple to explain.  Drawbacks
>           include: requires fetching and caching an ACL on create;
>           there's a race between checking and creating; creates may fail
>           just because reading the ACL fails.

Yeah, this is a non-starter.

>         - New protocol: e.g. add a new attribute representing the
>           un-umasked mode, send both that and the regular mode on
>           create, let the server sort it out.
>
>         - Something else??: adopt some convention that uses redundant
>           information in a compound (multiple SETATTRs?) to communicate
>           umask to "in the know" servers without changing behavior on
>           existing servers.  Provide an "ignore the umask" mount option.
>           Maybe I'm missing a clever trick.
>
> Any ideas?

As I indicated above, I'd like to see a little more debate around how
we expect this whole ACL inheritance thing to work in practice. The
NFSv4 spec is all about enabling Windows-like ACL behaviour, but that
isn't necessarily the right thing for Linux applications.

IOW: before we discuss fixes, I'd like to understand how the current
behaviour is broken.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
