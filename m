Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:45222 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdLURmu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 12:42:50 -0500
Subject: [PATCH v1 0/3] NFS/RDMA server changes for v4.16
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 21 Dec 2017 12:42:48 -0500
Message-ID: <20171221174206.11802.16286.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Would you consider these patches for merging into v4.16?

---

Chuck Lever (3):
      svcrdma: Post Receives in the Receive completion handler
      NFSD: Clean up write argument XDR decoders
      NFSD: Clean up symlink argument XDR decoders


 fs/nfsd/nfs3proc.c                         |   18 ++++-
 fs/nfsd/nfs3xdr.c                          |   67 ++++-------------
 fs/nfsd/nfs4proc.c                         |   37 +++-------
 fs/nfsd/nfs4xdr.c                          |   11 ++-
 fs/nfsd/nfsproc.c                          |   23 ++++--
 fs/nfsd/nfsxdr.c                           |   63 ++++++++--------
 fs/nfsd/xdr.h                              |    3 +
 fs/nfsd/xdr3.h                             |    3 +
 fs/nfsd/xdr4.h                             |    3 +
 include/linux/sunrpc/svc.h                 |    4 +
 include/linux/sunrpc/svc_rdma.h            |    2 -
 net/sunrpc/svc.c                           |  109 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    4 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   15 +---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    6 --
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   25 ++----
 16 files changed, 228 insertions(+), 165 deletions(-)

--
Chuck Lever
