Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57716 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbbGMDjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Jul 2015 23:39:45 -0400
Date: Mon, 13 Jul 2015 13:39:34 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713133934.6a4ef77d@noble>
In-Reply-To: <55A111A8.2040701@gmail.com>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 11 Jul 2015 20:52:56 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> If there are some mount points(not exported for nfs) under pseudo root,
> after client's operation of those entry under the root,  anyone *can't*
> unmount those mount points until export cache expired.
> 
> /nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
> total 0
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
> drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
> Filesystem                      1K-blocks    Used Available Use% Mounted on
> ......
> /dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
> /dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
> /dev/sde                           999320    1284    929224   1% /nfs/test
> /mnt/pnfs/:
> total 0
> -rw-r--r--. 1 root root 0 Apr 21 22:23 attr
> drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp
> 
> /mnt/xfs/:
> total 0
> umount: /nfs/test/: target is busy
>         (In some cases useful info about processes that
>         use the device is found by lsof(8) or fuser(1).)
> 
> It's caused by exports cache of nfsd holds the reference of
> the path (here is /nfs/test/), so, it can't be umounted.
> 
> I don't think that's user expect, they want umount /nfs/test/.
> Bruce think user can also umount /nfs/pnfs/ and /nfs/xfs.
> 
> Also, using kzalloc for all memory allocating without kmalloc.
> Thanks for Al Viro's commets for the logic of fs_pin.
> 
> v3,
> 1. using path_get_pin/path_put_unpin for path pin
> 2. using kzalloc for memory allocating
> 
> v4,
> 1. add a completion for pin_kill waiting the reference is decreased to zero.
> 2. add a work_struct for pin_kill decreases the reference indirectly.
> 3. free svc_export/svc_expkey in pin_kill, not svc_export_put/svc_expkey_put.
> 4. svc_export_put/svc_expkey_put go though pin_kill logic.
> 
> v5, same as v4.
> 
> v6,
> 1. Pin vfsmnt to mount point at first, when reference increace (==2),
>    grab a reference to vfsmnt by mntget. When decreace (==1),
>    drop the reference to vfsmnt, left pin.
> 2. Delete cache_head directly from cache_detail.
> 
> v7, 
> implement self reference increase and decrease for nfsd exports/expkey 
> 
> When reference of cahce_head increase(>1), grab a reference of mnt once.
> and reference decrease to 1 (==1), drop the reference of mnt.
> 
> So after that,
> When ref > 1, user cannot umount the filesystem with -EBUSY.
> when ref ==1, means cache only reference by nfsd cache,
> no other reference. So user can try umount,
> 1. before set MNT_UMOUNT (protected by mount_lock), nfsd cache is
>    referenced (ref > 1, legitimize_mntget), umount will fail with -EBUSY.
> 2. after set MNT_UMOUNT, nfsd cache is referenced (ref == 2),
>    legitimize_mntget will fail, and set cache to CACHE_NEGATIVE,
>    and the reference will be dropped, re-back to 1.
>    So, pin_kill can delete the cache and umount success.
> 3. when umountting, no reference to nfsd cache,
>    pin_kill can delete the cache and umount success.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Wow.... this is turning out to be a lot more complex that I imagined at
first (isn't that always the way!).

There is a lot of good stuff here, but I think we can probably make it
simpler and so even better.

I particularly don't like the get_ref/put_ref pointers in cache_head.
They make cache_head a lot bigger than it was before, and they are only
needed for two specific caches.  And then they are the same for every element
in the cache.

I also don't like the ref_mutex ... or I don't like where it is used...
or something.  I definitely don't think we need one per cached entry.
Maybe one per cache.

I can certainly see that the "first" time we get a reference to a cache
item that holds a vfsmnt pointer, we need to "legitimize" that - or
fail.  But I don't think that has to happen inside the cache.c
machinery.

How about this:
 - add a new cache flag "CACHE_ACTIVE" (for example) which the cache
   owner can set whenever it likes.  When cache_put finds that CACHE_ACTIVE
   is set when refcount is <= 2, it calls a new cache_detail method: cache_deactivate.
 - cache_deactivate takes a mutex (yes, we do need one, don't we)
   and if CACHE_ACTIVE is still set and refcount is still <= 2,
   it drops the reference on the vfsmnt and clears CACHE_ACTIVE.
   This actually needs to be something like:
    if (test_and_clear_bit(CACHE_ACTIVE,...)) {
        if (atomic_read(..refcnt) > 2) {
             set_bit(CACHE_ACTIVE);
             mutex_unlock()
             return

   so that if other code gets a reference and tests CACHE_ACTIVE, it
   won't suddenly become inactive.  Might need a memory barrier in there...
   no, test_and_clear implies a memory barrier.

We only need to make changes to svc_export and svc_expkey - right?
So that would be:
 Change svc_export_lookup and svc_expkey_lookup so they look something
 like:

  svc_XX_lookup(struct cache_detail *cd, struct svc_XXX *item)
  {
      struct cache_head *ch;
      int hash = svc_XXX_hash(item);

      ch = sunrpc_cache_lookup(cd, &item->h, hash);
      if (!ch)
           return NULL;
      item = container_of(ch, struct svc_XXX, h);
      if (!test_bit(CACHE_VALID, &ch->flags) ||
          test_bit(CACHE_NEGATIVE, &ch->flags) ||
          test_bit(CACHE_ACTIVE, &ch->flags))
            return item;

      mutex_lock(&svc_XXX_mutex);
      if (!test_bit(CACHE_ACTIVE, &ch->flags)) {
              if (legitimize_mnt_get() == NULL) {
                      XXX_put(item);
                      item = NULL;
              } else
                      set_bit(CACHE_ACTIVE, &ch->flags);
      }
      mutex_unlock(&something);
      return item;
 }

Then the new 'cache_deactivate' function is something like:

  svc_XXX_deactivate(struct cache_detail *cd, struct cache_head *ch)
  {
       struct svc_XXX *item = container_of(ch, &item->h, item);

       mutex_lock(&svc_XXX_mutex);
       if (test_and_clear_bit(CACHE_ACTIVE, &ch->flags)) {
              if (atomic_read(&ch->ref.refcount) > 2) {
                   /* Race with get_ref - do nothing */
                   set_bit(CACHE_ACTIVE, &ch->flags);
              else
                   mntput(....mnt);
       }
       mutex_unlock(&svc_XXX_mutex);
  }


cache_put would have:

    if (test_bit(CACHE_ACTIVE, &h->flags) &&
        cd->cache_deactivate &&
        atomic_read(&h->ref.refcount <= 2))
           cd->cache_deactivate(cd, h);

but there is still a race.  If: (T1 and T2 are threads)
   T1: cache_put finds refcount is 2 and CACHE_ACTIVE is set and calls ->cache_deactiveate
   T2: cache_get increments the refcount to 3
   T1: cache_deactivate clears CACHE_ACTIVE and find refcount is 3
   T2: now calls cache_put, which sees CACHE_ACTIVE is clear so refcount becomes 2
   T1: sets CACHE_ACTIVE again and continues.  refcount becomes 1.

So not refcount is 1 and the item is still active.

We can fix this by making cache_put loop:
    while (test_bit(CACHE_ACTIVE, &h->flags) &&
          cd->cache_deactivate &&
          (smb_rmb(), 1) &&
          atomic_read(&h->ref.refcount <= 2))
           cd->cache_deactivate(cd, h);

This should ensure that refcount never gets to 1 with the
item still active (i.e. with a ref count on the mnt).


The work item and completion are a bit unfortunate too.

I guess the problem here is that pin_kill() can run while there are
some inactive references to the cache item.  There can then be a race
over who will use path_put_unpin to put the dentry.

Could we fix that by having expXXX_pin_kill() use kref_get_unless_zero()
on the cache item.
If that succeeds, then path_put_unpin hasn't been called and it won't be.
So expXXX_pin_kill can call it and then set CACHE_NEGATIVE.
If it fails, then it has already been called and nothing else need be done.
Almost.
If kref_get_unless_zero() fails, pin_remove() may not have been called
yet, but it will be soon.  We might need to wait.
It would be nice if pin_kill() would check ->done again after calling p->kill.
e.g.

diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index 611b5408f6ec..c2ef5c9d4c0d 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -47,7 +47,9 @@ void pin_kill(struct fs_pin *p)
 		spin_unlock_irq(&p->wait.lock);
 		rcu_read_unlock();
 		p->kill(p);
-		return;
+		if (p->done > 0)
+			return;
+		spin_lock_irq(&p->wait.lock);
 	}
 	if (p->done > 0) {
 		spin_unlock_irq(&p->wait.lock);

I think that would close the last gap, without needing extra work
items and completion in the nfsd code.

Al: would you be OK with that change to pin_kill?

Thanks,
NeilBrown
