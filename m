Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:41124 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab0GVSlF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 14:41:05 -0400
In-Reply-To: <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
	<AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
Date: Thu, 22 Jul 2010 14:41:01 -0400
Message-ID: <AANLkTiljnpUGmP-DYW_5CNtRmlL8rK1W2c8ncrin92dC@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
From: Greg Freemyer <greg.freemyer@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 1:24 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:

<snip>

> and I seriously doubt that Windows people
> complain a lot about the fact that there you have mtime for metadata
> changes too.

But Windows doesn't work that way for I'm fairly sure.

Window's mtime is only affected by file content updates.  (I don't
know about xattr updates).

If you look at the first and fourth rows of the table at:

http://blogs.sans.org/computer-forensics/2010/04/12/windows-7-mft-entry-timestamp-properties/

You see that there are a number of activities that update the "$STD
Info MFT Entry Modified Field" that don't update the "$STD Info
Modification Time"

Again, "$STD Info MFT Entry Modified Field" has semantics close to linux ctime.

And "$STD Info  Modification Time" similar to mtime.

I don't know if there are APIs to present MFT Entry Modified to user
space or if Samba uses that info.  I just know it's part of the
on-disk NTFS filesystem data.

Greg
