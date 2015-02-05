Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:12375 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbbBEUqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 15:46:09 -0500
Message-ID: <54D3D68E.3000303@Netapp.com>
Date: Thu, 5 Feb 2015 15:46:06 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [GIT PULL] Please pull an NFSoRDMA fix
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit a0a1d50cd1e80652142af5cddcde500d06c71bdd:

  xprtrdma: Update the GFP flags used in xprt_rdma_allocate() (2015-01-30 12:18:48 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-3.20-part-2

for you to fetch changes up to b625a61698619c7af652de2701a2fb17c5c5d66e:

  xprtrdma: Address sparse complaint in rpcr_to_rdmar() (2015-02-05 15:38:29 -0500)

Thanks,
Anna

----------------------------------------------------------------
NFS: RDMA Client Sparse Fixes

This patch fixes a sparse warning in the initial submission.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Chuck Lever (1):
      xprtrdma: Address sparse complaint in rpcr_to_rdmar()

 net/sunrpc/xprtrdma/xprt_rdma.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)
