Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:53348 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757556Ab1ANNtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 08:49:40 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Landley <rlandley@parallels.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v3 11/16] Export iterate_mounts symbol to be able to use from sunrpc module.
Date: Fri, 14 Jan 2011 15:49:09 +0200
Message-Id: <1295012954-7769-12-git-send-email-kas@openvz.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas@openvz.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 fs/namespace.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 3ddfd90..f73054d 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1498,6 +1498,7 @@ int iterate_mounts(int (*f)(struct vfsmount *, void *), void *arg,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(iterate_mounts);
 
 static void cleanup_group_ids(struct vfsmount *mnt, struct vfsmount *end)
 {
-- 
1.7.3.4

