Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37805 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310Ab2JBKSu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 06:18:50 -0400
Subject: [PATCH 3/5] nfs: declare nfs_xdev_mount as static
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 02 Oct 2012 14:19:04 +0400
Message-ID: <20121002101904.15507.60636.stgit@localhost.localdomain>
In-Reply-To: <20121002101649.15507.50466.stgit@localhost.localdomain>
References: <20121002101649.15507.50466.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse warning:
fs/nfs/super.c:2517:15: warning: symbol 'nfs_xdev_mount' was not declared.
Should it be static?

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a719bc0..b4079bb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2514,7 +2514,7 @@ EXPORT_SYMBOL_GPL(nfs_kill_super);
 /*
  * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
  */
-struct dentry *
+static struct dentry *
 nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 		const char *dev_name, void *raw_data)
 {

