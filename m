Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26221 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756922Ab2AMJJU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 04:09:20 -0500
Subject: [PATCH v2 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 13:08:54 +0400
Message-ID: <20120113090520.1598.73772.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
head: devel

v2:
1) Rebased on up-to-date state ("devel" head).
2) patches change logs updated

This is another precursor patch set aimed to remove hard-coded "init_net"
reference from SUNRPC sockaddr convertion and construction routines.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: parametrize rpc_parse_scope_id() by network context
      SUNRPC: parametrize rpc_pton6() by network context
      SUNRPC: parametrize rpc_pton() by network context
      SUNRPC: parametrize rpc_uaddr2sockaddr() by network context


 fs/nfs/dns_resolve.c        |    4 ++--
 fs/nfs/nfs4filelayoutdev.c  |    2 +-
 fs/nfs/nfs4namespace.c      |    2 +-
 fs/nfs/super.c              |    4 ++--
 fs/nfsd/nfs4state.c         |    2 +-
 fs/nfsd/nfsctl.c            |    2 +-
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/addr.c           |   26 +++++++++++++++-----------
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svcauth_unix.c   |    2 +-
 10 files changed, 27 insertions(+), 23 deletions(-)

-- 
Signature
