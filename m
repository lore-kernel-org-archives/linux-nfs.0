Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:54110 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111AbaEFRqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2014 13:46:22 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V2 RFC 0/3] svcrdma: refactor marshalling logic
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Date: Tue, 06 May 2014 12:46:21 -0500
Message-ID: <20140506174621.18208.24242.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series refactors the NFSRDMA server marshalling logic to
remove the intermediary map structures.  It also fixes an existing bug
where the NFSRDMA server was not minding the device fast register page
list length limitations.

I've also made a git repo available with these patches on top of 3.15-rc4:

git://git.openfabrics.org/~swise/linux svcrdma-refactor

Changes since V1:

- fixed regression for devices that don't support FRMRs (see
  rdma_read_chunk_lcl())

- split patch up for closer review.  However I request it be squashed
  before merging as they is not bisectable, and I think these changes
  should all be a single commit anyway.

Please review, and test if you can.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>

---

Tom Tucker (3):
      svcrdma: Sendto changes
      svcrdma: Recvfrom changes
      svcrdma: Transport and header file changes


 include/linux/sunrpc/svc_rdma.h          |    3 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  633 ++++++++++++------------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  230 +----------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   62 ++-
 4 files changed, 318 insertions(+), 610 deletions(-)

-- 

Steve / Tom
