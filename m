Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54231 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbcEWIWc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2016 04:22:32 -0400
Date: Mon, 23 May 2016 01:22:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160523082230.GA21308@infradead.org>
References: <20160510070421.GB30896@infradead.org>
 <6897.1462868755@warthog.procyon.org.uk>
 <20160512091141.GA22420@infradead.org>
 <3204439.9qcmCY96fi@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3204439.9qcmCY96fi@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 13, 2016 at 05:28:11PM +0200, Arnd Bergmann wrote:
> I'm trying to understand what that means for the 64-bit time_t syscalls.
> 
> The patch series I did last year had a replacement 'sys_newfstatat()'
> syscall but IIRC no other stat variant, the idea being that we would
> only need to provide this one to the libc and have user space emulate
> the stat/fstat/lstat/fstatat variants based on that.
> With the statx introduction, I was hoping to no longer have to add
> that syscall but instead have libc do everything on top of sys_statx().
> 
> Do you think that is reasonable, given that we won't be allowed to
> call any of the existing stat() variants for a y2038-safe libc build[1],
> or should we plan to keep needing replacement fstatat (and possibly
> stat/lstat/fstat) syscalls with 64-bit time_t even after statx() support
> is merged into the kernel.

Honestly I think this really matters on the amount of 'emulation' we
need - if it's just adding a new flag that can be trivially generated
in the syscall stub in userland that's probably fine, but if we have
actually differing semantics (like the stat weak attributes) I'd rather
have a properly documented syscall.  If we otherwise need to rewrite
whole structures I'd much rather do that in kernel space.

And to get back to stat: if would be really useful to coordinate the
new one with glibc so that we don't end up with two different stat
structures again like we do for a lot of platforms at the moment.
