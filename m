Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:48571 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756984AbaDWSZJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 14:25:09 -0400
Received: by mail-qc0-f175.google.com with SMTP id e16so1385633qcx.34
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 11:25:08 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfs4: file locking fixes and cleanups
Date: Wed, 23 Apr 2014 14:24:57 -0400
Message-Id: <1398277500-31575-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The impetus for this set was a bug report in Fedora about "sleeping in
atomic context" warning that patch #2 fixes. While looking at that, I
noticed that a LOCKU wasn't being sent in the reproducer provided so I
tracked down and fixed that bug as well.

These are only lightly tested, and could probably use some soak time in
linux-next. Also, I'm not 100% thrilled with queueing the
free_lock_state job submission to a workqueue, but I don't see a better
way to handle it so far.

Jeff Layton (3):
  nfs4: treat lock owners as opaque values
  nfs4: queue free_lock_state job submission to nfsiod
  nfs4: turn free_lock_state into a void return operation

 fs/nfs/nfs4_fs.h   | 26 +++++++--------------
 fs/nfs/nfs4proc.c  | 14 ++++++------
 fs/nfs/nfs4state.c | 67 ++++++++++++++++++++++--------------------------------
 3 files changed, 42 insertions(+), 65 deletions(-)

-- 
1.9.0

