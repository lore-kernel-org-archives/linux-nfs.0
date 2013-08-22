Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63017 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806Ab3HVAYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:22 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 00/21] NFS add tracepoints (final version)
Date: Wed, 21 Aug 2013 20:23:58 -0400
Message-ID: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset sets up a number of ftrace tracepoints for use
when debugging NFSv4 state operations and NFS performance issues.

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

Changes in v4:
 - Fix the include file bug
 - Add more tracepoints for the generic NFS code
   - rename and sillyrename
   - generic directory related changes (file create/mknod/mkdir/rmdir/...)
 - Add debugging for NFSv4 free stateid events

Trond Myklebust (21):
  NFS: refactor code for calculating the crc32 hash of a filehandle
  NFS: Add event tracing for generic NFS events
  NFS: Pass in lookup flags from nfs_atomic_open to nfs_lookup
  NFS: Add event tracing for generic NFS lookups
  NFS: Add tracepoints for debugging generic file create events
  NFS: Add tracepoints for debugging directory changes
  NFS: Add tracepoints for debugging NFS rename and sillyrename issues
  NFS: Add tracepoints for debugging NFS hard links
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
  NFSv4.1: Add tracepoints for debugging test_stateid events

 fs/nfs/Makefile         |    7 +-
 fs/nfs/callback_proc.c  |    3 +
 fs/nfs/delegation.c     |    3 +
 fs/nfs/dir.c            |   49 +-
 fs/nfs/file.c           |    5 +
 fs/nfs/idmap.c          |    5 +
 fs/nfs/inode.c          |   32 +-
 fs/nfs/internal.h       |   20 +
 fs/nfs/nfs4filelayout.c |    4 +
 fs/nfs/nfs4proc.c       |  130 ++++--
 fs/nfs/nfs4session.h    |   10 +
 fs/nfs/nfs4trace.c      |   17 +
 fs/nfs/nfs4trace.h      | 1148 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfstrace.c       |    9 +
 fs/nfs/nfstrace.h       |  729 ++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c           |    3 +
 fs/nfs/unlink.c         |    5 +
 fs/nfs/write.c          |   15 +-
 18 files changed, 2142 insertions(+), 52 deletions(-)
 create mode 100644 fs/nfs/nfs4trace.c
 create mode 100644 fs/nfs/nfs4trace.h
 create mode 100644 fs/nfs/nfstrace.c
 create mode 100644 fs/nfs/nfstrace.h

-- 
1.8.3.1

