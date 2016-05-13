Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:50167 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbcEMP3I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2016 11:29:08 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
Date: Fri, 13 May 2016 17:28:11 +0200
Message-ID: <3204439.9qcmCY96fi@wuerfel>
In-Reply-To: <20160512091141.GA22420@infradead.org>
References: <20160510070421.GB30896@infradead.org> <6897.1462868755@warthog.procyon.org.uk> <20160512091141.GA22420@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 12 May 2016 02:11:41 Christoph Hellwig wrote:
> On Tue, May 10, 2016 at 09:25:55AM +0100, David Howells wrote:
> > Because it's not necessarily a perfectly working version of it.  See the Y2037
> > problem for example.
> > 
> > I was assuming that C libraries might want to update the struct stat and the
> > stat call() to provide fields that aren't currently there in Linux but are in
> > other OS's.  We could even dispense with older stat syscalls on new arches.
> 
> Please stop this whole let's get rid of old syscalls on new
> architectures stuff.  This just means we have to do the translation
> multiple, and the one in userspace is more costly as we it needs to be
> in every copy of the library.  And times where we had a single libc
> instance (nevermind implementation) are long over if we ever actually
> had them.

I'm trying to understand what that means for the 64-bit time_t syscalls.

The patch series I did last year had a replacement 'sys_newfstatat()'
syscall but IIRC no other stat variant, the idea being that we would
only need to provide this one to the libc and have user space emulate
the stat/fstat/lstat/fstatat variants based on that.
With the statx introduction, I was hoping to no longer have to add
that syscall but instead have libc do everything on top of sys_statx().

Do you think that is reasonable, given that we won't be allowed to
call any of the existing stat() variants for a y2038-safe libc build[1],
or should we plan to keep needing replacement fstatat (and possibly
stat/lstat/fstat) syscalls with 64-bit time_t even after statx() support
is merged into the kernel.

	Arnd

[1] the glibc developers plan to allow compatibility for 32-bit time_t
    and 64-bit time_t in the same binary, but any user space code built
    with 64-bit time_t must never call into kernel interfaces that use
    a 32-bit time_t.
