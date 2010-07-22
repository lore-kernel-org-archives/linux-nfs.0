Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:34914 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130Ab0GVRMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:12:25 -0400
Date: Thu, 22 Jul 2010 13:12:24 -0400
From: Jim Rees <rees@umich.edu>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100722171224.GA8630@merit.edu>
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
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Linus Torvalds wrote:

  I personally think that Unix ctime is insane. There is no real reason
  why "write()" should change mtime, but "chmod" changes ctime. It was
  just a random decision way back when...

I believe it was done that way so "dump" could backup just the inode and not
the data if only the inode had changed.  Full history here:

http://blog.plover.com/Unix/ctime.html
