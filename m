Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45878 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794Ab2AZLMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:12:15 -0500
Subject: [PATCH 0/5] NFS: various small fixes and updates for conteinerization
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:11:24 +0400
Message-ID: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Build fix and "init_net" replacements.

The following series consists of:

---

Stanislav Kinsbursky (5):
      NFS: pass proper net rpc_pton() in nfs_dns_resolve_name()
      NFS: build fixed in case of NFS_USE_NEW_IDMAPPER is undefined
      NFS: search for client session id in proper network namespace
      NFS: pass current net to rpc_pton() while parsing mount options
      NFS: pass transport net to rpc_pton() while parse server name


 fs/nfs/callback.h      |    1 +
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    1 +
 fs/nfs/client.c        |    4 ++--
 fs/nfs/dns_resolve.c   |    2 +-
 fs/nfs/idmap.c         |    1 +
 fs/nfs/internal.h      |    3 ++-
 fs/nfs/nfs4namespace.c |    6 +++---
 fs/nfs/super.c         |    4 ++--
 9 files changed, 14 insertions(+), 10 deletions(-)

