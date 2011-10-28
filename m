Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:22008 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932196Ab1J1Kvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 06:51:35 -0400
Subject: [PATCH v7 0/7] SUNRPC: make rpcbind clients allocated and destroyed
	dynamically
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Fri, 28 Oct 2011 14:52:09 +0300
Message-ID: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
and rebased on tag "v3.1".

v7:
1) Implemented "goto pattern" in __svc_create().
2) Pathes 5 and 6 from perious patch-set were squashed to make things looks
clearer and to allow safe bisecting of the patch-set.

v6:
1) Fixes in rpcb_clients management.

v4:
1) creation and destruction on rpcbind clients now depends on service program
versions "vs_hidden" flag.

This patch is required for further RPC layer virtualization, because rpcbind
clients have to be per network namespace.
To achive this, we have to untie network namespace from rpcbind clients sockets.
The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
clients will be created during first RPC service creation, and destroyed when
last RPC service is stopped.
With this patch set rpcbind clients can be virtualized easely.

The following series consists of:

---

Stanislav Kinsbursky (7):
      SUNRPC: introduce helpers for reference counted rpcbind clients
      SUNRPC: use rpcbind reference counting helpers
      SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
      SUNRPC: setup rpcbind clients if service requires it
      SUNRPC: cleanup service destruction
      SUNRPC: remove rpcbind clients creation during service registering
      SUNRPC: remove rpcbind clients destruction on module cleanup


 fs/nfsd/nfssvc.c            |    2 +
 include/linux/sunrpc/clnt.h |    2 +
 include/linux/sunrpc/svc.h  |    1 
 net/sunrpc/rpcb_clnt.c      |   88 ++++++++++++++++++++++++++++---------------
 net/sunrpc/sunrpc_syms.c    |    3 -
 net/sunrpc/svc.c            |   57 ++++++++++++++++++++++++----
 6 files changed, 113 insertions(+), 40 deletions(-)

