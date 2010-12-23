Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56099 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab0LWVyJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 16:54:09 -0500
Received: by iwn9 with SMTP id 9so6550865iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 13:54:09 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Refactor data structures to support NFSv4 migration
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 23 Dec 2010 16:54:05 -0500
Message-ID: <20101223214503.2344.79300.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

Here are four patches that move fields related to NFSv4 state from the
nfs_client struct to the nfs_server struct, in order to facilitate the
eventual implementation of NFSv4 migration.

This series should address all recent review comments.  It passes my
simple tests here:  Full cthon suite passes over NFSv4 against an
OpenSolaris 2009.6 NFS server, and a full -j3 kernel build on NFSv4
completes without hangs or lockdep splats on a two-way client.  The
kernel build usually generates some delegation activity with this
Solaris server.

---

Chuck Lever (4):
      NFS: Move cl_delegations to the nfs_server struct
      NFS: Introduce nfs_detach_delegations()
      NFS: Move cl_state_owners and related fields to the nfs_server struct
      NFS: Allow walking nfs_client.cl_superblocks list outside client.c


 fs/nfs/client.c           |   48 +++---
 fs/nfs/delegation.c       |  362 ++++++++++++++++++++++++++++++++-------------
 fs/nfs/delegation.h       |    1 
 fs/nfs/nfs4_fs.h          |    2 
 fs/nfs/nfs4renewd.c       |   11 +
 fs/nfs/nfs4state.c        |  239 +++++++++++++++++++++---------
 include/linux/nfs_fs_sb.h |   11 +
 7 files changed, 474 insertions(+), 200 deletions(-)

-- 
Chuck Lever
