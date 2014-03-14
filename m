Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:62832 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbaCNRrO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2014 13:47:14 -0400
Received: by mail-qc0-f171.google.com with SMTP id x13so3275281qcv.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2014 10:47:14 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] nfs: consolidate rename code into one set of functions
Date: Fri, 14 Mar 2014 13:47:00 -0400
Message-Id: <1394819225-13713-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As Trond pointed out yesterday, it makes little sense to maintain two
separate sets of functions for handling RENAMEs.

This patchset converts nfs_rename to use the asynchronous RENAME
infrastructure that is already in place for sillyrenames. It also
does some cleanup to remove some minor layering violations, and
adds a patch to make the sillyrename code emit a fsnotify_nameremove
when a sillyrename succeeds.

I've lightly tested this set and it seems to do the right thing,
but it obviously could stand some time in linux-next.

Jeff Layton (5):
  nfs: abstract out code needed to complete a sillyrename
  nfs: make nfs_async_rename non-static
  nfs: convert nfs_rename to use async_rename infrastructure
  nfs: remove synchronous rename code
  nfs: emit a fsnotify_nameremove call in sillyrename codepath

 fs/nfs/dir.c            | 26 +++++++++++++++++++++-----
 fs/nfs/internal.h       |  7 +++++++
 fs/nfs/nfs3proc.c       | 36 ------------------------------------
 fs/nfs/nfs4proc.c       | 44 --------------------------------------------
 fs/nfs/proc.c           | 25 -------------------------
 fs/nfs/unlink.c         | 35 ++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs.h  |  1 -
 include/linux/nfs_xdr.h |  3 +--
 8 files changed, 59 insertions(+), 118 deletions(-)

-- 
1.8.5.3

