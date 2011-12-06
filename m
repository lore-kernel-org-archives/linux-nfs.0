Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30891 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933094Ab1LFMp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 07:45:59 -0500
Subject: [PATCH 0/2] SUNRPC: make /proc helpers network-namespace-aware
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 06 Dec 2011 16:42:27 +0300
Message-ID: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is one more precursor patch set. Both patches in the series will be used
later for creating /proc entries for NFS and NFSd statistics per network
namespace context.

The following series consists of:

---

Stanislav Kinsbursky (2):
      SUNRPC: register RPC stats /proc entries in passed network namespace context
      SUNRPC: register service stats /proc entries in passed network namespace context


 fs/nfs/inode.c               |    6 +++---
 fs/nfsd/stats.c              |    5 +++--
 include/linux/sunrpc/stats.h |   16 ++++++++--------
 net/sunrpc/stats.c           |   21 +++++++++++----------
 4 files changed, 25 insertions(+), 23 deletions(-)

