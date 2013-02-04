Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18247 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab3BDLBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 06:01:42 -0500
Subject: [PATCH v2 0/6] SUNRPC: rework cache upcall to avoid NFSd root
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 04 Feb 2013 14:02:29 +0300
Message-ID: <20130204105728.11633.53621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

swapping

The main idea of this patch set is to call cache request not on kthread
upcall, but on userspace daemon cache_read call. This fixes the problem with
gaining of wrong dentry path after calling d_path() in kthread root context
(svc_export_request() callback), which always work in init root context, but
containers can work in "root jail" - i.e. have it's own nested root.

v2:
1) NFS DNS cache update wasn't done in the firest version. So this patch set
does preparation cleanup of the NFS DNS cache routines.
2) Also, this patch set doesn't remove cache_upcall helper anymore, because
it's still required for NFS DNS cache.

The following series implements...

---

Stanislav Kinsbursky (6):
      NFS: use SUNRPC cache creation and destruction helper for DNS cache
      NFS; simlify and clean cache library
      SUNRPC: introduce cache_detail->cache_request callback
      SUNRPC: rework cache upcall logic
      SUNRPC: remove "cache_request" argument in sunrpc_cache_pipe_upcall() function
      SUNRPC: move cache_detail->cache_request callback call to cache_read()


 fs/nfs/cache_lib.c                |   12 ++-----
 fs/nfs/cache_lib.h                |    2 -
 fs/nfs/dns_resolve.c              |   65 +++++++++++++++----------------------
 fs/nfsd/export.c                  |   14 +-------
 fs/nfsd/nfs4idmap.c               |   16 +--------
 include/linux/sunrpc/cache.h      |   10 +++---
 net/sunrpc/auth_gss/svcauth_gss.c |    8 +----
 net/sunrpc/cache.c                |   49 ++++++++++++++++------------
 net/sunrpc/svcauth_unix.c         |   14 +-------
 9 files changed, 69 insertions(+), 121 deletions(-)

