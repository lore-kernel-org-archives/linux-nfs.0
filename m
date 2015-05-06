Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33667 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbEFNS0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:18:26 -0400
Message-ID: <554A149B.5060102@gmail.com>
Date: Wed, 06 May 2015 21:18:19 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 0/4] NFSD: Pin to vfsmount instead of mntget for export cache
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

I don't think that's user expect, they want umount /nfs/test/.

It's caused by exports cache of nfsd holds the reference of
the path (here is /nfs/test/), so, it can't be umounted.

The patch site using fs_pin instead of mntget for export cache,
user at nfs server can unmount any mount points includes exported
for nfs. Maybe, only umounted for unexported mount points is better?

[PATCH 1/4] fs_pin: Fix uninitialized value in fs_pin
[PATCH 2/4] fs_pin: Export functions for specific filesystem
[PATCH 3/4] sunrpc: New helper cache_force_expire for cache cleanup
[PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget

Kinglong Mee (4):
  fs_pin: initialize done to zero
  fs_pin: export functions for nactive filesystem
  sunrpc: new helper cache_force_expire for deleting a cache
  nfsd: pin to mnt insteads mntget

 fs/fs_pin.c                  |  3 +++
 fs/nfsd/export.c             | 37 ++++++++++++++++++++++++++++++-------
 fs/nfsd/export.h             | 10 +++++++++-
 include/linux/fs_pin.h       |  1 +
 include/linux/sunrpc/cache.h | 11 +++++++++++
 5 files changed, 54 insertions(+), 8 deletions(-)

-- 
2.4.0

