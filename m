Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49414 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188Ab3HTTfQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:16 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 00/16] NFS add tracepoints
Date: Tue, 20 Aug 2013 15:34:56 -0400
Message-ID: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset sets up a number of ftrace tracepoints for use
when debugging state operations and NFS performance issues.

Changes in v2:
 - Fixed compile bugs
 - We need to convert the delegation recall status to a negative number
 - Added tracepoints for read/write, pnfs and slot table debugging.

Changes in v3:
 - Added tracepoints for generic NFS code
   - lookups
   - atomic open
   - inode cache consistency operations
   - internal fsync and data flush operations
 - Assorted cleanups and bugfixes


Trond Myklebust (16):
  NFS: refactor code for calculating the crc32 hash of a filehandle
  NFS: Add event tracing for generic NFS events
  NFS: Pass in lookup flags from nfs_atomic_open to nfs_lookup
  NFS: Add event tracing for generic NFS lookups
  NFSv4: Add tracepoints for debugging state management problems
  NFSv4: Add tracepoints for debugging file open
  NFSv4: Add tracepoints for debugging file locking
  NFSv4: Add tracepoints for debugging lookup/create operations
  NFSv4: Add tracepoints for debugging inode manipulations
  NFSv4: Add tracepoints for debugging rename
  NFSv4: Add tracepoints for debugging delegations
  NFSv4: Add tracepoints for debugging the idmapper
  NFSv4: Add tracepoints for debugging getattr
  NFSv4: Add tracepoints for debugging reads and writes
  NFSv4.1: Add tracepoints for debugging layoutget/return/commit
  NFSv4.1: Add tracepoints for debugging slot table operations

 fs/nfs/Makefile         |    5 +-
 fs/nfs/callback_proc.c  |    3 +
 fs/nfs/delegation.c     |    3 +
 fs/nfs/dir.c            |   27 +-
 fs/nfs/file.c           |    5 +
 fs/nfs/idmap.c          |    5 +
 fs/nfs/inode.c          |   32 +-
 fs/nfs/internal.h       |   20 +
 fs/nfs/nfs4filelayout.c |    4 +
 fs/nfs/nfs4proc.c       |  131 ++++--
 fs/nfs/nfs4session.h    |   10 +
 fs/nfs/nfs4trace.c      |   17 +
 fs/nfs/nfs4trace.h      | 1109 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfstrace.c       |    9 +
 fs/nfs/nfstrace.h       |  358 +++++++++++++++
 fs/nfs/pnfs.c           |    3 +
 fs/nfs/write.c          |   15 +-
 17 files changed, 1705 insertions(+), 51 deletions(-)
 create mode 100644 fs/nfs/nfs4trace.c
 create mode 100644 fs/nfs/nfs4trace.h
 create mode 100644 fs/nfs/nfstrace.c
 create mode 100644 fs/nfs/nfstrace.h

-- 
1.8.3.1

