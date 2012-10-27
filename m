Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35875 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2J0Mdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:33:50 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so699669ghb.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:33:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 00/32] vfs: add the ability to retry lookup and operation to most path-based syscalls
Date: Sat, 27 Oct 2012 08:33:07 -0400
Message-Id: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset retrofits most of the path-based syscalls in the kernel to
retry the lookup and operation when the operation returns ESTALE. There
might be a few more that need similar changes afterward, but this should
cover most of the ones people are interested in.

The prerequisite patches for this set were merged in 3.7. I think that
these are appropriate for 3.8. There are some minor changes since I last
posted the set:

- a subtle bug in the do_unlinkat patch was fixed. It's necessary to set
  "inode" to NULL on each pass through the function. This was causing a
  "Busy inodes on umount" error in testing.

- a patch for user_statfs has been added

- patches for do_filp_open, do_file_open_root, and filename_lookup have
  been added to make them use the retry_estale helper function.  These
  don't strictly need changing if we only ever want to make this code
  retry once on an ESTALE error, but I still felt it was best to keep the
  policy on retrying after an ESTALE error in a single function.

- a patch has been added to make the number of ESTALE retries tunable
  via sysctl. The problem I encountered in working on this set was the
  difficulty in testing these changes. By adding this tunable, I could
  crank up the number of retries to a large value to make testing easier.

I'm happy to report that with this set, I was able to run Peter
Staubach's reproducer program from 2008 for as long as I liked providing
I cranked up the estale_retries value to a large number. [1]

At the very least, I'd like to see the first 28 patches merged for 3.8.
The next three in the series I think also make sense for consistency's
sake. If we ever determined that a single retry was not enough, then
they will make changing that policy easier.

I include the final patch for completeness sake since it shows how I
tested the set. That said, since there is no well-defined value that
will work for all cases, allowing a tunable for this makes some sense to
me. [2]

These patches are also available in the "estale" branch of my git tree
if that makes it easier to merge them:

    git://git.samba.org/jlayton/linux.git estale

[1]: Peter's test program is here: https://lkml.org/lkml/2008/1/18/265
     I commented out the inotify_test since I haven't patched those
     syscalls. The test was done by running this program on the server
     and the client at the same time in the same directory. If I
     cranked up estale_retries to a large value (10000000 or so), then
     it would run indefinitely.

[2]: If we do want to allow a tunable however, we might consider "beefing
     up" retry_estale() to add some of the earlier suggestions. For
     instance, checking for fatal signals and an an exponential backoff
     delay. We might also want to do some work to ensure that lookups are
     making forward progress in the face of multiple retries. If we
     do want those, then that's probably best done in a separate patchset.

Jeff Layton (32):
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
  vfs: make number of ESTALE retries tunable

 arch/powerpc/platforms/cell/spufs/syscalls.c |   2 +-
 drivers/base/devtmpfs.c                      |   7 +-
 fs/namei.c                                   | 273 ++++++++++++++++-----------
 fs/ocfs2/refcounttree.c                      |   3 +-
 fs/open.c                                    | 252 ++++++++++++++-----------
 fs/stat.c                                    |  32 +++-
 fs/statfs.c                                  |  14 +-
 fs/utimes.c                                  |  15 +-
 fs/xattr.c                                   | 152 +++++++++------
 include/linux/fs.h                           |  23 +++
 include/linux/namei.h                        |   4 +-
 kernel/sysctl.c                              |   7 +
 net/unix/af_unix.c                           |   2 +-
 13 files changed, 484 insertions(+), 302 deletions(-)

-- 
1.7.11.7

