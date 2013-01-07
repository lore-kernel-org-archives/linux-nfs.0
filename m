Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:62732 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338Ab3AGPpf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 10:45:35 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: linux-kernel <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Mon, 7 Jan 2013 15:45:32 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911990F94@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit d1c3ed669a2d452cacfb48c2d171a1f364dae2ed:

  Linux 3.8-rc2 (2013-01-02 18:13:21 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.8-2

for you to fetch changes up to ecf0eb9edbb607d74f74b73c14af8b43f3729528:

  nfs: avoid dereferencing null pointer in initiate+AF8-bulk+AF8-draining (2013-01-05 14:26:51 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.8

- Fix a permissions problem when opening NFSv4 files that only have the
  exec bit set.
- Fix a couple of typos in pNFS (inverted logic), and the mount parsing
  (missing pointer dereference).
- Work around a series of deadlock issues due to workqueues using
  struct work+AF8-struct pointer address comparisons in the re-entrancy
  tests. Ensure that we don't free struct work+AF8-struct prematurely if
  our work function involves waiting for completion of other work
  items (e.g. by calling rpc+AF8-shutdown+AF8-client).
- Revert the part of commit 168e4b3 that is causing unnecessary warnings
  to be issued in the nfsd callback code.

----------------------------------------------------------------
Nickolai Zeldovich (1):
      nfs: avoid dereferencing null pointer in initiate+AF8-bulk+AF8-draining

Trond Myklebust (3):
      SUNRPC: Ensure that we free the rpc+AF8-task after cleanups are done
      NFS: Ensure that we free the rpc+AF8-task after read and write cleanups are done
      SUNRPC: Partial revert of commit 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9

Weston Andros Adamson (1):
      NFS: Fix access to suid/sgid executables

Xi Wang (1):
      nfs: fix null checking in nfs+AF8-get+AF8-option+AF8-str()

Yanchuan Nian (1):
      pnfs: Increase the refcount when LAYOUTGET fails the first time

 fs/nfs/callback+AF8-proc.c +AHw-  2 +--
 fs/nfs/dir.c           +AHw- 16 +-+-+-+-+-+-+-+-+-+-------
 fs/nfs/nfs4proc.c      +AHw- 18 +-+-+-+-+-+-+-+-+-+-+--------
 fs/nfs/pnfs.c          +AHw-  2 +--
 fs/nfs/read.c          +AHw- 10 +-+-+-+-+-+-+----
 fs/nfs/super.c         +AHw-  2 +--
 fs/nfs/write.c         +AHw- 10 +-+-+-+-+-+-+----
 net/sunrpc/clnt.c      +AHw-  5 -----
 net/sunrpc/sched.c     +AHw- 27 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-----
 9 files changed, 61 insertions(+-), 31 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
