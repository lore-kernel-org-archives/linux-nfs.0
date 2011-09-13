Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7626 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab1IMSNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:13:46 -0400
Subject: [PATCH v3 00/11] SUNRPC: make rpcbind clients allocated and destroyed
	dynamically
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:13:20 +0400
Message-ID: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

v3:
1) rebased to v3.1-rc6 (against branch
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git)
2) creation and destruction on rpcbind clients now depends on service type

This patch is required for further RPC layer virtualization, because rpcbind
clients have to be per network namespace.
To achive this, we have to untie network namespace from rpcbind clients sockets.
The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
clients will be created during first RPC service creation, and destroyed when
last RPC service is stopped.
With this patch set rpcbind clients can be virtualized easely.



The following series consists of:

---

Stanislav Kinsbursky (11):
      SUNRPC: introduce helpers for reference counted rpcbind clients
      SUNRPC: use rpcbind reference counting helpers
      SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
      SUNRPC: parametrize svc creation calls with portmapper flag
      SUNRPC: cleanup service destruction
      Lockd: force creation of rpcbind clients during service creation
      NFS: avoid rpcbind clients creation during service creation
      NFSd: force creation of rpcbind clients during service creation
      NFSd: call svc rpcbind cleanup explicitly
      SUNRPC: remove rpcbind clients creation during service registering
      SUNRPC: remove rpcbind clients destruction on module cleanup


 fs/lockd/svc.c              |    2 +
 fs/nfs/callback.c           |    2 +
 fs/nfsd/nfssvc.c            |    4 ++
 include/linux/sunrpc/clnt.h |    2 +
 include/linux/sunrpc/svc.h  |    3 ++
 net/sunrpc/rpcb_clnt.c      |   85 ++++++++++++++++++++++++++++---------------
 net/sunrpc/sunrpc_syms.c    |    3 --
 net/sunrpc/svc.c            |   41 +++++++++++++++++----
 8 files changed, 98 insertions(+), 44 deletions(-)

-- 
Signature
