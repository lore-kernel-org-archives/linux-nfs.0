Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54970 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756634Ab0GVSpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 14:45:09 -0400
In-Reply-To: <4C488C41.60002@panasas.com>
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
	<4C488C41.60002@panasas.com>
Date: Thu, 22 Jul 2010 14:45:07 -0400
Message-ID: <AANLkTilU5QLBzOgwpmYRP5aZglOMta2iMCaNk62tiUIB@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
From: Greg Freemyer <greg.freemyer@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 2:21 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> On Jul. 22, 2010, 20:24 +0300, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> On Thu, Jul 22, 2010 at 10:03 AM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>>
>>> I beg to differ. ctime is not completely useless. It reflects changes on
>>> the inode for when you don't you change the content.
>>
>> Uh. Yes. Except that why is file metadata really different from file
>> data? Most people really don't care. And a lot of people have asked
>> for creation dates - and I seriously doubt that Windows people
>> complain a lot about the fact that there you have mtime for metadata
>> changes too.
>>
>> The point being that Unix ctime semantics certainly have well-defined
>> semantics, but they are in no way "better" than having a real creation
>> time, and are often worse.
>
> Yeah, having create time would be important.
> That said, having a non user-settable modify timestamp is crucial
> for quickly determining whether a file has changed.

How would "cp --archive" and a host of backup/restore tools work
without user-settable modify timestamps?

Or are you proposing another timestamp?  I do computer forensics, I
like timestamps, but enough is enough.

Greg
