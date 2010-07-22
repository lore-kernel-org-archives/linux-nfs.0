Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33819 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab0GVREB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:04:01 -0400
Date: Thu, 22 Jul 2010 19:03:57 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
  file stats available [ver #6]
In-Reply-To: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Message-ID: <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>  <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>  <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>  <E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>  <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thursday 2010-07-22 18:40, Linus Torvalds wrote:

>On Thu, Jul 22, 2010 at 9:27 AM, Jeremy Allison <jra@samba.org> wrote:
>> On Thu, Jul 22, 2010 at 08:47:46AM -0700, Linus Torvalds wrote:
>>> Tell me why we shouldn't just do this right?
>>
>> No, ctime isn't the same as Windows "create time".
>
>Umm. What kind of reading problems do you guys have?
>
>I know effin well that ctime isn't the same as Windows create time.
>THAT WAS MY POINT.
>
>But the fact is, th Unix ctime semantics are insane and largely
>useless. There's a damn good reason almost nobody uses ctime under
>unix.

I beg to differ. ctime is not completely useless. It reflects changes on 
the inode for when you don't you change the content. It's like an mtime 
for the metadata. It comes useful when you go around in your filesystem 
trying to figure out who of your co-admins screwed up the permissions on 
/etc/passwd... and if the mtime is the same as that of the last backup, 
I can at least have a reasonable assurance that it was /only/ the 
metadata that was tampered with. (SHA1 check, yeah yeah, costly on large 
files.)

>I personally think that Unix ctime is insane. There is no real reason
>why "write()" should change mtime, but "chmod" changes ctime.
