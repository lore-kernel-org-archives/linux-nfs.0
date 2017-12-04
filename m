Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34983 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdLDTNY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:13:24 -0500
Subject: [PATCH v1 0/4] Use same proto= after traversing a referral
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 Dec 2017 14:13:22 -0500
Message-ID: <20171204190904.18629.70341.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Today when the Linux client traverses an NFSv4 referral, it always
chooses proto=tcp on the submount. This means following a referral
on an NFS/RDMA mount will always make the submounts use TCP, which
is not desirable. These patches make the client try NFS/RDMA first
when traversing a referral so that submounts will continue to use
NFS/RDMA.

Please consider this series for v4.16.

---

Chuck Lever (4):
      nfs: Define NFS_RDMA_PORT
      nfs: Referrals should use the same proto setting as their parent
      nfs: Update server port after referral or migration
      SUNRPC: Remove rpc_protocol()


 fs/nfs/nfs4client.c         |   24 +++++++++++++++++++++---
 fs/nfs/nfs4namespace.c      |    2 --
 include/linux/sunrpc/clnt.h |    1 -
 include/uapi/linux/nfs.h    |    1 +
 net/sunrpc/clnt.c           |   16 ----------------
 5 files changed, 22 insertions(+), 22 deletions(-)

--
Chuck Lever
