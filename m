Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:34694 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbINNqC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 09:46:02 -0400
Received: by ykdg206 with SMTP id g206so152581850ykd.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 06:46:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 0/4] fs: allow userland tasks to use delayed_fput infrastructure
Date: Mon, 14 Sep 2015 09:45:51 -0400
Message-Id: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm breaking this piece out of the open file cache work for nfsd to see
if we can get this piece settled before I re-post the whole set. If this
looks like a reasonable approach we can sort out how it should be merged
(either by you directly, or via Bruce's tree with the rest of the open
file cache patches).

For those just joining in, some background:

We want to add an open file cache for nfsd to reduce the open/close
overhead on READ/WRITE RPCs, and so we can eliminate the raparm cache.
The basic idea is to keep a cache of open files, and close them down on
certain sorts of activity -- primarily, after an unlink that takes the
link count to 0, or before setting a lease.

The setlease part is problematic though. The plan is to have a notifier
callback into nfsd from vfs_setlease that will tell nfsd to close any
open files that are associated with the inode so we don't block lease
attempts solely due to cached but otherwise idle nfsd files. That means
that we need to be able to close out the files and ensure that the final
__fput runs before we try to set a lease.

My latest pass involved making __fput_sync available to userland tasks,
but Al had concerns that that could lead to stack blowouts. This
patchset is an alternative approach that allows userland tasks to use
the delayed_fput infrastructure instead. The idea is that we'd have the
pre-setlease notifier do a fput_queue() and then call flush_delayed_fput
to ensure that any queued __fput() calls complete before setting the
lease.

There's also a fix for a potential race in flush_delayed_fput in here
and some doc comment cleanups.

Al, does this look more acceptable than using __fput_sync?

Jeff Layton (4):
  fs: have flush_delayed_fput flush the workqueue job
  fs: add a kerneldoc header to fput
  fs: add fput_queue
  fs: export flush_delayed_fput

 fs/file_table.c      | 57 +++++++++++++++++++++++++++++++++++++++++-----------
 include/linux/file.h |  1 +
 2 files changed, 46 insertions(+), 12 deletions(-)

-- 
2.4.3

