Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613AbcERKzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2016 06:55:05 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <3204439.9qcmCY96fi@wuerfel>
References: <3204439.9qcmCY96fi@wuerfel> <20160510070421.GB30896@infradead.org> <6897.1462868755@warthog.procyon.org.uk> <20160512091141.GA22420@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, Arnd Bergmann <arnd@arndb.de>,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 18 May 2016 11:55:02 +0100
Message-ID: <17597.1463568902@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:

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

Christoph?
