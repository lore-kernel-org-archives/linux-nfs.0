Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34481 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab0JaCEz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 22:04:55 -0400
Date: Sat, 30 Oct 2010 22:04:31 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd4: initialize delegation pointer to lease
Message-ID: <20101031020431.GA29702@infradead.org>
References: <20101030212500.GE480@fieldses.org>
 <1288474276-14288-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288474276-14288-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Oct 30, 2010 at 05:31:16PM -0400, J. Bruce Fields wrote:
> The NFSv4 server was initializing the dp->dl_flock pointer by the
> somewhat ridiculous method of a locks_copy_lock callback.
> 
> Now that setlease uses the passed-in lock instead of doing a copy,
> dl_flock no longer gets set, resulting in the lock leaking on delegation
> release, and later possible hangs (among other problems).
> 
> So, initialize dl_flock and get rid of the callback.

>From what I can see this was the only instance of 
lock_manager_operations.fl_copy_lock.  Please kill it while you're at
it.

Also lock_manager_operations.fl_release_private has only exact one
instance in nfs4d which is part of the same abuse scheme.  Please also
get rid of it.   I recently noticed this while updating
Documentation/filesystems/Locking for the grand new BKL-less world.

