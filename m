Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48444 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343Ab0GVPQI convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 11:16:08 -0400
In-Reply-To: <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Jul 2010 08:14:42 -0700
Message-ID: <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
To: Volker.Lendecke@sernet.de
Cc: David Howells <dhowells@redhat.com>, Jan Engelhardt <jengelh@medozas.de>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 5:17 AM, Volker Lendecke
<Volker.Lendecke@sernet.de> wrote:
> On Thu, Jul 22, 2010 at 01:14:47PM +0100, David Howells wrote:
>> Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>> > Linux already has a creation time field, it's called otime (there is no "b"
>> > in "creation"), and you will find scattered fragments of that all over the
>> > kernel (foremost, fs/jfs/, now btrfs, and I also notice sysvipc having
>> > something with that name).
>>
>> It is?  It's called crtime in Ext4.  st_btime, however, would be compatible
>> with BSD's stat, and Samba would just use it by way of autoconf magic if it
>> appeared.
>
> Samba has the following check:
>
> # recent FreeBSD, NetBSD have creation timestamps called birthtime:
> AC_CHECK_MEMBERS([struct stat.st_birthtimespec.tv_nsec])
> AC_CHECK_MEMBERS([struct stat.st_birthtime], AC_CHECK_MEMBERS([struct stat.st_birthtimensec]))
>
> and the supporting code around that. "birth" might also be
> where the "b" comes from :-)

Oh wow. And all of this just convinces me that we should _not_ do any
of this, since clearly it's all totally useless and people can't even
agree on a name.

Let's wait five years and see if there is actually any consensus on it
being needed and used at all, rather than rush into something just
because "we can".

                       Linus
