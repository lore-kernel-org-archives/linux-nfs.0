Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29746 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753757Ab1HXSe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 14:34:29 -0400
Subject: [PATCH 0/5] SUNRPC: make rpcbind clients allocated and destroyed on
	dynamically
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Wed, 24 Aug 2011 22:33:36 +0400
Message-ID: <20110824183304.4924.94670.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
      SUNRPC: use reference count helpers
      SUNRPC: make RPC service dependable on rpcbind clients creation
      SUNRPC: remove rpcbind clients creation during service registring
      SUNRPC: remove rpcbind clients destruction on module cleanup


 include/linux/sunrpc/clnt.h |    2 +
 net/sunrpc/rpcb_clnt.c      |   86 ++++++++++++++++++++++++++++---------------
 net/sunrpc/sunrpc_syms.c    |    3 --
 net/sunrpc/svc.c            |    5 +++
 4 files changed, 63 insertions(+), 33 deletions(-)

-- 
Signature
