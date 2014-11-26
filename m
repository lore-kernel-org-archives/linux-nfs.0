Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12611 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbaKZQMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 11:12:36 -0500
Message-ID: <5475FBF2.3080605@Netapp.com>
Date: Wed, 26 Nov 2014 11:12:34 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull additional NFS client changes for 3.19
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 5d01410fe4d92081f349b013a2e7a95429e4f2c9:

  Linux 3.18-rc6 (2014-11-23 15:25:20 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-cel-for-3.19

for you to fetch changes up to c2ef47b7f518f5eae5ffed11b8ac754fb263d398:

  NFS: Clean up nfs4_init_callback() (2014-11-25 16:22:16 -0500)

Thanks!
Anna

----------------------------------------------------------------
NFS: Generic client side changes from Chuck

These patches fixes for iostats and SETCLIENTID in addition to cleaning
up the nfs4_init_callback() function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Chuck Lever (3):
      SUNRPC: serialize iostats updates
      NFS: SETCLIENTID XDR buffer sizes are incorrect
      NFS: Clean up nfs4_init_callback()

 fs/nfs/nfs4client.c            | 31 ++++++++++++++-----------------
 fs/nfs/nfs4xdr.c               | 10 ++++++----
 include/linux/sunrpc/metrics.h |  3 +++
 net/sunrpc/stats.c             | 21 ++++++++++++++++-----
 4 files changed, 39 insertions(+), 26 deletions(-)
