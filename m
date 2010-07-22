Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.SerNet.de ([193.175.80.2]:46505 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865Ab0GVPhN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 11:37:13 -0400
Date: Thu, 22 Jul 2010 17:36:59 +0200
Date: Thu, 22 Jul 2010 17:36:59 +0200
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, Jan Engelhardt <jengelh@medozas.de>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Reply-To: Volker.Lendecke@SerNet.DE
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
Message-Id: <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 08:14:42AM -0700, Linus Torvalds wrote:
> > # recent FreeBSD, NetBSD have creation timestamps called birthtime:
> > AC_CHECK_MEMBERS([struct stat.st_birthtimespec.tv_nsec])
> > AC_CHECK_MEMBERS([struct stat.st_birthtime], AC_CHECK_MEMBERS([struct stat.st_birthtimensec]))
> >
> > and the supporting code around that. "birth" might also be
> > where the "b" comes from :-)
> 
> Oh wow. And all of this just convinces me that we should _not_ do any
> of this, since clearly it's all totally useless and people can't even
> agree on a name.
> 
> Let's wait five years and see if there is actually any consensus on it
> being needed and used at all, rather than rush into something just
> because "we can".

The nice thing about this is also that if this is supposed
to be fully usable for Windows clients, the birthtime needs
to be changeable. That's what NTFS semantics gives you, thus
Windows clients tend to require it.

Just as a hint, nothing that Linux should necessarily have
to be bothered with, this is Samba's duty :-)

Volker
