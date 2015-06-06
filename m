Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34602 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbbFFO4M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 10:56:12 -0400
Message-ID: <5573068B.5010406@gmail.com>
Date: Sat, 06 Jun 2015 22:41:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 0/5 v4] NFSD: Pin to vfsmount for nfsd exports cache
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

Kinglong Mee (5):
  fs_pin: Initialize value for fs_pin explicitly
  fs_pin: Export functions for specific filesystem
  path: New helpers path_get_pin/path_put_unpin for path pin
  sunrpc: New helper cache_force_expire for cache cleanup
  nfsd: Allows user un-mounting filesystem where nfsd exports base on

 fs/fs_pin.c                  |  4 ++
 fs/namei.c                   | 26 ++++++++++++
 fs/nfsd/export.c             | 96 +++++++++++++++++++++++++++++++++++---------
 fs/nfsd/export.h             | 18 ++++++++-
 include/linux/fs_pin.h       |  6 +++
 include/linux/path.h         |  4 ++
 include/linux/sunrpc/cache.h | 11 +++++
 7 files changed, 146 insertions(+), 19 deletions(-)

-- 
2.4.2

