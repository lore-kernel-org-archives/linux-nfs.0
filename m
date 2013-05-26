Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64175 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906Ab3EZT3N convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 May 2013 15:29:13 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Sun, 26 May 2013 19:29:11 +0000
Message-ID: <1369596545.12593.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit f722406faae2d073cc1d01063d1123c35425939e:

  Linux 3.10-rc1 (2013-05-11 17:14:08 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.10-3

for you to fetch changes up to 83c168bf8017212a9d502536f9dcd0b54d24e330:

  NFS: Fix SETCLIENTID fallback if GSS is not available (2013-05-23 18:50:40 -0400)

----------------------------------------------------------------
NFS client bugfixes for 3.10

- Stable fix to prevent an rpc_task wakeup race
- Fix a NFSv4.1 session drain deadlock
- Fix a NFSv4/v4.1 mount regression when not running rpc.gssd
- Ensure auth_gss pipe detection works in namespaces
- Fix SETCLIENTID fallback if rpcsec_gss is not available

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4.1 Fix a pNFS session draining deadlock

Chuck Lever (1):
      NFS: Fix SETCLIENTID fallback if GSS is not available

Trond Myklebust (4):
      SUNRPC: Fix a bug in gss_create_upcall
      SUNRPC: Faster detection if gssd is actually running
      SUNRPC: Convert auth_gss pipe detection to work in namespaces
      SUNRPC: Prevent an rpc_task wakeup race

 fs/nfs/callback_proc.c         |  2 +-
 fs/nfs/callback_xdr.c          |  2 +-
 fs/nfs/nfs4client.c            |  2 +-
 fs/nfs/nfs4proc.c              |  2 +-
 fs/nfs/nfs4session.c           |  4 +--
 fs/nfs/nfs4session.h           | 13 +++++----
 fs/nfs/nfs4state.c             | 15 +++++-----
 net/sunrpc/auth_gss/auth_gss.c | 62 ++++++++++++++++++++++++++++--------------
 net/sunrpc/netns.h             |  4 +++
 net/sunrpc/rpc_pipe.c          |  5 ++++
 net/sunrpc/sched.c             |  8 +++++-
 11 files changed, 78 insertions(+), 41 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
