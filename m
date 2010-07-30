Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933309Ab0G3SkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 14:40:15 -0400
Date: Fri, 30 Jul 2010 14:38:19 -0400
To: Neil Brown <neilb@suse.de>
Cc: David Howells <dhowells@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100730183819.GE21729@fieldses.org>
References: <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
 <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
 <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
 <13591.1280338082@redhat.com>
 <20100729090401.4b0a21f8@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100729090401.4b0a21f8@notabene>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 29, 2010 at 09:04:01AM +1000, Neil Brown wrote:
> On Wed, 28 Jul 2010 18:28:02 +0100
> David Howells <dhowells@redhat.com> wrote:
> 
> > Neil Brown <neilb@suse.de> wrote:
> > 
> > > ctime and mtime have real cache-coherence semantics which require them being
> > > updated by the kernel (whether the cache is on an NFS client, in a backup
> > > archive, or in a .o translation of a .c file).
> > 
> > So does creation time, at least for CIFS caching.  Creation time has potential
> > for spotting when the object at a pathname has changed for something else,
> > given the lack of inode number and inode generation from windows servers.
> > Creation time gives us one more datum to use.
> 
> This justifies for me why a CIFS client would want to extract the
> creation-time from the CIFS protocol, but not why you want to expose it via a
> generic interface.
> The kernel/filesystem doesn't need to maintain creation-time to meet this
> need, only the CIFS server needs to maintain it

For what it's worth, the NFSv4 server would also export creation time if
we had it.

--b.
