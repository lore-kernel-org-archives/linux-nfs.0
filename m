Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34377 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbFYORs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:17:48 -0400
Message-ID: <558C0D6A.9050104@gmail.com>
Date: Thu, 25 Jun 2015 22:17:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 00/10 v6] NFSD: Pin to vfsmount for nfsd exports cache
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

Right now,

When reference of cahce_head increase(>1), grab a reference of mnt once.
and reference decrease to 1 (==1), drop the reference of mnt.

So after that,
When ref > 1, user cannot umount the filesystem with -EBUSY.
when ref ==1, means cache only reference by nfsd cache,
no other reference. So user can try umount, 
1. before set MNT_UMOUNT (protected by mount_lock), nfsd cache is
   referenced (ref > 1, legitimize_mntget), umount will fail with -EBUSY.
2. after set MNT_UMOUNT, nfsd cache is referenced (ref == 2),
   legitimize_mntget will fail, and set cache to CACHE_NEGATIVE,
   and the reference will be dropped, re-back to 1.
   So, pin_kill can delete the cache and umount success.
3. when umountting, no reference to nfsd cache, 
   pin_kill can delete the cache and umount success.

Kinglong Mee (10):
  fs_pin: Initialize value for fs_pin explicitly
  fs_pin: Export functions for specific filesystem
  path: New helpers path_get_pin/path_put_unpin for path pin
  fs: New helper legitimize_mntget() for getting an legitimize mnt
  sunrpc: Store cache_detail in seq_file's private directly
  sunrpc/nfsd: Remove duplicate code by exports seq_operations functions
  sunrpc: Switch to using list_head instead single list
  sunrpc: New helper cache_delete_entry for deleting cache_head directly
  sunrpc: Support validate/invalidate for reference change in cache_detail
  nfsd: Allows user un-mounting filesystem where nfsd exports base on

 fs/fs_pin.c                       |   4 +
 fs/namei.c                        |  26 ++++
 fs/namespace.c                    |  19 +++
 fs/nfsd/export.c                  | 242 ++++++++++++++++++++++++--------------
 fs/nfsd/export.h                  |  26 +++-
 include/linux/fs_pin.h            |   6 +
 include/linux/mount.h             |   1 +
 include/linux/path.h              |   4 +
 include/linux/sunrpc/cache.h      |  21 +++-
 net/sunrpc/auth_gss/svcauth_gss.c |   2 +-
 net/sunrpc/cache.c                | 159 +++++++++++++++----------
 net/sunrpc/svcauth_unix.c         |   2 +-
 12 files changed, 357 insertions(+), 155 deletions(-)

-- 
2.4.3

