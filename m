From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Mon, 13 Apr 2009 15:16:42 -0400
Message-ID: <1239650202.16771.15.camel@heimdal.trondhjem.org>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0R2rofgRTq9bD/YIyNM7"
Cc: rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53121 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbZDMTQx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2009 15:16:53 -0400
In-Reply-To: <20090412235010.c8e3475b.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-0R2rofgRTq9bD/YIyNM7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-04-12 at 23:50 -0700, Andrew Morton wrote:
> (cc linux-nfs)
> 
> On Mon, 13 Apr 2009 01:46:24 -0400 (EDT) rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org wrote:
> 
> > Hi world,
> > I've got a production server that's running as an NFSv4 client, along with 
> > a number of other machines.
> > 
> > All the other machines are perfectly happy, but this one is a bit of a 
> > bother. It's got a Core 2 Duo 6700, with a D975XBX2 motherboard and 4 GB 
> > of ECC RAM.
> > 
> > The problem is that, under heavy load, NFS will trip a BUG_ON in 
> > nfs_do_writepage, as follows:
> > ------------[ cut here ]------------
> > kernel BUG at fs/nfs/write.c:252!
> > invalid opcode: 0000 [#1] SMP
> > last sysfs file: /sys/devices/virtual/block/dm-
> > 0/range
> > CPU 0
> > Modules linked in: fuse autofs4 coretemp hwmon nfs lockd nfs_acl 
> > auth_rpcgss sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table kvm_intel 
> > kvm snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_seq_dummy 
> > snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss 
> > snd_mixer_oss snd_pcm snd_timer usb_storage snd cpia_usb e1000e soundcore 
> > cpia ppdev firewire_ohci snd_page_alloc firewire_core i2c_i801 videodev 
> > parport_pc pcspkr iTCO_wdt i2c_core v4l1_compat crc_itu_t parport 
> > iTCO_vendor_support v4l2_compat_ioctl32 i82975x_edac edac_core raid1
> > Pid: 309, comm: pdflush Not tainted 2.6.29.1 #1
> > RIP: 0010:[<ffffffffa0291a47>]  [<ffffffffa0291a47>] 
> > nfs_do_writepage+0x106/0x1a2 [nfs]
> > RSP: 0018:ffff88012d805af0  EFLAGS: 00010282
> > RAX: 0000000000000001 RBX: ffffe20001f66878 RCX: 0000000000000015
> > RDX: 0000000000600020 RSI: 0000000000000000 RDI: ffff88000155789c
> > RBP: ffff88012d805b20 R08: ffff88012cd53460 R09: 0000000000000004
> > R10: ffff88009d421700 R11: ffffffffa02a98d0 R12: ffff88010253a300
> > R13: ffff88000155789c R14: ffffe20001f66878 R15: ffff88012d805c80
> > FS:  0000000000000000(0000) GS:ffffffff817df000(0000) 
> > knlGS:0000000000000000
> > CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > CR2: 00000000f7d2b000 CR3: 000000008708a000 CR4: 00000000000026e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process pdflush (pid: 309, threadinfo ffff88012d804000, task 
> > ffff88012e4fdb80)
> > Stack:
> >   ffff88012d805b20 ffffe20001f66878 ffffe20001f66878 0000000000000000
> >   0000000000000001 0000000000000000 ffff88012d805b40 ffffffffa0291f5a
> >   ffffe20001f66878 ffff88012d805e40 ffff88012d805c70 ffffffff810a9c1d
> > Call Trace:
> >   [<ffffffffa0291f5a>] nfs_writepages_callback+0x14/0x25 [nfs]
> >   [<ffffffff810a9c1d>] write_cache_pages+0x261/0x3a4
> >   [<ffffffffa0291f46>] ? nfs_writepages_callback+0x0/0x25 [nfs]
> >   [<ffffffffa0291f1c>] nfs_writepages+0xb5/0xdf [nfs]
> >   [<ffffffffa02932bd>] ? nfs_flush_one+0x0/0xeb [nfs]
> >   [<ffffffff81060f78>] ? bit_waitqueue+0x17/0xa4
> >   [<ffffffff810a9db7>] do_writepages+0x2d/0x3d
> >   [<ffffffff810f4a51>] __writeback_single_inode+0x1b2/0x347
> >   [<ffffffff8100f7d4>] ? __switch_to+0xbe/0x3eb
> >   [<ffffffff810f4ffb>] generic_sync_sb_inodes+0x24a/0x395
> >   [<ffffffff810f5354>] writeback_inodes+0xa9/0x102
> >   [<ffffffff810a9f26>] wb_kupdate+0xa8/0x11e
> >   [<ffffffff810aac9d>] pdflush+0x173/0x236
> >   [<ffffffff810a9e7e>] ? wb_kupdate+0x0/0x11e
> >   [<ffffffff810aab2a>] ? pdflush+0x0/0x236
> >   [<ffffffff810aab2a>] ? pdflush+0x0/0x236
> >   [<ffffffff81060c9e>] kthread+0x4e/0x7b
> >   [<ffffffff810126ca>] child_rip+0xa/0x20
> >   [<ffffffff81011fe7>] ? restore_args+0x0/0x30
> >   [<ffffffff81060c50>] ? kthread+0x0/0x7b
> >   [<ffffffff810126c0>] ? child_rip+0x0/0x20
> > Code: 89 e7 e8 d5 cc ff ff 4c 89 e7 89 c3 e8 2a cd ff ff 85 db 74 a0 e9 83 
> > 00 00 00 41 f6 44 24 40 02 74 0d 4c 89 ef e8 e2 a5 d9 e0 90 <0f> 0b eb fe 
> > 4c 89 f7 e8 f5 7a e1 e0 85 c0 75 49 49 8b 46 18 ba
> > RIP  [<ffffffffa0291a47>] nfs_do_writepage+0x106/0x1a2 [nfs]
> >   RSP <ffff88012d805af0>
> > ---[ end trace 6d60c9b253ebcf15 ]---
> > 
> > 64bit kernel, 32bit userland. 2.6.29.1 vanilla, bug occurred as early as 
> > 2.6.28, bug still occurs with 2.6.30-rc1. I'm running bisect now, but 
> > there's a limit on how often I can reboot a production server, so I'll 
> > report back when I find it.

This looks like the same issue as
    http://bugzilla.kernel.org/show_bug.cgi?id=12913

Does the following patch from Nick help? It should apply on top of
2.6.30-rc1, and fixes a race in which the VM layer can end up marking a
page dirty after the filesystem has cleaned it...

Cheers
  Trond


--=-0R2rofgRTq9bD/YIyNM7
Content-Disposition: inline
Content-Description: Attached message - [patch] mm: close page_mkwrite races
Content-Type: message/rfc822

Return-Path: <npiggin@suse.de>
Received: from mail-imap1.uio.no ([unix socket]) by mail-imap1.uio.no
 (Cyrus v2.2.12) with LMTPA; Mon, 30 Mar 2009 15:53:11 +0200
X-Sieve: CMU Sieve 2.2
Delivery-date: Mon, 30 Mar 2009 15:53:11 +0200
Received: from mail-mx2.uio.no ([129.240.10.30]) by mail-imap1.uio.no with
 esmtp (Exim 4.69) (envelope-from <npiggin@suse.de>) id 1LoHvL-0008WS-L0 for
 trond.myklebust@fys.uio.no; Mon, 30 Mar 2009 15:53:11 +0200
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de) by
 mail-mx2.uio.no with esmtps (TLSv1:AES256-SHA:256) (Exim 4.69)
 (envelope-from <npiggin@suse.de>) id 1LoHvK-0000RQ-N3 for
 trond.myklebust@fys.uio.no; Mon, 30 Mar 2009 15:53:11 +0200
