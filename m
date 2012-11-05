Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:52182 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392Ab2KEPWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:21 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017184yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:20 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 00/34] vfs: add the ability to retry lookup and operation to most path-based syscalls
Date: Mon,  5 Nov 2012 10:21:39 -0500
Message-Id: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset retrofits most of the path-based syscalls in the kernel to
retry the lookup and operation when the operation returns ESTALE. There
might be a few more that need similar changes afterward, but this should
cover most of the ones people are interested in.

The prerequisite patches for this set were merged in 3.7. I think that
these are appropriate for 3.8. There are some changes since I last
posted the set:

- the do_unlinkat patch has been respun to reorganize the function for
  greater clarity. It now uses a do-while loop and a comment has been
  added that points out the need to reset the "inode" variable on each
  pass through the loop.

- a few of the patches were not setting the "retry" arguments on some
  of the path lookup wrappers properly. Those have now been fixed so
  the code should now properly set LOOKUP_REVAL on lookup reattempts.

- I've also added a patches to ensure that lookups are making forward
  progress. This is necessary to prevent fruitless retries on a path
  based syscall when the process' cwd goes stale. We don't really
  need this though unless we plan to add the tunable to allow more
  retries.

- A patch to add a sliding backoff delay between timeouts has been
  added. This is a nice-to-have if we're planning to make the estale
  retries tunable.

I'm happy to report that with this set, I was able to run Peter
Staubach's reproducer program from 2008 for as long as I liked providing
I cranked up the estale_retries value to a large number. [1]

At the very least, I'd like to see the first 28 patches merged for 3.8.

The rest are not strictly needed unless we want to make the number of
retry attempts tunable. I've added them here since they demonstrate how
I tested these patches. It's too hard to verify that they actually do
what they're supposed to if you only retry once.

These patches are also available in the "estale" branch of my git tree
if that makes it easier to merge them:

    git://git.samba.org/jlayton/linux.git estale

[1]: Peter's test program is here: https://lkml.org/lkml/2008/1/18/265
     I commented out the inotify_test since I haven't patched those
     syscalls. The test was done by running this program on the server
     and the client at the same time in the same directory. If I
     cranked up estale_retries to a large value (10000000 or so), then
     it would run indefinitely.

Jeff Layton (34):
  vfs: add a retry_estale helper function to handle retries on ESTALE
  vfs: make fstatat retry on ESTALE errors from getattr call
  vfs: fix readlinkat to retry on ESTALE
  vfs: add new "reval" argument to kern_path_create and
    user_path_create
  vfs: fix mknodat to retry on ESTALE errors
  vfs: fix mkdir to retry on ESTALE errors
  vfs: fix symlinkat to retry on ESTALE errors
  vfs: fix linkat to retry on ESTALE errors
  vfs: add a reval argument to user_path_parent
  vfs: make rmdir retry on ESTALE errors
  vfs: make do_unlinkat retry on ESTALE errors
  vfs: fix renameat to retry on ESTALE errors
  vfs: have do_sys_truncate retry once on an ESTALE error
  vfs: have faccessat retry once on an ESTALE error
  vfs: have chdir retry lookup and call once on ESTALE error
  vfs: make chroot retry once on ESTALE error
  vfs: make fchmodat retry once on ESTALE errors
  vfs: make fchownat retry once on ESTALE errors
  vfs: fix user_statfs to retry once on ESTALE errors
  vfs: allow utimensat() calls to retry once on an ESTALE error
  vfs: allow setxattr to retry once on ESTALE errors
  vfs: allow lsetxattr() to retry once on ESTALE errors
  vfs: make getxattr retry once on an ESTALE error
  vfs: make lgetxattr retry once on ESTALE
  vfs: make listxattr retry once on ESTALE error
  vfs: make llistxattr retry once on ESTALE error
  vfs: make removexattr retry once on ESTALE
  vfs: make lremovexattr retry once on ESTALE error
  vfs: convert do_filp_open to use retry_estale helper
  vfs: convert do_file_open_root to use retry_estale helper
  vfs: convert filename_lookup to use retry_estale helper
  vfs: ensure that forward progress is being made on pathwalks
  vfs: make number of ESTALE retries tunable
  vfs: add a sliding backoff delay between ESTALE retries

 arch/powerpc/platforms/cell/spufs/syscalls.c |   2 +-
 drivers/base/devtmpfs.c                      |   7 +-
 fs/namei.c                                   | 404 ++++++++++++++++++---------
 fs/ocfs2/refcounttree.c                      |   3 +-
 fs/open.c                                    | 252 +++++++++--------
 fs/stat.c                                    |  32 ++-
 fs/statfs.c                                  |  14 +-
 fs/utimes.c                                  |  17 +-
 fs/xattr.c                                   | 152 ++++++----
 include/linux/fs.h                           |  22 ++
 include/linux/namei.h                        |   4 +-
 kernel/sysctl.c                              |   7 +
 net/unix/af_unix.c                           |   2 +-
 13 files changed, 582 insertions(+), 336 deletions(-)

-- 
1.7.11.7

