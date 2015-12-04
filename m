Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:51331 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbLDMGj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Dec 2015 07:06:39 -0500
Date: Fri, 4 Dec 2015 13:06:33 +0100
From: Pavel Machek <pavel@ucw.cz>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 03/12] statx: Add a system call to make enhanced file
 info available
Message-ID: <20151204120633.GI14427@amd>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <20151120145457.18930.79678.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151120145457.18930.79678.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

> ===============
> NEW SYSTEM CALL
> ===============
> 
> The new system call is:
> 
> 	int ret = statx(int dfd,
> 			const char *filename,
> 			unsigned int flags,
> 			unsigned int mask,
> 			struct statx *buffer);

Should this be called stat5, so that when new, even more improved stat
comes, it does not have to be called statxx?

> The dfd, filename and flags parameters indicate the file to query.  There
> is no equivalent of lstat() as that can be emulated with statx() by passing
> AT_SYMLINK_NOFOLLOW in flags.  There is also no equivalent of fstat() as
> that can be emulated by passing a NULL filename to statx() with the fd of
> interest in dfd.

Dunno. Of course you can multiplex everything.

But fstat() is really different operation to stat() -- tell me about
my file descriptor vs. tell me about this filename, and ptrace (and
some "security" solutions) might want to allow one but disallow the
second. I'd not group them together..

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
