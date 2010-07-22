Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:42890 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab0GVQZ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 12:25:26 -0400
Date: Thu, 22 Jul 2010 18:25:25 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
  file stats available [ver #6]
In-Reply-To: <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
Message-ID: <alpine.LSU.2.01.1007221818460.21589@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>  <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>  <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>  <E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Thursday 2010-07-22 17:47, Linus Torvalds wrote:
>On Thu, Jul 22, 2010 at 8:36 AM, Volker Lendecke
><Volker.Lendecke@sernet.de> wrote:
>>
>> The nice thing about this is also that if this is supposed
>> to be fully usable for Windows clients, the birthtime needs
>> to be changeable. That's what NTFS semantics gives you, thus
>> Windows clients tend to require it.
>
>Ok. So it's not really a creation date, exactly the same way ctime
>isn't at all a creation date. [...]
>Tell me why we shouldn't just do this right?

Nobody said the c in ctime stands for creation. It stands for
change (you probably knew that).

$ touch this
$ stat this
  File: `this'
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: fh/15d  Inode: 106777647   Links: 1
Access: (0644/-rw-r--r--)  Uid: (25121/ jengelh)   Gid: (  100/   users)
Access: 2010-07-22 18:18:52.665480058 +0200
Modify: 2010-07-22 18:18:52.665480058 +0200
Change: 2010-07-22 18:18:52.665480058 +0200

# Only change inode, not content
$ chmod 600 this
$ stat this
  File: `this'
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: fh/15d  Inode: 106777647   Links: 1
Access: (0600/-rw-------)  Uid: (25121/ jengelh)   Gid: (  100/   users)
Access: 2010-07-22 18:18:52.665480058 +0200
Modify: 2010-07-22 18:18:52.665480058 +0200
Change: 2010-07-22 18:18:58.533436339 +0200


(Solaris exhibits the very same kind of behavior.)
