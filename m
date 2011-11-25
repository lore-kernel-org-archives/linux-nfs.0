Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:3895 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109Ab1KYNOa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Nov 2011 08:14:30 -0500
Subject: [PATCH 0/6] NFS: create DNS resolver cache per network namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 25 Nov 2011 17:12:29 +0300
Message-ID: <20111125130557.6271.95071.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
tag: v3.1

This patch set depends on previous patch sets titled:
1) "SUNRPC: initial part of making pipefs work in net ns"
2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"

Actually, this patch set consists of two tightly connected parts:
1) DNS resolver cache per network namespcae implementation itself
2) DNS resolver cache dentries creation by PipeFS network namespace aware
routines.

Thus this patch set is the second part of "PipeFS per network namespace"
story.

The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: split cache creation and PipeFS registration
      NFS: split cache creation and PipeFS registration
      NFS: handle NFS caches dentries by network namespace aware routines
      NFS: DNS resolver cache per network namespace context introduced
      NFS: DNS resolver PipeFS notifier introduced
      NFS: remove RPC PipeFS mount point references from NFS cache routines


 fs/nfs/cache_lib.c           |   61 ++++++++++++++------
 fs/nfs/cache_lib.h           |   10 +++
 fs/nfs/dns_resolve.c         |  125 ++++++++++++++++++++++++++++++++++--------
 fs/nfs/dns_resolve.h         |   14 ++++-
 fs/nfs/inode.c               |   33 ++++++++++-
 fs/nfs/netns.h               |   13 ++++
 fs/nfs/nfs4namespace.c       |    8 ++-
 include/linux/sunrpc/cache.h |    2 +
 net/sunrpc/cache.c           |   12 ++--
 9 files changed, 218 insertions(+), 60 deletions(-)
 create mode 100644 fs/nfs/netns.h

-- 
Signature
