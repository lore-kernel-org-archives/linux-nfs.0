Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54082 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab0GaIIK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Jul 2010 04:08:10 -0400
Date: Sat, 31 Jul 2010 10:08:07 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: utz lehmann <lkml123@s2y4n2c.de>
cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
  file stats available [ver #6]
In-Reply-To: <1280524978.2452.9.camel@segv.aura.of.mankind>
Message-ID: <alpine.LSU.2.01.1007311006070.19122@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>  <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>  <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>  <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEw  <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com> <1280524978.2452.9.camel@segv.aura.of.mankind>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Friday 2010-07-30 23:22, utz lehmann wrote:
>On Thu, 2010-07-22 at 09:40 -0700, Linus Torvalds wrote:
>> But the fact is, th Unix ctime semantics are insane and largely
>> useless. There's a damn good reason almost nobody uses ctime under
>> unix.
>> 
>> So what I'm suggesting is that we have a flag - either per-process or
>> per-mount - that just says "use windows semantics for ctime".
>
>When abusing an existing time stamp use atime not ctime please.
>ctime has it's uses. atime was just a mistake and is nearly useless.

MUAs make use of atime.

>And with noatime we already have creation time semantics for atime.

noatime was a late afterthought, and because it can interfere with
some programs, relatime came along too.
