Return-Path: <bfields@fieldses.org>
Date: Tue, 16 Jan 2018 10:08:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
	Benjamin Coddington <bcodding@redhat.com>
Subject: [PATCH] NFS: commit direct writes even if they fail partially
Message-ID: <20180116150800.GA21173@fieldses.org>
References: <20171208221626.GB22508@fieldses.org>
 <20171213171815.GB9205@fieldses.org>
 <9383ABA6-B994-4DB3-95F4-C0D6F59580F9@redhat.com>
 <20171214163654.GD9205@fieldses.org>
 <20171214185514.GE9205@fieldses.org>
 <20171219165622.GC19967@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171219165622.GC19967@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If some of the WRITE calls making up an O_DIRECT write syscall fail,
we neglect to commit, even if some of the WRITEs succeed.

We also depend on the commit code to free the reference count on the
nfs_page taken in the "if (request_commit)" case at the end of
nfs_direct_write_completion().  The problem was originally noticed
because ENOSPC's encountered partway through a write would result in a
closed file being sillyrenamed when it should have been unlinked.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/direct.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d2972d537469..8c10b0562e75 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -775,10 +775,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 
 	spin_lock(&dreq->lock);
 
-	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
-		dreq->flags = 0;
+	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags))
 		dreq->error = hdr->error;
-	}
 	if (dreq->error == 0) {
 		nfs_direct_good_bytes(dreq, hdr);
 		if (nfs_write_need_commit(hdr)) {
-- 
2.14.3
