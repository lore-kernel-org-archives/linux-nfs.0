Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53936 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab0G3VXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jul 2010 17:23:14 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
From: utz lehmann <lkml123@s2y4n2c.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
In-Reply-To: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEw  <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 30 Jul 2010 23:22:58 +0200
Message-ID: <1280524978.2452.9.camel@segv.aura.of.mankind>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-22 at 09:40 -0700, Linus Torvalds wrote:
> But the fact is, th Unix ctime semantics are insane and largely
> useless. There's a damn good reason almost nobody uses ctime under
> unix.
> 
> So what I'm suggesting is that we have a flag - either per-process or
> per-mount - that just says "use windows semantics for ctime".

When abusing an existing time stamp use atime not ctime please.
ctime has it's uses. atime was just a mistake and is nearly useless.

And with noatime we already have creation time semantics for atime.


utz


