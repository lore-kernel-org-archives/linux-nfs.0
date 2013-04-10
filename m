Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60294 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab3DJP7i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 11:59:38 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Linux linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes
Date: Wed, 10 Apr 2013 15:59:28 +0000
Message-ID: <1365609573.8465.5.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 1166fde6a923c30f4351515b6a9a1efc513e7d00:

  SUNRPC: Add barriers to ensure read ordering in rpc_wake_up_task_queue_locked (2013-03-25 11:23:40 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.9-4

for you to fetch changes up to fa332941c0c7c00e3420078268b7558d0ef792b5:

  NFSv4: Fix another potential state manager deadlock (2013-04-09 13:19:35 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.9

- Stable fix for memory corruption issues in nfs4[01]_walk_client_list
- Stable fix for an Oopsable bug in rpc_clone_client
- Another state manager deadlock in the NFSv4 open code
- Memory leaks in nfs4_discover_server_trunking and rpc_new_client

----------------------------------------------------------------
Chuck Lever (1):
      SUNRPC: Remove extra xprt_put()

Trond Myklebust (4):
      NFSv4: Fix a memory leak in nfs4_discover_server_trunking
      NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list
      SUNRPC: Fix a potential memory leak in rpc_new_client
      NFSv4: Fix another potential state manager deadlock

 fs/nfs/nfs4client.c | 44 ++++++++++++++++++++++++++++----------------
 fs/nfs/nfs4proc.c   |  1 +
 fs/nfs/nfs4state.c  |  8 +++++++-
 net/sunrpc/clnt.c   | 11 +++--------
 4 files changed, 39 insertions(+), 25 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
