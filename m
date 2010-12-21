Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab0LUXth (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Dec 2010 18:49:37 -0500
Date: Tue, 21 Dec 2010 18:49:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfs: fix mispelling of idmap CONFIG symbol
Message-ID: <20101221234934.GB30525@fieldses.org>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
 <20101220144644.GC20643@fieldses.org>
 <20101221233215.GC7092@shutemov.name>
 <1292975008.16674.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292975008.16674.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Trivial, but confusing when you're trying to grep through this
code....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/idmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 4e2d9b6..1869688 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -238,7 +238,7 @@ int nfs_map_gid_to_group(struct nfs_client *clp, __u32 gid, char *buf, size_t bu
 	return nfs_idmap_lookup_name(gid, "group", buf, buflen);
 }
 
-#else  /* CONFIG_NFS_USE_IDMAPPER not defined */
+#else  /* CONFIG_NFS_USE_NEW_IDMAPPER not defined */
 
 #include <linux/module.h>
 #include <linux/mutex.h>
-- 
1.7.1

