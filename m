Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60931 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092Ab3AaTrg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2013 14:47:36 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes
Date: Thu, 31 Jan 2013 19:47:33 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91834580F@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,
The following changes since commit 949db153b6466c6f7cad5a427ecea94985927311:

  Linux 3.8-rc5 (2013-01-25 11:57:28 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.8-4

for you to fetch changes up to c489ee290bdbbace6bb63ebe6ebd4dd605819495:

  NFSv4.1: Handle NFS4ERR_DELAY when resetting the NFSv4.1 session (2013-01-30 17:45:15 -0500)

----------------------------------------------------------------
NFS client bugfixe for Linux 3.8

- Error reporting in nfs_xdev_mount incorrectly maps all errors to ENOMEM
- Fix an NFSv4 refcounting issue
- Fix a mount failure when the server reboots during NFSv4 trunking discovery
- NFSv4.1 mounts may need to run the lease recovery thread.
- Don't silently fail setattr() requests on mountpoints
- Fix a SUNRPC socket/transport livelock and priority queue issue
- We must handle NFS4ERR_DELAY when resetting the NFSv4.1 session.

----------------------------------------------------------------
Trond Myklebust (7):
      NFS: Fix error reporting in nfs_xdev_mount
      NFSv4: Fix NFSv4 reference counting for trunked sessions
      NFSv4: Fix NFSv4 trunking discovery
      NFSv4.1: Ensure that nfs41_walk_client_list() does start lease recovery
      NFS: Don't silently fail setattr() requests on mountpoints
      SUNRPC: When changing the queue priority, ensure that we change the owner
      NFSv4.1: Handle NFS4ERR_DELAY when resetting the NFSv4.1 session

 fs/nfs/namespace.c  | 20 +++++++++++++++++
 fs/nfs/nfs4client.c | 62 ++++++++++++++++++++++-------------------------------
 fs/nfs/nfs4state.c  | 22 ++++++++++++-------
 fs/nfs/super.c      | 22 ++++++++-----------
 net/sunrpc/sched.c  | 18 +++++++++++++++-
 5 files changed, 86 insertions(+), 58 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
