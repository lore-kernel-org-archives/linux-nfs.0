Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47202 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752526Ab0GVQsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 12:48:35 -0400
In-Reply-To: <20100722162712.GB10352@jeremy-laptop>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Jul 2010 09:40:22 -0700
Message-ID: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
To: Jeremy Allison <jra@samba.org>
Cc: Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 9:27 AM, Jeremy Allison <jra@samba.org> wrote:
> On Thu, Jul 22, 2010 at 08:47:46AM -0700, Linus Torvalds wrote:
>> Tell me why we shouldn't just do this right?
>
> No, ctime isn't the same as Windows "create time".

Umm. What kind of reading problems do you guys have?

I know effin well that ctime isn't the same as Windows create time.
THAT WAS MY POINT.

But the fact is, th Unix ctime semantics are insane and largely
useless. There's a damn good reason almost nobody uses ctime under
unix.

So what I'm suggesting is that we have a flag - either per-process or
per-mount - that just says "use windows semantics for ctime".

And yes, I'm very aware that the "c" in ctime doesn't stand for
"create". But anybody who points that out is - once more - totally
missing the point. My point is that we have three timestamps, and
windows wants three timestamps (somebody claims that NTFS has four
timestamps, but the Windows file time access functions certainly only
shows three times, so any potential extra on-disk times have no
relevance because they are invisible to pretty much everybody). We can
have unix semantics for mtime/atime/ctime, or we can have windows
semantics for those three values.

So let's say that we introduce a mount flag that says
"ctime=winctime", which basically just sets a flag that instead of
changing ctime on chmod/chown/etc, it just changes mtime instead (or,
as mentioned, we could make it a process flag instead).

Let's face it, Unix semantics are not sacred.  Especially not
something like ctime, which is pretty damn useless. If you're a samba
server, why not just say "let's do ctime the way windows does creation
times", and let it be at that?

I personally think that Unix ctime is insane. There is no real reason
why "write()" should change mtime, but "chmod" changes ctime. It was
just a random decision way back when, and it's clearly not what samba
wants, and it's equally clearly not what even most _unix_ people want
(just google for "ctime" and "creation time", and watch the confusion
- exactly because unix semantics are simply _random_ and odd semantics
in this area)

I would not be at all surprised if it turns out that people might want
to really turn ctime into creation time (with the mount flag or
whatever) even if they are _not_ running samba.

An added issue is that most filesystems simply don't have more than
three times (and some obviously have not even that, but that's true in
Windows too). So re-using ctime actually means that this scheme would
work a whole lot better than some crazy xstat() interface that doesn't
support common filesystems anyway.

                                         Linus
