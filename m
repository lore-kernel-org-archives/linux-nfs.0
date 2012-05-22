Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65249 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab2EVOMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:25 -0400
Received: by yhmm54 with SMTP id m54so5458934yhm.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:25 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 00/15] vfs: add the ability to retry on ESTALE to several syscalls
Date: Tue, 22 May 2012 10:12:04 -0400
Message-Id: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the second version of the patchset to add ESTALE
handling to several syscalls. The previous version is here:

    http://lwn.net/Articles/496103/

I spoke with Al Viro about my previous set and he pointed out something
I had not considered. getname() has side effects when auditing is
enabled, so if we end up calling it multiple times for the same names,
we'll make a mess of the audit handling.

This patchset is a revised version that should fix that by ensuring that
we only call getname() once per __user path, per syscall. In order to do
that, I had to break up some of the nice user_path_* wrappers.

I've tried to keep this patchset pretty granular. Some of these patches
could be combined if that's desirable. It's probably too late for 3.5
here, but I'd like to see this considered for 3.6 if possible.

Jeff Layton (15):
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

 drivers/base/devtmpfs.c |    7 +-
 fs/namei.c              |  407 ++++++++++++++++++++++++++++-------------------
 fs/stat.c               |   44 ++++--
 include/linux/fs.h      |   24 +++-
 include/linux/namei.h   |    4 +-
 net/unix/af_unix.c      |    3 +-
 6 files changed, 310 insertions(+), 179 deletions(-)

-- 
1.7.7.6

