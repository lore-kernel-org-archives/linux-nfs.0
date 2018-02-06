Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:55884 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753050AbeBFUaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Feb 2018 15:30:16 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFSoRDMA client fixes for 4.16
Message-ID: <ba9f0f68-2441-8157-e874-1fc88955786c@Netapp.com>
Date: Tue, 6 Feb 2018 15:30:05 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 21ead9ff3dc72604d89499a1da5a18cc193ec4ff:

  SUNRPC: Micro-optimize __rpc_execute (2018-01-23 09:44:40 -0500)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-rdma-for-4.16-2

for you to fetch changes up to e89e8d8fcdc6751e86ccad794b052fe67e6ad619:

  xprtrdma: Fix BUG after a device removal (2018-02-02 13:31:04 -0500)

----------------------------------------------------------------
Stable fixes:
- Fix calculating ri_max_send_sges, which can oops if max_sge is too small
- Fix a BUG after device removal if freed resources haven't been allocated yet

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (2):
      xprtrdma: Fix calculation of ri_max_send_sges
      xprtrdma: Fix BUG after a device removal

 net/sunrpc/xprtrdma/rpc_rdma.c | 2 +-
 net/sunrpc/xprtrdma/verbs.c    | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)
