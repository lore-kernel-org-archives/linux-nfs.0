From: Thomas Moestl <moestl@ibr.cs.tu-bs.de>
Subject: Re: [autofs] Re: umount() and NFS races in 2.4.26
Date: Sat, 10 Jul 2004 20:25:10 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040710182510.GB800@timesink.dyndns.org>
References: <20040708180709.GA7704@timesink.dyndns.org> <Pine.LNX.4.58.0407101419210.1378@donald.themaw.net> <20040710152549.GD21121@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raven@themaw.net, autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net,
	Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266333AbUGJSZE@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040710152549.GD21121@sgi.com>
List-ID: <nfs.lists.sourceforge.net>

On Sun, 2004/07/11 at 01:25:49 +1000, Greg Banks wrote:
> On Sat, Jul 10, 2004 at 02:57:46PM +0800, raven@themaw.net wrote:
> > On Thu, 8 Jul 2004, Thomas Moestl wrote:
> > > I believe that I have found two problems:
> > > 
> > > - The NFS async unlink code (fs/nfs/unlink.c) does keep a dentry for
> > >   later asynchronous processing, but the mount point is unbusied via
> > >   path_release() once sys_unlink() returns (fs/namei.c). [...]
> 
> This used to be a bug.  It was fixed in 2.4.26 with
> 
> http://linux.bkbits.net:8080/linux-2.4/diffs/fs/nfs/dir.c@1.13
> 
> What happens now is that the dentry and its inode are cleaned up
> when the async unlink task is deleted in nfs_put_super() between
> the first and second calls to invalidate_inodes() in kill_super().

Ah, I see; I didn't look deep enough there.

> > > - There is a SMP race between the shrink_dcache_parent() (fs/dcache.c)
> > >   called from kill_super() and prune_dache() called via
> > >   shrink_dache_memory() (called by kswapd), as follows: [...]
> 
> Your scenario sounds plausible and might explain at least some 
> of the autofs unmount races we've been seeing.
> 
> > >   In the attached patch, I have used a semaphore to serialize purging
> > >   accesses to the dentry_unused list. [...]
> 
> Can we see the patch please?

I've attached it below.

Thanks,

	- Thomas

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
