Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.SerNet.de ([193.175.80.2]:49320 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab0GVMwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 08:52:13 -0400
Date: Thu, 22 Jul 2010 14:17:50 +0200
Date: Thu, 22 Jul 2010 14:17:50 +0200
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: David Howells <dhowells@redhat.com>
Cc: Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Reply-To: Volker.Lendecke@SerNet.DE
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <30448.1279800887@redhat.com>
Message-Id: <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 01:14:47PM +0100, David Howells wrote:
> Jan Engelhardt <jengelh@medozas.de> wrote:
> 
> > Linux already has a creation time field, it's called otime (there is no "b"
> > in "creation"), and you will find scattered fragments of that all over the
> > kernel (foremost, fs/jfs/, now btrfs, and I also notice sysvipc having
> > something with that name).
> 
> It is?  It's called crtime in Ext4.  st_btime, however, would be compatible
> with BSD's stat, and Samba would just use it by way of autoconf magic if it
> appeared.

Samba has the following check:

# recent FreeBSD, NetBSD have creation timestamps called birthtime:             
AC_CHECK_MEMBERS([struct stat.st_birthtimespec.tv_nsec])
AC_CHECK_MEMBERS([struct stat.st_birthtime], AC_CHECK_MEMBERS([struct stat.st_birthtimensec]))

and the supporting code around that. "birth" might also be
where the "b" comes from :-)

Volker
