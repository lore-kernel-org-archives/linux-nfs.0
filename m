Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33854 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbcCASFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 13:05:21 -0500
Subject: [PATCH v5 00/14] NFS/RDMA server patches for v4.6
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 Mar 2016 13:05:14 -0500
Message-ID: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I think these are ready for linux-next.

Two major changes: Finish server-side support for RDMA_ERROR type
messages, and convert the server's completion handlers to the new
core CQ API.

Also available in the "nfsd-rdma-for-4.6" topic branch of this git
repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.6


Changes since v4:
- Rebased on v4.5-rc6
- Replace confusing comments about NFSv4.1 over RDMA support


Changes since v3:
- Rebased on v4.5-rc5
- Completed fix for Write chunk XDR padding
- On error, svc_rdma_sendto() should close connection


Changes since v2:
- Rebased on v4.5-rc4
- checkpatch.pl passes
- Fix iWARP RDMA Read path regression
- Reduce NFSv4.1 CB message size maximum in CREATE_SESSION
- Another pass at fixing Write chunk XDR padding
- Various clean ups


Changes since v1:
- Rebased on v4.5-rc3
- Patch 02/10 (pre-allocate frmrs) dropped
- Patch 04/10 replaced with more surgical patch
- Refined reporting of flushed completions
- Function names of completion methods changed to match client's
new completion function naming convention

---

Chuck Lever (14):
      nfsd: Update NFS server comments related to RDMA support
      svcrdma: Find client-provided write and reply chunks once per reply
      svcrdma: Do not write xdr_buf::tail in a Write chunk
      svcrdma: Do not send Write chunk XDR pad with inline content
      nfsd: Lower NFSv4.1 callback message size limit
      svcrdma: Close connection when a send error occurs
      svcrdma: svc_rdma_post_recv() should close connection on error
      rpcrdma: Add RPCRDMA_HDRLEN_ERR
      svcrdma: Make RDMA_ERROR messages work
      svcrdma: Use correct XID in error replies
      svcrdma: Hook up the logic to return ERR_CHUNK
      svcrdma: Remove close_out exit path
      svcrdma: Use new CQ API for RPC-over-RDMA server receive CQs
      svcrdma: Use new CQ API for RPC-over-RDMA server send CQs


 fs/nfsd/nfs4state.c                        |   26 +-
 fs/nfsd/nfs4xdr.c                          |    2 
 include/linux/sunrpc/auth.h                |    7 
 include/linux/sunrpc/rpc_rdma.h            |    1 
 include/linux/sunrpc/svc_rdma.h            |   20 +
 net/sunrpc/auth_null.c                     |    4 
 net/sunrpc/auth_unix.c                     |    6 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   64 +++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   60 ++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  196 ++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  445 +++++++++-------------------
 12 files changed, 393 insertions(+), 455 deletions(-)

--
Chuck Lever
