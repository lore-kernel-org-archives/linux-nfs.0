Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:64503 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932448Ab3HNX0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:26:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 00/13] NFSv4 add debugging tracepoints
Date: Wed, 14 Aug 2013 19:24:45 -0400
Message-ID: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset sets up a number of ftrace tracepoints for use
when debugging state operations.

Changes in v2:
 - Fixed compile bugs
 - We need to convert the delegation recall status to a negative number
 - Added tracepoints for read/write, pnfs and slot table debugging.

Trond Myklebust (13):
  NFSv4: Add tracepoints for debugging state management problems
  NFS: refactor code for calculating the crc32 hash of a filehandle
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

 fs/nfs/Makefile         |   3 +-
 fs/nfs/callback_proc.c  |   3 +
 fs/nfs/delegation.c     |   3 +
 fs/nfs/idmap.c          |   5 +
 fs/nfs/inode.c          |   3 +-
 fs/nfs/internal.h       |  20 +
 fs/nfs/nfs4filelayout.c |  10 +
 fs/nfs/nfs4proc.c       | 135 +++++--
 fs/nfs/nfs4session.h    |  10 +
 fs/nfs/nfs4trace.c      |  17 +
 fs/nfs/nfs4trace.h      | 969 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c           |   7 +
 12 files changed, 1146 insertions(+), 39 deletions(-)
 create mode 100644 fs/nfs/nfs4trace.c
 create mode 100644 fs/nfs/nfs4trace.h

-- 
1.8.3.1

