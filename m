Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:62023 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab2JNTox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 15:44:53 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so197466wib.1
        for <linux-nfs@vger.kernel.org>; Sun, 14 Oct 2012 12:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121014193905.GC32420@fieldses.org>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com> <20121014193905.GC32420@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 14 Oct 2012 12:44:32 -0700
Message-ID: <CA+55aFyqy_unZJFpg2Cax=VHf-ZkwtM2fq=K3VSvKXT6NRVkbQ@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Bruce Fields <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Larry McVoy <lm@bitmover.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 14, 2012 at 12:39 PM, Bruce Fields <bfields@fieldses.org> wrote:
>
> Can't it be called from the rpciod workqueue?  I'm not sure what happens
> when we hit a BUG there.

>From personal experience, I can say that killing a workqueue will
cause tons of *very* non-obvious downstream errors, so yeah, if it's
called that way, I could easily see watchdogs firing etc.

> It looks like a bunch of BUG_ON's got added with an xdr rewrite in
> 2b061f9ef216b6d229b06267f188167fd6ab3d9b.  Maybe Chuck or someone should
> do a 'git grep BUG fs/lockd' and figure out what those should be
> instead?

Even just replacing them with a WARN_ON_ONCE() would probably help
things. Because BUG_ON() really *really* should be a "last possible
case" thing.

               Linus
