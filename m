Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:24588 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbbDORAN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 13:00:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 3/3] NFS: Rename idmap.c to nfs4idmap.c
Date: Wed, 15 Apr 2015 13:00:06 -0400
Message-ID: <1429117206-13671-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I added the nfs4 prefix to make it obvious that this file is built into
the NFS v4 module, and not the generic client.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/Makefile                 | 2 +-
 fs/nfs/{idmap.c => nfs4idmap.c} | 0
 2 files changed, 1 insertion(+), 1 deletion(-)
 rename fs/nfs/{idmap.c => nfs4idmap.c} (100%)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 1e987ac..8664417 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -22,7 +22,7 @@ nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
 obj-$(CONFIG_NFS_V4) += nfsv4.o
 CFLAGS_nfs4trace.o += -I$(src)
 nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
-	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
+	  delegation.o nfs4idmap.o callback.o callback_xdr.o callback_proc.o \
 	  nfs4namespace.o nfs4getroot.o nfs4client.o nfs4session.o \
 	  dns_resolve.o nfs4trace.o
 nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
diff --git a/fs/nfs/idmap.c b/fs/nfs/nfs4idmap.c
similarity index 100%
rename from fs/nfs/idmap.c
rename to fs/nfs/nfs4idmap.c
-- 
2.3.5

