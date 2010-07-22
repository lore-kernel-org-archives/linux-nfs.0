Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:43426 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753596Ab0GVNFY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 09:05:24 -0400
Date: Thu, 22 Jul 2010 15:05:22 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>
cc: David Howells <dhowells@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
In-Reply-To: <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
Message-ID: <alpine.LSU.2.01.1007221457120.25261@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thursday 2010-07-22 14:17, Volker Lendecke wrote:
>On Thu, Jul 22, 2010 at 01:14:47PM +0100, David Howells wrote:
>> Jan Engelhardt <jengelh@medozas.de> wrote:
>> 
>> > Linux already has a creation time field, it's called otime (there is no "b"
>> > in "creation"), and you will find scattered fragments of that all over the
>> > kernel (foremost, fs/jfs/, now btrfs, and I also notice sysvipc having
>> > something with that name).
>> 
>> It is?  It's called crtime in Ext4.  st_btime, however, would be compatible
>> with BSD's stat, and Samba would just use it by way of autoconf magic if it
>> appeared.

Of course you can find remnants of btime in Linux's BSD-style task 
accounting, but Linux always looked more like SysV than BSD, speaking 
for otime. And if you are using autoconf, the cost of using otime over 
btime seems the same.

>Samba has the following check:
>
># recent FreeBSD, NetBSD have creation timestamps called birthtime:             
>AC_CHECK_MEMBERS([struct stat.st_birthtimespec.tv_nsec])
>AC_CHECK_MEMBERS([struct stat.st_birthtime], AC_CHECK_MEMBERS([struct stat.st_birthtimensec]))
>
>and the supporting code around that. "birth" might also be
>where the "b" comes from :-)

Well, in all reference to the Matrix movie, files aren't born. Except 
for Directory Default ACLs and possibly security labels, they usually 
don't inherit either :)  And on a CS level, it's more like copy than 
inherit, because if the parent changes, the file does not (with the 
potential exception of security relabeling, bla).
