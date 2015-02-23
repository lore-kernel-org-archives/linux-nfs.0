Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx144.netapp.com ([216.240.21.25]:42304 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbbBWWEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2015 17:04:11 -0500
Message-ID: <54EBA3CC.7010403@Netapp.com>
Date: Mon, 23 Feb 2015 17:03:56 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS RDMA client updates
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'm sorry this took a week to send out...

The following changes since commit b625a61698619c7af652de2701a2fb17c5c5d66e:

  xprtrdma: Address sparse complaint in rpcr_to_rdmar() (2015-02-05 15:38:29 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git nfs-rdma-for-4.0-3

for you to fetch changes up to 9b1dcbc8cf4679ecf090b343ac31bda6e55ddabe:

  xprtrdma: Store RDMA credits in unsigned variables (2015-02-23 16:54:04 -0500)

Thanks,
Anna

----------------------------------------------------------------
NFS: RDMA Client Sparse Fix #2

This patch fixes another sparse fix found by Dan Carpenter's tool.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Chuck Lever (1):
      xprtrdma: Store RDMA credits in unsigned variables

 net/sunrpc/xprtrdma/rpc_rdma.c  | 3 ++-
 net/sunrpc/xprtrdma/xprt_rdma.h | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)
