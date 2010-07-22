Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35247 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753510Ab0GVRxc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 13:53:32 -0400
In-Reply-To: <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop> <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Jul 2010 10:24:17 -0700
Message-ID: <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 10:03 AM, Jan Engelhardt <jengelh@medozas.de> wrote:
>
> I beg to differ. ctime is not completely useless. It reflects changes on
> the inode for when you don't you change the content.

Uh. Yes. Except that why is file metadata really different from file
data? Most people really don't care. And a lot of people have asked
for creation dates - and I seriously doubt that Windows people
complain a lot about the fact that there you have mtime for metadata
changes too.

The point being that Unix ctime semantics certainly have well-defined
semantics, but they are in no way "better" than having a real creation
time, and are often worse.

Just imagine what you could do as an MIS person if you actually had a
creation time you could somewhat trust? You talk about seeing somebody
change the permissions of /etc/passwd, but realistically, absent
preexisting semantics, who would really ask for that? The only reason
you mention that as an example of what you can do with ctime is that
that is indeed pretty much the _only_ thing you can do with ctime, and
it really isn't that useful.

In contrast, with a creation date, you see the difference between
people overwriting files by writing to them, or overwriting files by
creating a new one and moving it over the old one. At a guess, that
would be quite as useful to a sysadmin as ctime is now (my gut feel is
that it would be more so, but whatever).

IOW, there really isn't anything magically good about UNIX ctime
semantics, and in fact they are totally broken in the presence of
extended attributes (that's file data, but it only changes ctime? WTF
is up with that? Yes, I know why it happens, and it makes sense within
the insane unix ctime rules, but no way does it make sense in a bigger
picture unless you are in total denial and try to claim that xattrs
are just metadata despite having contents).

And yes, I am also sure that there are applications that do depend on
ctime semantics. Trond mentioned NFS serving, and that's unfortunate.
I bet there are others. That's inevitable when you have 40 years of
history. So I'm not claiming that re-using ctime is painfree, but for
somebody that cares about samba a lot, I bet it's a _lot_ better than
adding a new time that almost nobody actually supports as things stand
now.

Of people can just use xattrs and do it all entirely in user space. I
assume that's what samba does now, even outside of birthtime.

                     Linus
