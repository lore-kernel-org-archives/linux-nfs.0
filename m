Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247Ab3CCAIh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Mar 2013 19:08:37 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Sun, 3 Mar 2013 00:08:34 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AB5FC@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

We've just concluded another Connectathon interoperability testing week,
and so here are the fixes for the bugs that were discovered.

Cheers,
  Trond

The following changes since commit 666b3d803a511fbc9bc5e5ea8ce66010cf03ea13:

  NLM: Ensure that we resend all pending blocking locks after a reclaim (2013-02-19 12:18:27 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.9-2

for you to fetch changes up to 512e4b291c0e97af24619a91f3e8963697da00d8:

  SUNRPC: One line comment fix (2013-03-02 15:54:11 -0800)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.9

- Don't allow NFS silly-renamed files to be deleted
- Don't start the retransmission timer when out of socket space
- Fix a couple of pnfs-related Oopses.
- Fix one more NFSv4 state recovery deadlock
- Don't loop forever when LAYOUTGET returns NFS4ERR_LAYOUTTRYLATER

----------------------------------------------------------------
Benny Halevy (1):
      pnfs: fix resend_to_mds for directio

Jeff Layton (1):
      nfs: don't allow nfs_find_actor to match inodes of the wrong type

Trond Myklebust (4):
      NFS: Don't allow NFS silly-renamed files to be deleted, no signal
      SUNRPC: Don't start the retransmission timer when out of socket space
      NFSv4: Fix another open/open_recovery deadlock
      SUNRPC: One line comment fix

Weston Andros Adamson (4):
      NFSv4.1: Hold reference to layout hdr in layoutget
      PNFS: set the default DS timeout to 60 seconds
      SUNRPC: add call to get configured timeout
      NFSv4.1: LAYOUTGET EDELAY loops timeout to the MDS

 fs/nfs/inode.c              |  2 ++
 fs/nfs/nfs4filelayout.c     |  6 ++++--
 fs/nfs/nfs4filelayout.h     |  2 +-
 fs/nfs/nfs4proc.c           | 21 ++++++++++++++++++---
 fs/nfs/pnfs.c               | 21 +++++++++++++--------
 fs/nfs/pnfs.h               |  6 ++++--
 fs/nfs/unlink.c             | 20 +++++++++++++-------
 include/linux/nfs_xdr.h     |  1 +
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 15 +++++++++++++++
 net/sunrpc/xprt.c           |  6 +++++-
 11 files changed, 77 insertions(+), 24 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
