From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: NFS: possible circular locking  i_mutex <> mmap_sem
Date: Thu, 18 Jun 2009 18:48:08 +0200
Message-ID: <1245343689.13761.23623.camel@twins>
References: <20090618023208.GA28572@localhost>
	 <20090617195251.e648dbb8.akpm@linux-foundation.org>
	 <20090618030238.GA850@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36389 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbZFRQsH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 12:48:07 -0400
In-Reply-To: <20090618030238.GA850@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-06-18 at 11:02 +0800, Wu Fengguang wrote:

> > > [ 2638.515865] =======================================================
> > > [ 2638.519743] [ INFO: possible circular locking dependency detected ]
> > > [ 2638.519743] 2.6.30-rc8-mm1 #307
> > > [ 2638.519743] -------------------------------------------------------
> > > [ 2638.519743] firefox-bin/3399 is trying to acquire lock:
> > > [ 2638.519743]  (&mm->mmap_sem){++++++}, at: [<ffffffff81548471>] do_page_fault+0x301/0x330
> > > [ 2638.519743]
> > > [ 2638.519743] but task is already holding lock:
> > > [ 2638.519743]  (&sb->s_type->i_mutex_key#6){+.+.+.}, at: [<ffffffff810c2bd2>] generic_file_aio_write+0x52/0xd0
> > > [ 2638.519743]
> > > [ 2638.519743] which lock already depends on the new lock.
> > > [ 2638.519743]
> > > [ 2638.519743]
> > > [ 2638.519743] the existing dependency chain (in reverse order) is:
> > > [ 2638.519743]
> > > [ 2638.519743] -> #1 (&sb->s_type->i_mutex_key#6){+.+.+.}:
> > > [ 2638.519743]        [<ffffffff8107c066>] __lock_acquire+0x12b6/0x1b40
> > > [ 2638.519743]        [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
> > > [ 2638.519743]        [<ffffffff8154328e>] mutex_lock_nested+0x5e/0x390
> > > [ 2638.519743]        [<ffffffff811be15c>] nfs_revalidate_mapping+0xac/0x110    ==> takes i_mutex in nfs_invalidate_mapping()
> > > [ 2638.519743]        [<ffffffff811bba25>] nfs_file_mmap+0x55/0x80
> > > [ 2638.519743]        [<ffffffff810e2bb7>] mmap_region+0x427/0x600
> > > [ 2638.519743]        [<ffffffff810e305e>] do_mmap_pgoff+0x2ce/0x3f0
> > > [ 2638.519743]        [<ffffffff81010c26>] sys_mmap+0x106/0x130                 ==> takes mmap_sem
> > > [ 2638.519743]        [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
> > > [ 2638.519743]        [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > This is the faulty code path.  mmap_sem is supposed to nest inside i_mutex.
> 
> This could be a long stand bug: the nfs_revalidate_mapping() call was
> there in the very beginning of git history.

http://programming.kicks-ass.net/kernel-patches/mmap-vs-nfs/


