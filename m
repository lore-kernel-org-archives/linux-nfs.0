Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44638 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756340Ab3AOIIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 03:08:48 -0500
Subject: [RFC PATCH 0/4] SUNRPC: rework cache upcall to avoid NFSd root
	swapping
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 15 Jan 2013 11:09:23 +0300
Message-ID: <20130115080402.2996.74320.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main idea of this patch set is to call cache request not on kthread
upcall, but on userspace daemon cache_read call. This fixes the problem with
gaining of wrong dentry path after calling d_path() in kthread root context
(svc_export_request() callback), which always work in init root context, but
containers can work in "root jail" - i.e. have it's own nested root.

The following series implements...

---

Stanislav Kinsbursky (4):
      SUNRPC: introduce cache_detail->cache_request callback
      SUNRPC: remove cache_detail->cache_upcall callback
      SUNRPC: remove "cache_request" argument in sunrpc_cache_pipe_upcall() function
      SUNRPC: move cache_detail->cache_request callback call to cache_read()


 fs/nfs/dns_resolve.c              |    2 +-
 fs/nfsd/export.c                  |   14 ++----------
 fs/nfsd/nfs4idmap.c               |   16 ++-----------
 include/linux/sunrpc/cache.h      |   11 +++------
 net/sunrpc/auth_gss/svcauth_gss.c |    8 +------
 net/sunrpc/cache.c                |   44 ++++++++++++++++++++-----------------
 net/sunrpc/svcauth_unix.c         |   14 ++----------
 7 files changed, 36 insertions(+), 73 deletions(-)

