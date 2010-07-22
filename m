Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:52222 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755563Ab0GVSPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 14:15:51 -0400
Date: Thu, 22 Jul 2010 11:15:49 -0700
From: Jeremy Allison <jra@samba.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100722181549.GD32008@samba1>
Reply-To: Jeremy Allison <jra@samba.org>
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
 <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
 <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 10:24:17AM -0700, Linus Torvalds wrote:
> 
> And yes, I am also sure that there are applications that do depend on
> ctime semantics. Trond mentioned NFS serving, and that's unfortunate.
> I bet there are others. That's inevitable when you have 40 years of
> history. So I'm not claiming that re-using ctime is painfree, but for
> somebody that cares about samba a lot, I bet it's a _lot_ better than
> adding a new time that almost nobody actually supports as things stand
> now.

Samba mostly ignores ctime, for just the reasons you mention.
But re-using ctime as create time will lead to more horrible
confusion (IMHO).

Easier to add a btime field to stat (or whatever you want to
call it), especially as some of the filesystems already support it,
the code for it exists inside Samba and is working on other UNIX-style
OS'es, and for filesystems that don't support it, just return
zero or -1 in that field (which we already ignore).

> Of people can just use xattrs and do it all entirely in user space. I
> assume that's what samba does now, even outside of birthtime.

Yep. We even have to do that on systems with an immutable
btime to get Windows semantics.

Jeremy.
