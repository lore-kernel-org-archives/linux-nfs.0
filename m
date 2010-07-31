Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50284 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172Ab0GaSGC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Jul 2010 14:06:02 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
From: utz lehmann <lkml123@s2y4n2c.de>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
In-Reply-To: <3533.1280595212@redhat.com>
References: <1280524978.2452.9.camel@segv.aura.of.mankind>
	 <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEw <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	 <3533.1280595212@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 31 Jul 2010 20:05:21 +0200
Message-ID: <1280599521.2720.5.camel@segv.aura.of.mankind>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-07-31 at 17:53 +0100, David Howells wrote:
> utz lehmann <lkml123@s2y4n2c.de> wrote:
> 
> > When abusing an existing time stamp use atime not ctime please.
> > ctime has it's uses. atime was just a mistake and is nearly useless.
> 
> CacheFiles currently uses atime to determine least-recently-usedness.

How does this works right with noatime or relatime (which is default)?

We had used FS-Cache with a few 10000s files cached. Doesn't it mean
that the cleanup has to stat them all?

Why didn't cachefilesd managed the cache index in a separate database
like other caches?


