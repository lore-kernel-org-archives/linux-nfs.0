From: raven@themaw.net
Subject: umount() and NFS races in 2.4.26 (fwd)
Date: Sun, 11 Jul 2004 01:43:25 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0407110142180.7586@donald.themaw.net>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=uAKRQypu60I7Lcqm
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BjM3b-0002j7-EG
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 10:54:39 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BjM3a-0005Mr-6U
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 10:54:38 -0700
To: nfs@lists.sourceforge.net, Greg Banks <gnb@sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--uAKRQypu60I7Lcqm
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.58.0407110142201.7586@donald.themaw.net>
Content-Disposition: INLINE


This was the original post to LKML.

---------- Forwarded message ----------
Date: Thu, 8 Jul 2004 20:07:09 +0200
From: Thomas Moestl <moestl@ibr.cs.tu-bs.de>
To: linux-kernel@vger.kernel.org
Subject: umount() and NFS races in 2.4.26

Hi,

after deploying an SMP machine at work, we started to experience Oopses
in file-system related code relatively frequently. Investigation
revealed that they were caused by references using junk pointers from
freed super blocks via dangling inodes from unmounted file systems;
Oopses would always be preceded by the warning
  VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
on an unmount (unmount activity is high on this machine due to heavy use
of the automounter). The predecessor to this machine, a UP system with
otherwise almost identical configuration, did never encounter such
problems, so I went looking for possible SMP races.

I believe that I have found two problems:

- The NFS async unlink code (fs/nfs/unlink.c) does keep a dentry for
  later asynchronous processing, but the mount point is unbusied via
  path_release() once sys_unlink() returns (fs/namei.c). While it
  does a dget() on the dentry, this is insufficient to prevent an
  umount(); when one would happen in the right time window, it seems
  that it would initially get past the busy check:
	if (atomic_read(&mnt->mnt_count) == 2 || flags & MNT_DETACH) {
  (fs/namespace.c, do_umount()), but invalidate_inodes() in kill_super()
  (fs/super.c) would then fail because of the inode referenced from
  the dentry needed for the async unlink (which cannot be removed
  by shrink_dcache_parent() because the NFS code did dget() it).

  Please note that this problem is only conjectured, as it turned out
  to not be our culprit. It looks not completely trivial to fix to me,
  I believe it might require some changes that would affect other FS
  implementations. It is not a true SMP race, if it exists it would
  affect UP systems as well.

- There is a SMP race between the shrink_dcache_parent() (fs/dcache.c)
  called from kill_super() and prune_dache() called via
  shrink_dache_memory() (called by kswapd), as follows:
  shrink_dache_parent() calls select_parent() to both prepare the LRU
  list for purge_cache() and return the number of unused dcache
  entries that can likely be removed in the next prune_dache() run.
  If select_parent() returns 0, shrink_dcache_parent() assumes that
  its work is done and returns. Now, assume for simplicity that there
  are only two remaining dcache entries: one for "foo/bar" and for
  the directory "foo/", which is referenced by the "foo/bar" entry.
  Furthermore, prune_dcache() is currently running, called from kswapd,
  and has decided to remove the "foo/bar" entry. To that end, it
  calls prune_one_dentry(), which dentry_iput()s then "foo/bar" dentry.
  This causes the dache_lock() to be dropped. Just now select_parent()
  comes along, and can obtain the dcache_lock(). It now looks for unused
  dentries; but there is only the "foo/" one left, which has a non-zero
  d_count because "foo/bar" referenced it as parent, and
  prune_one_dentry() did not yet have a chance to dput() it because it
  has to wait for the dcache_lock(). Thus, select_parent() finds no
  unused dentries, assumes that all is fine and does not purge any
  more; the "foo/" entry can remain in the cache for much longer
  because it may have DCACHE_REFERENCED set, so that the kswapd
  purge_dcache() will leave it alone. The inode corresponding to the
  dangling dcache entry will still be referenced, and end up dangling,
  too. kill_super() will print the warning mentioned above.
  When dentry or inode are touched again later (for example in another
  purge_dcache() later on) we can end up accessing the super block
  freed during the unmount, leading to an Oops.
  This was partially verified by inspecting the dcache state via
  /dev/kmem after the busy inodes warning had occured (the directory
  dentry was not busy any more, but still remained in the unused list).

  In the attached patch, I have used a semaphore to serialize purging
  accesses to the dentry_unused list. With a kernel so patched, the
  problem seems to have disappeared. The patch is just a quick hack,
  the semantics of the semaphore is not really well-defined; but maybe
  it can serve as a starting point.
  
I have not checked whether any of these issues pertain to the 2.6 series
as well.

	- Thomas

P.S: please CC me in replies, as I am not subscribed to this list.

--uAKRQypu60I7Lcqm
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Content-ID: <Pine.LNX.4.58.0407110142202.7586@donald.themaw.net>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="dcachesem.diff"

--- dcache.c.orig	Wed Jun 16 00:22:03 2004
+++ dcache.c	Wed Jun 16 01:00:47 2004
@@ -51,6 +51,7 @@
 static unsigned int d_hash_shift;
 static struct list_head *dentry_hashtable;
 static LIST_HEAD(dentry_unused);
+struct semaphore dcache_lru_sem;
 
 /* Statistics gathering. */
 struct dentry_stat_t dentry_stat = {0, 0, 45, 0,};
@@ -381,6 +382,7 @@
 	struct list_head *tmp, *next;
 	struct dentry *dentry;
 
+	down(&dcache_lru_sem);
 	/*
 	 * Pass one ... move the dentries for the specified
 	 * superblock to the most recent end of the unused list.
@@ -416,6 +418,7 @@
 		goto repeat;
 	}
 	spin_unlock(&dcache_lock);
+	up(&dcache_lru_sem);
 }
 
 /*
@@ -548,8 +551,10 @@
 {
 	int found;
 
+	down(&dcache_lru_sem);
 	while ((found = select_parent(parent)) != 0)
 		prune_dcache(found);
+	up(&dcache_lru_sem);
 }
 
 /*
@@ -581,9 +586,11 @@
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
+	down(&dcache_lru_sem);
 	count = dentry_stat.nr_unused / priority;
 
 	prune_dcache(count);
+	up(&dcache_lru_sem);
 	return kmem_cache_shrink(dentry_cache);
 }
 
@@ -1247,6 +1254,7 @@
 		d++;
 		i--;
 	} while (i);
+	sema_init(&dcache_lru_sem, 1);
 }
 
 static void init_buffer_head(void * foo, kmem_cache_t * cachep, unsigned long flags)

--uAKRQypu60I7Lcqm--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
