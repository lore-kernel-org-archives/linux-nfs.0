From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH 0/4] NFS/RDMA Connectathon fixes
Date: Thu, 05 Mar 2009 16:17:41 -0500
Message-ID: <20090305210738.6517.67862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:52694
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750902AbZCEVXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:23:43 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch series are the fixes from Connectathon. With
the first two, we achieved full interop between Linux and OpenSolaris,
over Infiniband, in both directions. (Linux-to-Linux was also tested
successfully with both Infiniband and iWARP.)

The first patch merely removes a bogus assertion in the server rdma
chunk manipulation. This was triggered by the slightly different way
that the OpenSolaris client marshals certain requests.

The second patch fixes a defect in the client chunk marshaling, which
caused a bad XDR encode in (only) NFSv4 symlink requests.

The third and fourth patches are a usability improvement, to dynamically
load the xprtrdma client module on-demand when mounting nfs over rdma.

I'm hoping they'll all be acceptable for the 2.6.30 merge window.

Comments are welcome, etc.

---

Tom Talpey (4):
      NFS: load the rpc/rdma transport module automatically
      SUNRPC: dynamically load RPC transport modules on-demand
      XPRTRDMA: correct an rpc/rdma inline send marshaling error
      SVCRDMA: remove faulty assertions in rpc/rdma chunk validation.


 fs/nfs/super.c                        |    4 +++-
 include/linux/sunrpc/xprt.h           |    1 +
 net/sunrpc/xprt.c                     |   31 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c        |   26 ++++++++++++++------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    8 +++++---
 5 files changed, 54 insertions(+), 16 deletions(-)

-- 

Tom.
