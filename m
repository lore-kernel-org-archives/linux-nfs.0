Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2K2Qku (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:50 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/9] NFSD: Improve fault injection
Date: Thu, 29 Nov 2012 11:40:37 -0500
Message-Id: <1354207246-32343-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

While working on p2p-nfs, I discovered that I sometimes need to clear
state for a specific client to test all possible error recovery conditions.
The current fault injection code deletes state as it find it, so it can
be difficult to guess which state will be forgotten.  In addition, I
currently print out the amount of state forgotten but I don't give details
like "Forgot 3 locks from client w.x.y.z".  These patches set out to
improve that.

The first 6 patches clean up the current code and prepare it for specific
client state removal.  Patch 7 adds printing information to the server's logs
when a fault injection file is read (such as "Client w.x.y.z has 3 open
files").  Patch 8 adds in a custom file operations structure so users can
write strings to fault injection files in addition to u64s.  Finally, patch
9 allows users to remove state by writing a client's IP address to one of
the files.

Changes in v4:
- Access lock state from open owners rather than requiring a network namespace
  pointer.
- Don't produce a null pointer expection if fault injection is attempted after
  loading the nfsd module but before running any nfsd threads.

- Bryan

Bryan Schumaker (9):
  NFSD: Lock state before calling fault injection function
  NFSD: Clean up forgetting clients
  NFSD: Clean up forgetting locks
  NFSD: Clean up forgetting openowners
  NFSD: Clean up forgetting and recalling delegations
  NFSD: Fault injection operations take a per-client forget function
  NFSD: Reading a fault injection file prints a state count
  NFSD: Add a custom file operations structure for fault injection
  NFSD: Forget state for a specific client

 fs/nfsd/fault_inject.c | 112 ++++++++++++++++++++++++----
 fs/nfsd/netns.h        |   3 +
 fs/nfsd/nfs4state.c    | 197 ++++++++++++++++++++++++++++++-------------------
 fs/nfsd/state.h        |  18 +++--
 4 files changed, 237 insertions(+), 93 deletions(-)

-- 
1.8.0.1

