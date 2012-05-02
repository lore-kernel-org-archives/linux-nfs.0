Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4325 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385Ab2EBMKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 08:10:08 -0400
Subject: [PATCH v3 0/2] SUNRPC: separate per-net data creation from service
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 02 May 2012 16:08:29 +0400
Message-ID: <20120502120536.8794.22210.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

creation

v3: "SUNRPC: new svc_bind() routine introduced" patch was squashed with the
    "SUNRPC: check rpcbind clients usage counter before decrement" patch.

v2: Increase per-net usage counted in lockd_up_net().

This is a cleanup patch set.
It will be followed my LockD start/stop cleanup patch set and NFS callback
service containerization patch set (yes, I forgot to implement it).

Today per-net data is created with service, and then is service is starting in
other network namespace. And thus it's destroyed with service too. Moreover,
network context for destroying of per-net data is taken from current process.
This is correct, but code looks ugly.
This patch set separates per-net data allocation from service allocation and
destruction.
IOW, per-net data have to be destroyed by service users - not service itself.

BTW, NFSd code become uglier with this patch set. Sorry.
But I assume, that these new ugly parts will be replaced later by NFSd service
containerization code.

The following series implements...

---

Stanislav Kinsbursky (2):
      SUNRPC: new svc_bind() routine introduced
      SUNRPC: move per-net operations from svc_destroy()


 fs/lockd/svc.c             |   33 +++++++++++++++++++++------------
 fs/nfs/callback.c          |   11 +++++++++++
 fs/nfsd/nfsctl.c           |    4 ++++
 fs/nfsd/nfssvc.c           |   16 ++++++++++++++++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/rpcb_clnt.c     |   12 +++++++-----
 net/sunrpc/svc.c           |   23 ++++++++++-------------
 7 files changed, 70 insertions(+), 30 deletions(-)

