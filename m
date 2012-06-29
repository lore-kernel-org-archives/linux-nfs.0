Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f42.google.com ([209.85.213.42]:59981 "EHLO
	mail-yw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab2F2S6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:07 -0400
Received: by yhfq11 with SMTP id q11so4407138yhf.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:06 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 00/17] vfs: add the ability to retry on ESTALE to several syscalls
Date: Fri, 29 Jun 2012 14:57:43 -0400
Message-Id: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the third version of the patchset to add ESTALE
handling to several syscalls. The basic idea is to allow the client to
gracefully retry the lookup and call when a NFS server returns ESTALE.

The previous version of this patchset is here:

    http://lwn.net/Articles/496103/

When discussing my v2 patchset, Al pointed out that the problems with
audit go beyond just doing multiple getname() calls per syscall attempt.
While that is a problem, the most insidious issue is some very brittle
logic in audit_inode_child(). I believe I now have a solution to that
problem in the patchset that I posted earlier this week:

	https://lkml.org/lkml/2012/6/26/306

The above patchset should make it safe to do retries of path-based
syscalls. The main caveat when doing that is that it's important to only
call getname() once per __user string. That ensures that you don't end
up with duplicate audit_names entries per syscall. As a side benefit, it
turns out that that's more efficient on a retry, but it does mean that
we can't use the nice user_path_* helpers in many cases.

I've tried to keep this patchset pretty granular. Some of these patches
could be combined if that's desirable. I'd like to see this go into 3.6,
but it obviously needs to go in after the above-referenced set of audit
related patches is merged.

Jeff Layton (17):
  vfs: add a retry_estale helper function to handle retries on ESTALE
  vfs: add a kern_path_at function
  vfs: make fstatat retry on ESTALE errors from getattr call
  vfs: fix readlinkat to retry on ESTALE
  vfs: remove user_path_at_empty
  vfs: turn "empty" arg in getname_flags into a bool
  vfs: add new "reval" argument to kern_path_create
  vfs: fix mknodat to retry on ESTALE errors
  vfs: fix mkdir to retry on ESTALE errors
  vfs: fix symlinkat to retry on ESTALE errors
  vfs: fix linkat to retry on ESTALE errors
  vfs: make rmdir retry on ESTALE errors
  vfs: make do_unlinkat retry on ESTALE errors
  vfs: fix renameat to retry on ESTALE errors
  vfs: remove user_path_parent
  vfs: have do_sys_truncate retry once on an ESTALE error
  vfs: have faccessat retry once on an ESTALE error

 drivers/base/devtmpfs.c |    7 +-
 fs/namei.c              |  407 ++++++++++++++++++++++++++++-------------------
 fs/open.c               |  162 +++++++++++--------
 fs/stat.c               |   44 ++++--
 include/linux/fs.h      |   24 +++-
 include/linux/namei.h   |    4 +-
 net/unix/af_unix.c      |    3 +-
 7 files changed, 401 insertions(+), 250 deletions(-)

-- 
1.7.7.6

