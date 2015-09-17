Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35751 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbbIQMjx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 08:39:53 -0400
Received: by ykdu9 with SMTP id u9so15110366ykd.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 05:39:53 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/4] fs: allow userland tasks to use delayed_fput infrastructure
Date: Thu, 17 Sep 2015 08:39:43 -0400
Message-Id: <1442493587-32499-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- kerneldoc header cleanups. Hopefully they are more clear now
- make fput_queue return bool, telling whether the final reference was
  put. Caller can use that to tell whether it should call
  flush_delayed_fput.

Only minor changes since the last set. Al, does this look any more
reasonable? Original cover letter follows:

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
but Al had concerns that that could lead to stack blowouts and locking
issues. This patchset is an alternative approach that allows userland
tasks to use the delayed_fput infrastructure instead. The idea is that
we'd have the pre-setlease notifier do a fput_queue() and then call
flush_delayed_fput to ensure that any queued __fput() calls complete
before setting the lease.

There's also a fix for a potential race in flush_delayed_fput in here
and some doc comment cleanups.

Jeff Layton (4):
  fs: have flush_delayed_fput flush the workqueue job
  fs: add a kerneldoc header to fput
  fs: add fput_queue
  fs: export flush_delayed_fput

 fs/file_table.c      | 76 +++++++++++++++++++++++++++++++++++++++++++---------
 include/linux/file.h |  1 +
 2 files changed, 64 insertions(+), 13 deletions(-)

-- 
2.4.3

