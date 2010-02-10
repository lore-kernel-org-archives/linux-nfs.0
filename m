Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:57223 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672Ab0BJAd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 19:33:28 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay1.corp.sgi.com (Postfix) with ESMTP id DC74C8F80CC
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 16:33:27 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id E8A9248F3C1A
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 18:33:26 -0600 (CST)
Subject: [RFC PATCH 0/2] nfsd sync export_op (was 'wsync export option')
To: linux-nfs@vger.kernel.org
From: Ben Myers <bpm@sgi.com>
Date: Tue, 09 Feb 2010 18:33:26 -0600
Message-ID: <20100210003220.6021.74943.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is another try based upon Christoph and Trond's suggestions in the 'wsync
export option' thread.  I've added the export operation and combined
nfsd_sync_dir and write_inode_now usage into nfsd_sync2 which passes the buck
onto XFS.  It's been very lightly tested.  It's just a little bit faster than
the previous try:

# time tar -xvf /mnt2/quilt-0.47.tar > /dev/null

plain jane:
0m13.177s       0m13.301s       0m13.528s

previous try:
0m8.361s        0m8.400s        0m8.301s

w/ xfs commit_metadata op:
0m7.426s        0m7.340s        0m7.198s

Thanks!
-Ben

---

Ben Myers (2):
      commit_metadata export operation and nfsd_sync2
      xfs_export_operations.commit_metadata


 fs/nfsd/nfs3proc.c            |    2 -
 fs/nfsd/nfs4proc.c            |    2 -
 fs/nfsd/nfs4recover.c         |    2 -
 fs/nfsd/nfs4state.c           |    2 -
 fs/nfsd/nfsproc.c             |    4 +
 fs/nfsd/vfs.c                 |  113 ++++++++++++++++++++++++++---------------
 fs/nfsd/vfs.h                 |    4 +
 fs/xfs/linux-2.6/xfs_export.c |   64 +++++++++++++++++++++++
 include/linux/exportfs.h      |    6 ++
 9 files changed, 151 insertions(+), 48 deletions(-)

-- 
