Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:46315 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752809Ab2JMAr7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 20:47:59 -0400
Date: Fri, 12 Oct 2012 17:21:00 -0700
From: Larry McVoy <lm@bitmover.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121013002100.GB23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 08:52:44AM +0900, Linus Torvalds wrote:
> Also, why the *HELL* is that a BUG_ON() in the first place? Who was
> the less-than-gifted person who decided "if this thing can happen,
> let's just kill the whole machine"?

Ahh, I've been away from the kernel too long.  I miss that delicate
management touch.

> Larry, the stack trace and registers would be useful. Picture or a
> full dump of the BUG_ON() if it got logged? If it gets eaten by the
> machine being unresponsive after the event and since you can reproduce
> it, you could just try to change it to the WARN_ON_ONCE() above, and
> then it should be easier to just get out of the dmesg, since hopefully
> the machine stays up despite the odd status value..

Been a while since I've built a kernel and this is our production file
server, it goes down and our whole company stops.  As surprising as
it might sound, given git's success, we're still busy so crashing the
server isn't fun :)

pics of the stack trace at http://www.mcvoy.com/lm/nfs-lock-crash

-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
