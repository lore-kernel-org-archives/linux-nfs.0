Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35981 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194Ab2EGOMT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 10:12:19 -0400
Received: by yenm10 with SMTP id m10so3663285yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 May 2012 07:12:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 RESEND 00/12] vfs: add the ability to retry on ESTALE to several syscalls
Date: Mon,  7 May 2012 10:11:59 -0400
Message-Id: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ESTALE errors are a source of pain for many users, primarily those who
are doing work on NFS. When userspace provides a path to a syscall, then
there's really little excuse for returning ESTALE. If userspace gave us
a path that we had to lookup in order to do the call, then it's not
particularly helpful to return ESTALE just because that path went stale
before we could do the actual operation.

We can and should do better here. The kernel should instead catch that
error and retry the lookup and call, while forcing a revalidation of all
dentries involved.

Unfortunately fixing this requires touching the syscalls themselves, or
at least their immediate helper functions. Not all syscalls can be
retried -- only those that take a pathname as an argument.

This set is a first "official" pass at adding ESTALE retry handling to
various syscalls.  With this patchset, I've decided to take the
relatively less controversial approach of just having the kernel retry
once when it gets an ESTALE error. I still think that it's not as strong
as it should be, but it should improve the situation in many common
cases.

I've also tried to engineer this in such a way that if we do decide that
we need to retry more than once, then it should be easy to change that
later. This should cover all of the syscalls in fs/stat.c and
fs/namei.c.

If this approach is reasonable I'll look at adding similar handling to
other path-based vfs calls in a another set. A quick look shows that
we have about 50-odd path-based syscalls that will need similar
handling, so this is just a start.

Comments welcome...

Jeff Layton (12):
  vfs: add a retry_estale helper function to handle retries on ESTALE
  vfs: make fstatat retry on ESTALE errors from getattr call
  vfs: fix readlinkat to retry on ESTALE
  vfs: add new "reval" argument to kern_path_create and
    user_path_create
  vfs: fix mknodat to retry on ESTALE errors
  vfs: fix mkdir to retry on ESTALE errors
  vfs: add a "reval" flag to args for user_path_parent
  vfs: make rmdir retry on ESTALE errors
  vfs: make do_unlinkat retry on ESTALE errors
  vfs: fix symlinkat to retry on ESTALE errors
  vfs: fix linkat to retry on ESTALE errors
  vfs: fix renameat to retry on ESTALE errors

 arch/powerpc/platforms/cell/spufs/syscalls.c |    2 +-
 drivers/base/devtmpfs.c                      |    7 +-
 fs/namei.c                                   |  233 +++++++++++++++-----------
 fs/ocfs2/refcounttree.c                      |    3 +-
 fs/stat.c                                    |   32 +++-
 include/linux/fs.h                           |   21 +++
 include/linux/namei.h                        |    4 +-
 net/unix/af_unix.c                           |    3 +-
 8 files changed, 191 insertions(+), 114 deletions(-)

-- 
1.7.7.6

