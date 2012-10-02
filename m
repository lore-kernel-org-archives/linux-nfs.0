Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:35811 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310Ab2JBKSo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 06:18:44 -0400
Subject: [PATCH 2/5] nfs: declare nfs_callback_tcp_port in header
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 02 Oct 2012 14:18:59 +0400
Message-ID: <20121002101859.15507.9493.stgit@localhost.localdomain>
In-Reply-To: <20121002101649.15507.50466.stgit@localhost.localdomain>
References: <20121002101649.15507.50466.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse warning:
fs/nfs/super.c:2638:16: sparse: symbol 'nfs_callback_tcpport' was not
declared. Should it be static?

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c07a8d4..4251c2a 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -208,5 +208,6 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
+extern unsigned short nfs_callback_tcpport;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */

