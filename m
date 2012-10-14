Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50831 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab2JNWyX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 18:54:23 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so1362859wib.1
        for <linux-nfs@vger.kernel.org>; Sun, 14 Oct 2012 15:54:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F6AF04FD-1849-408B-A964-DDC386CA4654@oracle.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121014193905.GC32420@fieldses.org> <2CAF58DA-E925-47F5-B1FD-DC86EF565125@oracle.com>
 <CA+55aFz=1yFc-i4gmfGbyATvSNmPheedb6qF38ditHrdvtbdFQ@mail.gmail.com> <F6AF04FD-1849-408B-A964-DDC386CA4654@oracle.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 14 Oct 2012 15:54:02 -0700
Message-ID: <CA+55aFx-4FNQpmtLsVmVNufk0nVxqvJ=3wNrfAt2aK9=F7U8Cg@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Larry McVoy <lm@bitmover.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 14, 2012 at 3:32 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> The client-side XDR encoder functions don't return a return value.  Upper layers can not find out there was a problem if marshalling fails.  That's why we use BUG_ON here

The above is STILL pure bull.

Use a WARN_ON_ONCE() so that people can actually *report* the bugs
sanely (see this very thread about why BUG_ON causes problems for
reporters).

If you are so damned certain that you mustn't continue, make the damn
function return the error code, and stop marshalling. If you don't do
error handling, that's no excuse for BUG_ON.

And if you think the code gets too complicated from that, then that
*still* isn't a reason to do BUG_ON(). See above.

What part of this thread do you have problems acknowledging? The
undeniable *facts* (that you seem to be in total denial about) from
this very thread are:

 - the BUG_ON() caused an otherwise *benign* bug to result in a unusable system.

   Your "to avoid crapping on other parts of memory or posting data"
argument is pretty much f*cked up, when you instead cause a fatal
error!

 - the BUG_ON() caused the debug data to be almost totally useless.

   Look at the screen shots. Look at the lack of debug info. Just look at it.

Why are you denying reality, and bringing up arguments that are purely
theoretical and shown to be wrong in reality?

BUG_ON() in a filesystem or random service is pure and utter garbage.
There is no way it is ever the right thing to do. Get rid of them, and
stop posting excuses for them.

Christ, we had THIS VERY SAME issue not more than a month or two ago,
when the locking code had a BUG() in it that turned what should have
been a simple error return into a DoS attack by normal users. See
commit 8d657eb3b438.

The whole "it's better to BUG_ON() than do something unexpected" is a
disease. It may be well-intentioned, but the road to hell is paved
with good intentions, and saying "I don't want to do odd things" is
stupid to do, when the BUG_ON() itself just causes *different*
catastrophic odd things to happen.

Really: killing the machine IS NOT ANY BETTER than sending out odd packets.

             Linus
