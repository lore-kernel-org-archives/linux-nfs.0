Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55421 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750773AbdHRHNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:13:53 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:51 +1000
Subject: [PATCH 3/8] NFS: don't expect errors from mempool_alloc().
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037191.30218.12891416109766472128.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fbe77c30e9ab ("NFS: move rw_mode to nfs_pageio_header")
reintroduced some pointless code that commit 518662e0fcb9 ("NFS: fix
usage of mempools.") had recently removed.

Remove it again.

Cc: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/write.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b1af5dee5e0a..e833179d0d49 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -102,10 +102,8 @@ static struct nfs_pgio_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_pgio_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
-	if (p) {
-		memset(p, 0, sizeof(*p));
-		p->rw_mode = FMODE_WRITE;
-	}
+	memset(p, 0, sizeof(*p));
+	p->rw_mode = FMODE_WRITE;
 	return p;
 }
 