Received: from Relay2.suse.de (relay-ext.suse.de [195.135.221.8]) (using
 TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)) (No client certificate
 requested) by mx1.suse.de (Postfix) with ESMTP id EE3778D893; Mon, 30 Mar
 2009 15:53:07 +0200 (CEST)
Date: Mon, 30 Mar 2009 15:53:07 +0200
From: Nick Piggin <npiggin@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>, Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, linux-mm@vger.kernel.org
Subject: [patch] mm: close page_mkwrite races
Message-ID: <20090330135307.GP31000-B4tOwbsTzaBolqkO4TVVkw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.9i
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=-8.0, required=5.0,
 autolearn=disabled, RCVD_IN_DNSWL_HI=-8, uiobl=NO, uiouri=NO)
X-UiO-Scanned: 1FE2322A61BF0A90A5C40479477E3B8457187ED0
X-UiO-SPAM-Test: remote_host: 195.135.220.2 spam_score: -79 maxlevel 30
 minaction 1 bait 0 mail/h: 1 total 230 max/h 4 blacklist 0 greylist 1
 ratelimit 0
X-Evolution-Source: imap://trondmy-tX7RMk7GYJRTXje20yR8kg@public.gmane.org/
Content-Transfer-Encoding: 7bit

Hi,

I'd like opinions on this patch (applies on top of the previous
page_mkwrite fixes in -mm). I was not going to ask to merge it
immediately however it appears that fsblock is not the only one who
needs it...

