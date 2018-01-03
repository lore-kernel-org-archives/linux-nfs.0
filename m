Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36925 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbeACUmM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:42:12 -0500
Subject: [PATCH v2 0/3] NFS/RDMA server changes for v4.16
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:42:10 -0500
Message-ID: <20180103203849.7074.9609.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Would you consider these patches for merging into v4.16?

Changes since v1:
- Rebased on v4.15-rc6
- Address a 0day robot complaint in nfsd3_proc_symlink
- Properly handle error return from svc_rdma_handle_bc_reply

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
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    5 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    9 --
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    6 --
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   25 ++----
 16 files changed, 225 insertions(+), 163 deletions(-)

--
Chuck Lever
