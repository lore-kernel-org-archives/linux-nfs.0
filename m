Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp04.blacknight.com ([81.17.249.35]:52082 "EHLO
	outbound-smtp04.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbbHTMYJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 08:24:09 -0400
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id C6959F4066
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 12:24:01 +0000 (UTC)
Date: Thu, 20 Aug 2015 13:23:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
Message-ID: <20150820122359.GB12432@techsingularity.net>
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
 <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
 <55AF9EA8.6020102@redhat.com>
 <20150727105216.GD2660@techsingularity.net>
 <55B6153B.1070604@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <55B6153B.1070604@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 27, 2015 at 01:25:47PM +0200, Jerome Marchand wrote:
> On 07/27/2015 12:52 PM, Mel Gorman wrote:
> > On Wed, Jul 22, 2015 at 03:46:16PM +0200, Jerome Marchand wrote:
> >> On 07/22/2015 02:23 PM, Trond Myklebust wrote:
> >>> On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.com> wrote:
> >>>>
> >>>> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
> >>>> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in
> >>>> nfs_file_direct_write(). This code was introduced by commit a9ab5e840669
> >>>> ("nfs: page cache invalidation for dio").
> >>>> This naive test patch avoid to take the mutex on a swapfile and makes
> >>>> lockdep happy again. However I don't know much about NFS code and I
> >>>> assume it's probably not the proper solution. Any thought?
> >>>>
> >>>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> >>>
> >>> NFS is not the only O_DIRECT implementation to set the inode->i_mutex.
> >>> Why can't this be fixed in the generic swap code instead of adding
> >>> yet-another-exception-for-IS_SWAPFILE?
> >>
> >> I meant to cc Mel. Just added him.
> >>
> > 
> > Can the full lockdep warning be included as it'll be easier to see then if
> > the generic swap code can somehow special case this? Currently, generic
> > swapping does not not need to care about how the filesystem locked.
> > For most filesystems, it's writing directly to the blocks on disk and
> > bypassing the FS. In the NFS case it'd be surprising to find that there
> > also are dirty pages in page cache that belong to the swap file as it's
> > going to cause corruption. If there is any special casing it would to only
> > attempt the invalidation in the !swap case and warn if mapping->nrpages. It
> > still would look a bit weird but safer than just not acquiring the mutex
> > and then potentially attempting an invalidation.
> > 
> 
> [ 6819.501009] =================================
> [ 6819.501009] [ INFO: inconsistent lock state ]
> [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tainted
> [ 6819.501009] ---------------------------------

Thanks. Sorry for the long delay but I finally got back to the bug this
week. NFS can be modified to special case the swapfile but I was not happy
with the result for multiple reasons. It took me a while to see a way for
the core VM to deal with it. What do you think of the following
approach? More importantly, does it work for you?

---8<---
nfs: Use swap_lock to prevent parallel swapon activations

Jerome Marchand reported a lockdep warning as follows

    [ 6819.501009] =================================
    [ 6819.501009] [ INFO: inconsistent lock state ]
    [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tainted
    [ 6819.501009] ---------------------------------
    [ 6819.501009] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
    [ 6819.501009] kswapd0/38 [HC0[0]:SC0[0]:HE1:SE1] takes:
    [ 6819.501009]  (&sb->s_type->i_mutex_key#17){+.+.?.}, at: [<ffffffffa03772a5>] nfs_file_direct_write+0x85/0x3f0 [nfs]
    [ 6819.501009] {RECLAIM_FS-ON-W} state was registered at:
    [ 6819.501009]   [<ffffffff81107f51>] mark_held_locks+0x71/0x90
    [ 6819.501009]   [<ffffffff8110b775>] lockdep_trace_alloc+0x75/0xe0
    [ 6819.501009]   [<ffffffff81245529>] kmem_cache_alloc_node_trace+0x39/0x440
    [ 6819.501009]   [<ffffffff81225b8f>] __get_vm_area_node+0x7f/0x160
    [ 6819.501009]   [<ffffffff81226eb2>] __vmalloc_node_range+0x72/0x2c0
    [ 6819.501009]   [<ffffffff81227424>] vzalloc+0x54/0x60
    [ 6819.501009]   [<ffffffff8122c7c8>] SyS_swapon+0x628/0xfc0
    [ 6819.501009]   [<ffffffff81867772>] entry_SYSCALL_64_fastpath+0x12/0x76

It's due to NFS acquiring i_mutex since a9ab5e840669 ("nfs: page
cache invalidation for dio") to invalidate page cache before direct I/O.
Filesystems may safely acquire i_mutex during direct writes but NFS is unique
in its treatment of swap files. Ordinarily swap files are supported by the
core VM looking up the physical block for a given offset in advance. There
is no physical block for NFS and the direct write paths are used after
calling mapping->swap_activate.

The lockdep warning is triggered by swapon(), which is not in reclaim
context, acquiring the i_mutex to ensure a swapfile is not activated twice.

swapon does not need the i_mutex for this purpose.  There is a requirement
that fallocate not be used on swapfiles but this is protected by the inode
flag S_SWAPFILE and nothing to do with i_mutex. In fact, the current
protection does nothing for block devices. This patch expands the role
of swap_lock to protect against parallel activations of block devices and
swapfiles and removes the use of i_mutex. This both improves the protection
for swapon and avoids the lockdep warning.

Reported-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/swapfile.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 41e4581af7c5..d58ed6833fa3 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1928,9 +1928,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		set_blocksize(bdev, old_block_size);
 		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	} else {
-		mutex_lock(&inode->i_mutex);
+		spin_lock(&swap_lock);
 		inode->i_flags &= ~S_SWAPFILE;
-		mutex_unlock(&inode->i_mutex);
+		spin_unlock(&swap_lock);
 	}
 	filp_close(swap_file, NULL);
 
@@ -2156,7 +2156,6 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 		p->flags |= SWP_BLKDEV;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
-		mutex_lock(&inode->i_mutex);
 		if (IS_SWAPFILE(inode))
 			return -EBUSY;
 	} else
@@ -2386,6 +2385,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 
+	/* prevent parallel swapons */
+	spin_lock(&swap_lock);
 	p->swap_file = swap_file;
 	mapping = swap_file->f_mapping;
 
@@ -2396,13 +2397,14 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			continue;
 		if (mapping == q->swap_file->f_mapping) {
 			error = -EBUSY;
+			spin_unlock(&swap_lock);
 			goto bad_swap;
 		}
 	}
 
 	inode = mapping->host;
-	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
 	error = claim_swapfile(p, inode);
+	spin_unlock(&swap_lock);
 	if (unlikely(error))
 		goto bad_swap;
 
@@ -2543,10 +2545,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	vfree(swap_map);
 	vfree(cluster_info);
 	if (swap_file) {
-		if (inode && S_ISREG(inode->i_mode)) {
-			mutex_unlock(&inode->i_mutex);
+		if (inode && S_ISREG(inode->i_mode))
 			inode = NULL;
-		}
 		filp_close(swap_file, NULL);
 	}
 out:
@@ -2556,8 +2556,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	if (name)
 		putname(name);
-	if (inode && S_ISREG(inode->i_mode))
-		mutex_unlock(&inode->i_mutex);
 	return error;
 }
 
