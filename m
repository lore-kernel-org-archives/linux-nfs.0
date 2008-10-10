From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 0/2] RPC/RDMA patchset addendum
Date: Fri, 10 Oct 2008 11:32:24 -0400
Message-ID: <20081010152634.3983.91559.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:47533 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758191AbYJJPcZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2008 11:32:25 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m9AFWOKH004027
	for <linux-nfs@vger.kernel.org>; Fri, 10 Oct 2008 11:32:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, the following two patches implement the reestablish_timeout
backoff for rpc/rdma connection attempts. per your comment. This
way is certainly cleaner! The new patch has two functional components
so it is split.

These should go in with the prior set, as they fix existing issues
in the 2.6.25->2.6.27 codeline.

---

Tom Talpey (2):
      RPC/RDMA: ensure connection attempt is complete before signalling.
      RPC/RDMA: correct the reconnect timer backoff


 net/sunrpc/xprtrdma/transport.c |    7 +++++++
 net/sunrpc/xprtrdma/verbs.c     |    6 +-----
 2 files changed, 8 insertions(+), 5 deletions(-)

-- 

Tom.
