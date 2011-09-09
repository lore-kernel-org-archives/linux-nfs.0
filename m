Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14760 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933914Ab1IIMJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:09:17 -0400
Subject: [PATCH v2 0/5] SUNRPC: make rpcbind clients allocated and destroyed
	dynamically
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Fri, 09 Sep 2011 16:08:20 +0400
Message-ID: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

v2:
1) rebased to v3.1-rc4 (against branch
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git)
2) Patch 3/5 (SUNRPC: make RPC service dependable on rpcbind clients creation)
fixed: added rpcb_put_local() call in case of svc_serv creation failure.

This patch is required for further RPC layer virtualization, because rpcbind
clients have to be per network namespace.
To achive this, we have to untie network namespace from rpcbind clients sockets.
The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
clients will be created during first RPC service creation, and destroyed when
last RPC service is stopped.
With this patch set rpcbind clients can be virtualized easely.

The following series consists of:

---

Stanislav Kinsbursky (5):
      SUNRPC: introduce helpers for reference counted rpcbind clients
      SUNRPC: use rpcbind reference counting helpers
      SUNRPC: make RPC service dependable on rpcbind clients creation
      SUNRPC: remove rpcbind clients creation during service registering
      SUNRPC: remove rpcbind clients destruction on module cleanup


 include/linux/sunrpc/clnt.h |    2 +
 net/sunrpc/rpcb_clnt.c      |   86 ++++++++++++++++++++++++++++---------------
 net/sunrpc/sunrpc_syms.c    |    3 --
 net/sunrpc/svc.c            |   13 ++++++-
 4 files changed, 69 insertions(+), 35 deletions(-)

-- 
Signature
