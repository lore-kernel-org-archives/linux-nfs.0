Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:61851 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab2JLXxJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 19:53:09 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so57641wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Oct 2012 16:53:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121012211701.GA8301@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 13 Oct 2012 08:52:44 +0900
Message-ID: <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Larry McVoy <lm@bitmover.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Guys, check this report from Larry out.

Also, why the *HELL* is that a BUG_ON() in the first place? Who was
the less-than-gifted person who decided "if this thing can happen,
let's just kill the whole machine"?

BUG_ON()'s are for machine-killing problems, not for some random
assert() in the code. If the thing can never happen, then the BUG_ON()
shouldn't have existed in the first place. And if you are worried
about it happening (like it clearly did for Larry), ou should have
handled it, since clearly this is *not* a machine-killing worthy
problem.

IOW, something like

        WARN_ON_ONCE(be32_to_cpu(stat) > NLM_LCK_DENIED_GRACE_PERIOD);

would have been way more appropriate. Let people know that there is a
problem, but don't kill the machine.

We have way too many people who seem to think that "I don't know what
I should do, so I'll just kill the machine" is a sane option. It's
not. Sure, often a BUG_ON() is survivable (just killing the process),
but in filesystem code there's usually a lock (or many) that tends to
make it problematic even when we can just kill the process, and often
causes these things to not even be logged very well.

Larry, the stack trace and registers would be useful. Picture or a
full dump of the BUG_ON() if it got logged? If it gets eaten by the
machine being unresponsive after the event and since you can reproduce
it, you could just try to change it to the WARN_ON_ONCE() above, and
then it should be easier to just get out of the dmesg, since hopefully
the machine stays up despite the odd status value..

                  Linus

On Sat, Oct 13, 2012 at 6:17 AM, Larry McVoy <lm@bitmover.com> wrote:
> I've got a reproduce-at-will crash, it's starting skype w/ /home nfs mounted
> on an x86 mac.  I can text you the stack trace if you like.
> --
> ---
> Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
