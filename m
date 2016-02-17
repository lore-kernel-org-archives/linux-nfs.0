Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:50715 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965230AbcBQWMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 17:12:32 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull an NFSoRDMA Client Bugfix
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <56C4F049.5020005@Netapp.com>
Date: Wed, 17 Feb 2016 17:12:25 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 26ae9d1c5af1b1d669ca1c28fc02bbca3d778d45:

  xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit'). (2015-12-18 15:34:33 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.5-1

for you to fetch changes up to 9f74660bcf1e4cca577be99e54bc77b5df62b508:

  xprtrdma: rpcrdma_bc_receive_call() should init rq_private_buf.len (2016-02-17 10:23:52 -0500)

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (1):
      xprtrdma: rpcrdma_bc_receive_call() should init rq_private_buf.len

 net/sunrpc/xprtrdma/backchannel.c | 2 ++
 1 file changed, 2 insertions(+)
