From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 9/9] SQUASHME: pnfs: filelayout: mask out server's MDS capability flag for DSs
Date: Wed,  9 Dec 2009 12:28:50 +0200
Message-ID: <1260354530-12578-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When establishing a session with a DS mask out its MDS
exchange_id flag so we know we use it as DS-only.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 128715a..cb8ae88 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -272,6 +272,9 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	if (err)
 		goto out_put;
 
+	/* mask out the server's MDS capability flag */
+	clp->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_DS;
+
 	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
 		printk(KERN_INFO "ip:port %s is not a pNFS Data Server\n",
 			ds->r_addr);
-- 
1.6.5.1

