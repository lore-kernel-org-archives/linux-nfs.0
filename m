Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:35868 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab2AZLMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:12:01 -0500
Subject: [PATCH 2/5] NFS: build fixed in case of NFS_USE_NEW_IDMAPPER is
 undefined
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:11:41 +0400
Message-ID: <20120126111141.8386.95788.stgit@localhost6.localdomain6>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/idmap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index aed3d2e..04f58d4 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -378,6 +378,7 @@ int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf,
 
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "netns.h"
 
 #define IDMAP_HASH_SZ          128
 