--
I want to have the page be protected by page lock between page_mkwrite
notification to the filesystem, and the actual setting of the page
dirty. Do this by allowing the filesystem to return a locked page from
page_mkwrite, and have the page fault code keep it held until after it
calls set_page_dirty.

I need this in fsblock because I am working to ensure filesystem metadata
can be correctly allocated and refcounted. This means that page cleaning
should not require memory allocation.

Without this patch, then for example we could get a concurrent writeout
after the page_mkwrite (which allocates page metadata required to clean
it), but before the set_page_dirty. The writeout will clean the page and
notice that the metadata is now unused and may be deallocated (because
it appears clean as set_page_dirty hasn't been called yet). So at this
point the page may be dirtied via the pte without enough metadata to be
able to write it back.

Sage needs this race closed for ceph, and Trond maybe for NFS.

Cc: Sage Weil <sage@newdream.net>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 Documentation/filesystems/Locking |   24 +++++++---
 fs/buffer.c                       |   10 ++--
 mm/memory.c                       |   83 ++++++++++++++++++++++++++------------
 3 files changed, 79 insertions(+), 38 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2480,7 +2480,8 @@ block_page_mkwrite(struct vm_area_struct
 	if ((page->mapping != inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* page got truncated out from underneath us */
-		goto out_unlock;
+		unlock_page(page);
+		goto out;
 	}
 
 	/* page is wholly or partially inside EOF */
@@ -2494,14 +2495,15 @@ block_page_mkwrite(struct vm_area_struct
 		ret = block_commit_write(page, 0, end);
 
 	if (unlikely(ret)) {
+		unlock_page(page);
 		if (ret == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else /* -ENOSPC, -EIO, etc */
 			ret = VM_FAULT_SIGBUS;
-	}
+	} else
+		ret = VM_FAULT_LOCKED;
 
-out_unlock:
-	unlock_page(page);
+out:
 	return ret;
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1964,6 +1964,15 @@ static int do_wp_page(struct mm_struct *
 				ret = tmp;
 				goto unwritable_page;
 			}
+			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+				lock_page(old_page);
+				if (!old_page->mapping) {
+					ret = 0; /* retry the fault */
+					unlock_page(old_page);
+					goto unwritable_page;
+				}
+			} else
+				VM_BUG_ON(!PageLocked(old_page));
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -1973,9 +1982,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
+			if (!pte_same(*page_table, orig_pte)) {
+				page_cache_release(old_page);
+				unlock_page(old_page);
 				goto unlock;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -2098,16 +2109,30 @@ unlock:
 		 *
 		 * do_no_page is protected similarly.
 		 */
-		wait_on_page_locked(dirty_page);
-		set_page_dirty_balance(dirty_page, page_mkwrite);
+		if (!page_mkwrite) {
+			wait_on_page_locked(dirty_page);
+			set_page_dirty_balance(dirty_page, page_mkwrite);
+		}
 		put_page(dirty_page);
+		if (page_mkwrite) {
+			struct address_space *mapping = old_page->mapping;
+
+			unlock_page(old_page);
+			page_cache_release(old_page);
+			balance_dirty_pages_ratelimited(mapping);
+		}
 	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
-	if (old_page)
+	if (old_page) {
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 		page_cache_release(old_page);
+	}
 	return VM_FAULT_OOM;
 
 unwritable_page:
@@ -2659,27 +2684,22 @@ static int __do_fault(struct mm_struct *
 				int tmp;
 
 				unlock_page(page);
-				vmf.flags |= FAULT_FLAG_MKWRITE;
+				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
 				if (unlikely(tmp &
 					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 					ret = tmp;
-					anon = 1; /* no anon but release vmf.page */
-					goto out_unlocked;
-				}
-				lock_page(page);
-				/*
-				 * XXX: this is not quite right (racy vs
-				 * invalidate) to unlock and relock the page
-				 * like this, however a better fix requires
-				 * reworking page_mkwrite locking API, which
-				 * is better done later.
-				 */
-				if (!page->mapping) {
-					ret = 0;
-					anon = 1; /* no anon but release vmf.page */
-					goto out;
+					goto unwritable_page;
 				}
+				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+					lock_page(page);
+					if (!page->mapping) {
+						ret = 0; /* retry the fault */
+						unlock_page(page);
+						goto unwritable_page;
+					}
+				} else
+					VM_BUG_ON(!PageLocked(page));
 				page_mkwrite = 1;
 			}
 		}
@@ -2731,19 +2751,30 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(vmf.page);
-out_unlocked:
-	if (anon)
-		page_cache_release(vmf.page);
-	else if (dirty_page) {
+	if (dirty_page) {
+		struct address_space *mapping = page->mapping;
+
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
 
+		if (set_page_dirty(dirty_page))
+			page_mkwrite = 1;
 		set_page_dirty_balance(dirty_page, page_mkwrite);
+		unlock_page(dirty_page);
 		put_page(dirty_page);
+		if (page_mkwrite)
+			balance_dirty_pages_ratelimited(mapping);
+	} else {
+		unlock_page(vmf.page);
+		if (anon)
+			page_cache_release(vmf.page);
 	}
 
 	return ret;
+
+unwritable_page:
+	page_cache_release(page);
+	return ret;
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -509,16 +509,24 @@ locking rules:
 		BKL	mmap_sem	PageLocked(page)
 open:		no	yes
 close:		no	yes
-fault:		no	yes
-page_mkwrite:	no	yes		no
+fault:		no	yes		can return with page locked
+page_mkwrite:	no	yes		can return with page locked
 access:		no	yes
 
-	->page_mkwrite() is called when a previously read-only page is
-about to become writeable. The file system is responsible for
-protecting against truncate races. Once appropriate action has been
-taking to lock out truncate, the page range should be verified to be
-within i_size. The page mapping should also be checked that it is not
-NULL.
+	->fault() is called when a previously not present pte is about
+to be faulted in. The filesystem must find and return the page associated
+with the passed in "pgoff" in the vm_fault structure. If it is possible that
+the page may be truncated and/or invalidated, then the filesystem must lock
+the page, then ensure it is not already truncated (the page lock will block
+subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
+locked. The VM will unlock the page.
+
+	->page_mkwrite() is called when a previously read-only pte is
+about to become writeable. The filesystem again must ensure that there are
+no truncate/invalidate races, and then return with the page locked. If
+the page has been truncated, the filesystem should not look up a new page
+like the ->fault() handler, but simply return with VM_FAULT_NOPAGE, which
+will cause the VM to retry the fault.
 
 	->access() is called when get_user_pages() fails in
 acces_process_vm(), typically used to debug a process through

--=-0R2rofgRTq9bD/YIyNM7--

