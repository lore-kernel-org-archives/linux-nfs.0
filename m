Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:50444 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555Ab0GVPql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 11:46:41 -0400
Date: Thu, 22 Jul 2010 17:46:39 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
  file stats available [ver #6]
In-Reply-To: <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
Message-ID: <alpine.LSU.2.01.1007221740570.12308@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>  <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>  <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Thursday 2010-07-22 17:14, Linus Torvalds wrote:
>>>
>>> It is?  It's called crtime in Ext4.  st_btime, however, would be compatible
>>> with BSD's stat, and Samba would just use it by way of autoconf magic if it
>>> appeared.
>>
>> Samba has the following check:
>> # recent FreeBSD, NetBSD have creation timestamps called birthtime:
>> AC_CHECK_MEMBERS([struct stat.st_birthtimespec.tv_nsec])
>> AC_CHECK_MEMBERS([struct stat.st_birthtime], AC_CHECK_MEMBERS([struct stat.st_birthtimensec]))
>>
>> and the supporting code around that. "birth" might also be
>> where the "b" comes from :-)
>
>Oh wow. And all of this just convinces me that we should _not_ do any
>of this, since clearly it's all totally useless and people can't even
>agree on a name.
>
>Let's wait five years and see if there is actually any consensus on it
>being needed and used at all, rather than rush into something just
>because "we can".

There just is no way currently to store creation times. Abusing ctimes
for write-once archives also stops working once you rsync it from one
place to another. (Which brings me to the side question of why
the ctime isn't settable through futimesnat.)
