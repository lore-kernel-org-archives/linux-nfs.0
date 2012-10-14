Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35864 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab2JNVFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 17:05:40 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so1335591wib.1
        for <linux-nfs@vger.kernel.org>; Sun, 14 Oct 2012 14:05:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2CAF58DA-E925-47F5-B1FD-DC86EF565125@oracle.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121014193905.GC32420@fieldses.org> <2CAF58DA-E925-47F5-B1FD-DC86EF565125@oracle.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 14 Oct 2012 14:05:19 -0700
Message-ID: <CA+55aFz=1yFc-i4gmfGbyATvSNmPheedb6qF38ditHrdvtbdFQ@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Larry McVoy <lm@bitmover.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 14, 2012 at 1:55 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> I think range-check assertions in the XDR code are valuable.  Whether they are done via BUG_ON or WARN_ON_ONCE is a matter of priority:

Bullshit.

> BUG_ON forces you to notice the problem and address it, while WARN_ON allows the system to continue operating with the bug, but the bug can be ignored (or the WARN_ON simply removed because it is annoying).

Bullshit again.

I don't think you've ever even *seen* a BUG_ON() fire in critical
code, have you? It's not pretty.

It doesn't "force you to notice the problem". Rather the reverse. It
often causes a totally silent death of the machine, and/or
scrolled-off messages that you never see, exactly because the thing
you *do* see is the fallout from the developer having done something
incredibly stupid.

Really.

There's a reason I say that BUG_ON() is only for those cases where the
machine is already totally unrecoverable. It *will* screw the machine
up, usually in ways that makes it totally undebuggable.

So please stop making excuses for it. It's bad. It isn't some kind of
"this forces you to notice". Really. The fact that you think it is
just shows that you probably never saw them actually trigger, or you
only saw them trigger in code that happened to not hold any locks etc.

So shove those BUG_ON()'s where the sun don't shine. They make things
*worse*, not better. They are valid for some very core code where a
major internal data structure is totally scrogged, but they are
*never* valid for some kind of random assert(). Exactly because
BUG_ON() is such a big hammer that using it is more likely to
*destroy* the data you want to assert and show the user, rather than
actually showing the user anything at all.

             Linus
