Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52171 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260Ab0GVRQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:16:32 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
In-Reply-To: <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	 <20100722162712.GB10352@jeremy-laptop>
	 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	 <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Jul 2010 13:16:07 -0400
Message-ID: <1279818967.3621.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-22 at 19:03 +0200, Jan Engelhardt wrote:
> On Thursday 2010-07-22 18:40, Linus Torvalds wrote:
> 
> >On Thu, Jul 22, 2010 at 9:27 AM, Jeremy Allison <jra@samba.org> wrote:
> >> On Thu, Jul 22, 2010 at 08:47:46AM -0700, Linus Torvalds wrote:
> >>> Tell me why we shouldn't just do this right?
> >>
> >> No, ctime isn't the same as Windows "create time".
> >
> >Umm. What kind of reading problems do you guys have?
> >
> >I know effin well that ctime isn't the same as Windows create time.
> >THAT WAS MY POINT.
> >
> >But the fact is, th Unix ctime semantics are insane and largely
> >useless. There's a damn good reason almost nobody uses ctime under
> >unix.
> 
> I beg to differ. ctime is not completely useless. It reflects changes on 
> the inode for when you don't you change the content. It's like an mtime 
> for the metadata. It comes useful when you go around in your filesystem 
> trying to figure out who of your co-admins screwed up the permissions on 
> /etc/passwd... and if the mtime is the same as that of the last backup, 
> I can at least have a reasonable assurance that it was /only/ the 
> metadata that was tampered with. (SHA1 check, yeah yeah, costly on large 
> files.)

Errr... Only if you eliminate utimes() from your syscall table.
Otherwise it is trivial to reset the mtime after changing the file
contents.

Cheers
  Trond

