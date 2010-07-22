Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28110 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752067Ab0GVTxk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 15:53:40 -0400
Message-ID: <4C48A1BE.8010503@panasas.com>
Date: Thu, 22 Jul 2010 22:53:34 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Greg Freemyer <greg.freemyer@gmail.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 	file stats available [ver #6]
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>	<30448.1279800887@redhat.com>	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>	<20100722162712.GB10352@jeremy-laptop>	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>	<alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>	<AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>	<4C488C41.60002@panasas.com> <AANLkTilU5QLBzOgwpmYRP5aZglOMta2iMCaNk62tiUIB@mail.gmail.com>
In-Reply-To: <AANLkTilU5QLBzOgwpmYRP5aZglOMta2iMCaNk62tiUIB@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jul. 22, 2010, 21:45 +0300, Greg Freemyer <greg.freemyer@gmail.com> wrote:
> On Thu, Jul 22, 2010 at 2:21 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On Jul. 22, 2010, 20:24 +0300, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>>> On Thu, Jul 22, 2010 at 10:03 AM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>>>
>>>> I beg to differ. ctime is not completely useless. It reflects changes on
>>>> the inode for when you don't you change the content.
>>>
>>> Uh. Yes. Except that why is file metadata really different from file
>>> data? Most people really don't care. And a lot of people have asked
>>> for creation dates - and I seriously doubt that Windows people
>>> complain a lot about the fact that there you have mtime for metadata
>>> changes too.
>>>
>>> The point being that Unix ctime semantics certainly have well-defined
>>> semantics, but they are in no way "better" than having a real creation
>>> time, and are often worse.
>>
>> Yeah, having create time would be important.
>> That said, having a non user-settable modify timestamp is crucial
>> for quickly determining whether a file has changed.
> 
> How would "cp --archive" and a host of backup/restore tools work
> without user-settable modify timestamps?
> 
> Or are you proposing another timestamp?  I do computer forensics, I
> like timestamps, but enough is enough.

mtime and atime are already user settable and archive programs use
this on the destination, but ctime would be different after
copy/restore.

When updating the archive, just comparing mtime to determine if the source
changed is problematic as it can be set to any value after the change,
but src.ctime would be greater than dest.ctime in this case.

With posix semantics (http://www.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap04.html#tag_04_07)
this is not perfect either as there can be false-positives when the file stat changed but
the file has not, e.g. when st_nlink changed.

Benny

> 
> Greg
