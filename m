Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753642Ab0JaDFI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 23:05:08 -0400
Date: Sat, 30 Oct 2010 23:04:44 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd4: initialize delegation pointer to lease
Message-ID: <20101031030443.GB24174@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
 <1288474276-14288-4-git-send-email-bfields@redhat.com>
 <20101031020431.GA29702@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101031020431.GA29702@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Oct 30, 2010 at 10:04:31PM -0400, Christoph Hellwig wrote:
> On Sat, Oct 30, 2010 at 05:31:16PM -0400, J. Bruce Fields wrote:
> > The NFSv4 server was initializing the dp->dl_flock pointer by the
> > somewhat ridiculous method of a locks_copy_lock callback.
> > 
> > Now that setlease uses the passed-in lock instead of doing a copy,
> > dl_flock no longer gets set, resulting in the lock leaking on delegation
> > release, and later possible hangs (among other problems).
> > 
> > So, initialize dl_flock and get rid of the callback.
> 
> >From what I can see this was the only instance of 
> lock_manager_operations.fl_copy_lock.  Please kill it while you're at
> it.
> 
> Also lock_manager_operations.fl_release_private has only exact one
> instance in nfs4d which is part of the same abuse scheme.  Please also
> get rid of it.   I recently noticed this while updating
> Documentation/filesystems/Locking for the grand new BKL-less world.

Yeah, I wanted to maximize chances of getting the minimal fixes into
-rc1, but I've got patches for that queued up too.  I was planning on
waiting for the next merge window, but I'm happy enough to send them in
now.

--b.
