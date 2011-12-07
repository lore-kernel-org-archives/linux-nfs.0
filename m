Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:47373 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825Ab1LGLUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 06:20:43 -0500
Subject: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 07 Dec 2011 15:20:07 +0300
Message-ID: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is another precursor patch set aimed to remove hard-coded "init_net"
reference from SUNRPC sockaddr convertion and construction routines.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: use passed network namespace context in rpc_parse_scope_id()
      SUNRPC: use passed network namespace context in rpc_pton6()
      SUNRPC: use passed network namespace context in rpc_pton()
      SUNRPC: use passed network namespace context in rpc_uaddr2sockaddr()


 fs/nfs/dns_resolve.c        |    4 ++--
 fs/nfs/nfs4filelayoutdev.c  |    2 +-
 fs/nfs/nfs4namespace.c      |    2 +-
 fs/nfs/super.c              |    4 ++--
 fs/nfsd/nfs4state.c         |    2 +-
 fs/nfsd/nfsctl.c            |    2 +-
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/addr.c           |   24 +++++++++++++-----------
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svcauth_unix.c   |    2 +-
 10 files changed, 25 insertions(+), 23 deletions(-)

-- 
Signature
