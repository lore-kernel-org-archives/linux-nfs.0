Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35143 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbG0DGG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:06:06 -0400
Message-ID: <55B5A012.1030006@gmail.com>
Date: Mon, 27 Jul 2015 11:05:54 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 0/9 v8] NFSD: Pin to vfsmount for nfsd exports cache
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are some mount points(not exported for nfs) under pseudo root,
after client's operation of those entry under the root, anyone *can't*
unmount those mount points until export cache expired.

# cat /etc/exports
/nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
/nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
# ll /nfs/
total 0
drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
# mount /dev/sde /nfs/test
# df
Filesystem                      1K-blocks    Used Available Use% Mounted on
......
/dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
/dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
/dev/sde                           999320    1284    929224   1% /nfs/test
# mount -t nfs 127.0.0.1:/nfs/ /mnt
# ll /mnt/*/
/mnt/pnfs/:
total 0
-rw-r--r--. 1 root root 0 Apr 21 22:23 attr
drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp

/mnt/xfs/:
total 0
# umount /nfs/test/
umount: /nfs/test/: target is busy
        (In some cases useful info about processes that
         use the device is found by lsof(8) or fuser(1).)

It's caused by exports cache of nfsd holds the reference of
the path (here is /nfs/test/), so, it can't be umounted.

I don't think that's user expect, they want umount /nfs/test/.
Bruce think user can also umount /nfs/pnfs/ and /nfs/xfs.

This patch site lets nfsd exports pinning to vfsmount, 
not using mntget, so user can umount any exports mountpoint now.

v3, 
1. New helpers path_get_pin/path_put_unpin for path pin.
2. Use kzalloc for allocating memory.

v4, Thanks for Al Viro's commets for the logic of fs_pin.
1. add a completion for pin_kill waiting the reference is decreased to zero.
2. add a work_struct for pin_kill decreases the reference indirectly.
3. free svc_export/svc_expkey in pin_kill, not svc_export_put/svc_expkey_put.
4. svc_export_put/svc_expkey_put go though pin_kill logic.

v5, 
let killing fs_pin under a reference of vfsmnt.

v6,
1. revert the change of v5
2. new helper legitimize_mntget() for nfsd exports/expkey cache
   get vfsmount from fs_pin
3. cleanup some codes of sunrpc's cache
4. switch using list_head instead of single list for cache_head
   in cache_detail
5. new functions validate/invalidate for processing of reference
   increase/decrease change (nfsd exports/expkey using grab the
   reference of mnt)
6. delete cache_head directly from cache_detail in pin_kill

v7, 
implement self reference increase and decrease for nfsd exports/expkey 

When reference of cahce_head increase(>1), grab a reference of mnt once.
and reference decrease to 1 (==1), drop the reference of mnt.

v8, Use hash_list for sunrpc cachen and a new method for nfsd's pin,

1. There are only one outlet from each cache, exp_find_key() for expkey, 
   exp_get_by_name() for export.
2. Any fsid to export or filehandle to export will call the function.
3. exp_get()/exp_put() increase/decrease the reference of export.

Call legitimize_mntget() in the only outlet function exp_find_key()/
exp_get_by_name(), if fail return STALE, otherwise, any valid
expkey/export from the cache is validated (Have get the reference of vfsmnt).

Add mntget() in exp_get() and mntput() in exp_put(), because the export
passed to exp_get/exp_put are returned from exp_find_key/exp_get_by_name.

For expkey cache,
1. At first, a fsid is passed to exp_find_key, and lookup a cache
   in svc_expkey_lookup, if success, ekey->ek_path is pined to mount.
2. Then call legitimize_mntget getting a reference of vfsmnt 
   before return from exp_find_key.
3. Any calling exp_find_key with valid cache must put the vfsmnt.

for export cache,
1. At first, a path (returned from exp_find_key) with validate vfsmnt
   is passed to exp_get_by_name, if success, exp->ex_path is pined to mount.
2. Then call legitimize_mntget getting a reference of vfsmnt 
   before return from exp_get_by_name.
3. Any calling exp_get_by_name with valid cache must put the vfsmnt
   by exp_put();
4. Any using the exp returned from exp_get_by_name must call exp_get(),
   will increase the reference of vfsmnt.

So that,
a. After getting the reference in 2, any umount of filesystem will get -EBUSY.
b. After put all reference after 4, or before get the reference in 2, 
   any umount of filesystem will call pin_kill, and delete the cache directly,
   also unpin the vfsmount.
c. Between 1 and 2, have get the reference of exp/key cache, with invalidate vfsmnt.
   As you said, umount of filesystem only wait exp_find_key/exp_get_by_name
   put the reference of cache when legitimize_mntget fail.

Kinglong Mee (9):
  fs_pin: Initialize value for fs_pin explicitly
  fs_pin: Export functions for specific filesystem
  path: New helpers path_get_pin/path_put_unpin for path pin
  fs: New helper legitimize_mntget() for getting a legitimize mnt
  sunrpc: Store cache_detail in seq_file's private, directly
  sunrpc/nfsd: Remove redundant code by exports seq_operations functions
  sunrpc: Switch to using hash list instead single list
  sunrpc: New helper cache_delete_entry for deleting cache_head directly
  nfsd: Allows user un-mounting filesystem where nfsd exports base on

 fs/fs_pin.c                  |   4 +
 fs/namei.c                   |  26 ++++++
 fs/namespace.c               |  19 ++++
 fs/nfsd/export.c             | 209 ++++++++++++++++++++++++-------------------
 fs/nfsd/export.h             |  22 ++++-
 include/linux/fs_pin.h       |   6 ++
 include/linux/mount.h        |   1 +
 include/linux/path.h         |   4 +
 include/linux/sunrpc/cache.h |  10 ++-
 net/sunrpc/cache.c           | 133 ++++++++++++++++-----------
 10 files changed, 286 insertions(+), 148 deletions(-)

-- 
2.4.3

