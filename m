From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfs: LOCKDEP warning with 2.6.31-rc6
Date: Thu, 20 Aug 2009 08:54:51 -0400
Message-ID: <1250772891.5352.21.camel@heimdal.trondhjem.org>
References: <s5hiqgipz4x.wl%tiwai@suse.de> <1250770159.8282.185.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Takashi Iwai <tiwai@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35028 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754056AbZHTMyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 08:54:51 -0400
In-Reply-To: <1250770159.8282.185.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 14:09 +0200, Peter Zijlstra wrote:
> On Thu, 2009-08-20 at 12:18 +0200, Takashi Iwai wrote:
> > Hi,
> > 
> > my machine got a lockdep warning regarding NFS client on 2.6.31-rc6.
> > Here is the log:
> > 
> > =======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.31-rc6-test #12
> > -------------------------------------------------------
> > soffice.bin/31490 is trying to acquire lock:
> >  (&sb->s_type->i_mutex_key#13){+.+.+.}, at: [<f85ea8bb>] nfs_revalidate_mapping+0x72/0xbe [nfs]
> > 
> > but task is already holding lock:
> >  (&mm->mmap_sem){++++++}, at: [<c0106c5b>] sys_mmap2+0x6d/0xb4
> > 
> > which lock already depends on the new lock.
> > 
> > 
> > the existing dependency chain (in reverse order) is:
> > 
> > -> #1 (&mm->mmap_sem){++++++}:
> >        [<c0161b06>] __lock_acquire+0x100e/0x130d
> >        [<c0161ebc>] lock_acquire+0xb7/0xeb
> >        [<c01a2a15>] might_fault+0x69/0x9a
> >        [<c026d399>] copy_to_user+0x3c/0x127
> >        [<c01d4427>] filldir64+0xc3/0x108
> >        [<f85e6270>] nfs_do_filldir+0x383/0x4ad [nfs]
> >        [<f85e6b4e>] nfs_readdir+0x7b4/0x830 [nfs]
> >        [<c01d469e>] vfs_readdir+0x76/0xb3
> >        [<c01d474e>] sys_getdents64+0x73/0xc3
> >        [<c0102df3>] sysenter_do_call+0x12/0x38
> >        [<ffffffff>] 0xffffffff
> > 
> > -> #0 (&sb->s_type->i_mutex_key#13){+.+.+.}:
> >        [<c0161856>] __lock_acquire+0xd5e/0x130d
> >        [<c0161ebc>] lock_acquire+0xb7/0xeb
> >        [<c03af059>] mutex_lock_nested+0x43/0x272
> >        [<f85ea8bb>] nfs_revalidate_mapping+0x72/0xbe [nfs]
> >        [<f85e8128>] nfs_file_mmap+0x5e/0x77 [nfs]
> >        [<c01ab5f7>] mmap_region+0x263/0x40f
> >        [<c01aba07>] do_mmap_pgoff+0x264/0x2c7
> >        [<c0106c6f>] sys_mmap2+0x81/0xb4
> >        [<c0102df3>] sysenter_do_call+0x12/0x38
> >        [<ffffffff>] 0xffffffff
> > 
> > other info that might help us debug this:
> > 
> > 1 lock held by soffice.bin/31490:
> >  #0:  (&mm->mmap_sem){++++++}, at: [<c0106c5b>] sys_mmap2+0x6d/0xb4
> > 
> > stack backtrace:
> > Pid: 31490, comm: soffice.bin Not tainted 2.6.31-rc6-test #12
> > Call Trace:
> >  [<c03ad742>] ? printk+0x1d/0x33
> >  [<c01606d1>] print_circular_bug_tail+0xaf/0xcb
> >  [<c0161856>] __lock_acquire+0xd5e/0x130d
> >  [<f85ea8bb>] ? nfs_revalidate_mapping+0x72/0xbe [nfs]
> >  [<c0161ebc>] lock_acquire+0xb7/0xeb
> >  [<f85ea8bb>] ? nfs_revalidate_mapping+0x72/0xbe [nfs]
> >  [<f85ea8bb>] ? nfs_revalidate_mapping+0x72/0xbe [nfs]
> >  [<c03af059>] mutex_lock_nested+0x43/0x272
> >  [<f85ea8bb>] ? nfs_revalidate_mapping+0x72/0xbe [nfs]
> >  [<f8609339>] ? nfs_have_delegation+0x68/0x82 [nfs]
> >  [<f85ea8bb>] nfs_revalidate_mapping+0x72/0xbe [nfs]
> >  [<f85e8128>] nfs_file_mmap+0x5e/0x77 [nfs]
> >  [<c01ab5f7>] mmap_region+0x263/0x40f
> >  [<c01aba07>] do_mmap_pgoff+0x264/0x2c7
> >  [<c0106c6f>] sys_mmap2+0x81/0xb4
> >  [<c0102df3>] sysenter_do_call+0x12/0x38
> > 
> > =======================================================
> > 
> > Indeed this looks like a circular lock dependency since copy_*_user()
> > invokes mm->mmap_sem mutex lock internally.  (I hit a similar bug in
> > the ALSA core ago, thus I know it :)
> > 
> > The inode lock in vfs_readdir is killable, so it's not critical,
> > though...
> 
> Right, I did a number of patches to split up ->mmap() a while ago (ok, a
> long while ago).
> 
>   http://www.mail-archive.com/linux-arch@vger.kernel.org/msg04493.html
> 
> Unless someone sees another way out, we should reconsider these, as this
> warning seems to pop up more frequently.

I'd be fine with that...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
