Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:35564 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755516Ab0BCXo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:44:26 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay3.corp.sgi.com (Postfix) with ESMTP id 9D9FCAC036
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:44:25 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 7E22E48D6BF8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 17:44:24 -0600 (CST)
Subject: [RFC PATCH 0/4] wsync export option
To: linux-nfs@vger.kernel.org
From: Ben Myers <bpm@sgi.com>
Date: Wed, 03 Feb 2010 17:44:24 -0600
Message-ID: <20100203233755.17677.96582.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In April I did some research on why synchronous NFSv3 performance on XFS is so
rotten when compared to local filesystem performance.  The workload I chose to
work with is tar.

After taking some measurements I came to the conclusion that one of the big
problems is that we're not treating the log as stable storage.  By calling
write_inode_now() we've written the changes to the log first and then gone and
also written them out to the inode on disk.

In a short discussion of this issue on the xfs-oss list it was suggested that I
post the patches here for discussion.

The following series is adds a 'wsync' export option to nfsd.  It is intended
to be used on XFS with the wsync mount option.  When you already have a
synchronous log there is no need to sync metadata separately.

This is barely tested, YMMV, I could have this all wrong, etc, etc.  Here are
some very unscientific measurements taken over gigabit ethernet.

# time tar -xvf /mnt2/quilt-0.47.tar > /dev/null

No XFS wsync, no NFS wsync:
0m13.177s	0m13.301s	0m13.528s

XFS wsync set, no NFS wsync:
0m13.019s	0m13.232s	0m13.094s

XFS wsync set, NFS wsync set:
0m8.361s	0m8.400s	0m8.301s

Curious to hear if this is a reasonable thing to do.  Suggestions welcome.

Thanks!
	Ben

---

Ben Myers (4):
      Add 'wsync' export option.
      Add datasync argument to nfsd_sync_dir().
      If 'wsync' call vfs_fsync() instead of write_inode_now().
      If 'wsync' pass datasync=1 to vfs_fsync().


 fs/nfsd/export.c            |    1 +
 fs/nfsd/nfs4recover.c       |    2 +
 fs/nfsd/vfs.c               |   62 +++++++++++++++++++++++++++++++------------
 fs/nfsd/vfs.h               |    2 +
 include/linux/nfsd/export.h |    4 ++-
 5 files changed, 50 insertions(+), 21 deletions(-)
