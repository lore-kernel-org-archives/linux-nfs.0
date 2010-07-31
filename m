Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:49380 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756052Ab0GaOoT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Jul 2010 10:44:19 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
From: utz lehmann <lkml123@s2y4n2c.de>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
In-Reply-To: <alpine.LSU.2.01.1007311006070.19122@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEw  <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	 <1280524978.2452.9.camel@segv.aura.of.mankind>
	 <alpine.LSU.2.01.1007311006070.19122@obet.zrqbmnf.qr>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 31 Jul 2010 16:43:53 +0200
Message-ID: <1280587433.3284.10.camel@segv.aura.of.mankind>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-07-31 at 10:08 +0200, Jan Engelhardt wrote:
> >When abusing an existing time stamp use atime not ctime please.
> >ctime has it's uses. atime was just a mistake and is nearly useless.
> 
> MUAs make use of atime.

I know mutt uses atime to detect new messages. But there are better and
more reliable ways to do this.

> 
> >And with noatime we already have creation time semantics for atime.
> 
> noatime was a late afterthought, and because it can interfere with
> some programs, relatime came along too.

There are people who prefer noatime over relatime.

Using an existing time stamp for creation time is a bad idea IMHO. But
when doing this use the least important one. Which is atime. For example
ctime is used by backup programs.

Anyway when we want to support creation time it should be an additional
time stamp.


utz


