From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/12] NFS: Clean up nfs_sync_mapping
Date: Mon, 25 Jan 2010 17:15:46 -0500
Message-ID: <20100125221545.16750.26844.stgit@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar@nec-labs.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100125221544.16750.70574.stgit@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the redundant call to filemap_write_and_wait().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8341709..a867c4c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -114,16 +114,12 @@ void nfs_clear_inode(struct inode *inode)
  */
 int nfs_sync_mapping(struct address_space *mapping)
 {
-	int ret;
+	int ret = 0;
 
-	if (mapping->nrpages == 0)
-		return 0;
-	unmap_mapping_range(mapping, 0, 0, 0);
-	ret = filemap_write_and_wait(mapping);
-	if (ret != 0)
-		goto out;
-	ret = nfs_wb_all(mapping->host);
-out:
+	if (mapping->nrpages != 0) {
+		unmap_mapping_range(mapping, 0, 0, 0);
+		ret = nfs_wb_all(mapping->host);
+	}
 	return ret;
 }
 

