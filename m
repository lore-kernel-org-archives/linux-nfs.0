Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44078 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759399Ab0GVRd1 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:33:27 -0400
In-Reply-To: <20100722171224.GA8630@merit.edu>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop> <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<20100722171224.GA8630@merit.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Jul 2010 10:32:31 -0700
Message-ID: <AANLkTinmV7YuRof7dZGDmbXR_7J2hz2Z_DtsDu54dUGo@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
To: Jim Rees <rees@umich.edu>
Cc: Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 10:12 AM, Jim Rees <rees@umich.edu> wrote:
>
> I believe it was done that way so "dump" could backup just the inode and not
> the data if only the inode had changed.  Full history here:
>
> http://blog.plover.com/Unix/ctime.html

Yes, the dump reasoning makes sense, and that history also shows that
originally chmod just changed mtime (since that's the _sane_ thing to
do). So if it wasn't for dump - that nobody uses any more and that was
considered a hack even back when and never supported things like
xattrs etc - unix probably wouldn't have a ctime at all (or would have
implemented a "creation time" because people would have asked for it).

So I'm sure there are reasons for ctime. That just doesn't mean that
it's really "good", the same way there were reasons to name "creat()"
without the "e".

                                  Linus
