From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH] nfs: clear_commit_release incorrectly handle truncated page
Date: Tue, 02 Feb 2010 13:36:02 +0300
Message-ID: <87hbpzhqlp.fsf@openvz.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: linux-nfs@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=


After page was truncated it lost it's mapping, this result in null
pointer dereference on bdi_stat update. In fact we have to decrement
bdi_stat even for truncated pages, so let's pass correct mapping in
function arguments. Patch against linux-2.6
##TEST_CASE
/*
Tast case for bug in nfs_clear_request_commit()
caused by null pointer dereference in case of truncated page.
It takes less than 10 minutes to reproduce the bug.
### start script
#! /bin/bash -x
# mount my-host:/my-share /mnt
mkdir /mnt/T
cd /mnt/T || exit 1
while true ;
      do for ((i=0;i<3;i++)); do
      	 /tmp/mmap file3 200000000 $i & done;
	 sleep 2 ;
	 killall -9 mmap ;
      done
done
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
int main(int argc, char *argv[])
{
	char *addr;
	unsigned int size;
	off_t off;
	int i = 0;
	int fd, result;
	if (argc != 4) {
		perror("Wrong args:\n Usage: %s [file] [size] [offset]\n");
		exit(EXIT_FAILURE);
	}
	size = atoi(argv[2]);
	size &= ~(4096-1);
	off = atol(argv[3]);
	off = ((off_t)size)*off;
	fd = open(argv[1], O_RDWR | O_CREAT | O_TRUNC, (mode_t)0600);
	if (fd == -1) {
		perror("Error opening file for writing");
		exit(EXIT_FAILURE);
	}
	result = lseek(fd, off + (off_t)size, SEEK_SET);
	if (result == -1) {
		close(fd);
		perror("Error calling lseek() to 'stretch' the file");
		exit(EXIT_FAILURE);
	}
	write(fd, "a", 1);
	addr = mmap(0, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, off);
	if (addr == MAP_FAILED) {
		close(fd);
		perror("Error mmapping the file");
		exit(EXIT_FAILURE);
	}
	/* Now write int's to the file as if it were memory (an array of ints).
	 */
	while (1) {
		memset(addr, i++, size);
	}
}


--=-=-=
Content-Disposition: inline;
 filename=0001-nfs-clear_commit_release-incorrectly-handle-truncate.patch

>From bdce13e6947ad738b68bcb9fd507885d14dca9f0 Mon Sep 17 00:00:00 2001
From: Dmitry Monakhov <dmonakhov@openvz.org>
Date: Tue, 2 Feb 2010 13:24:58 +0300
Subject: [PATCH] nfs: clear_commit_release incorrectly handle truncated page

After page was truncated it lost it's mapping, this result in null
pointer dereference on bdi_stat update. In fact we have to decrement
bdi_stat even for truncated pages, so let's pass correct mapping in
function arguments.

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 fs/nfs/write.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..bfcf92a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -445,13 +445,13 @@ nfs_mark_request_commit(struct nfs_page *req)
 }
 
 static int
-nfs_clear_request_commit(struct nfs_page *req)
+nfs_clear_request_commit(struct nfs_page *req, struct address_space *mapping)
 {
 	struct page *page = req->wb_page;
-
+	/* page->mapping may be NULL if page was truncated */
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
 	}
 	return 0;
@@ -483,7 +483,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 }
 
 static inline int
-nfs_clear_request_commit(struct nfs_page *req)
+nfs_clear_request_commit(struct nfs_page *req, struct address_space *mapping)
 {
 	return 0;
 }
@@ -539,14 +539,15 @@ static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, u
 	return res;
 }
 
-static void nfs_cancel_commit_list(struct list_head *head)
+static void nfs_cancel_commit_list(struct list_head *head,
+				struct address_space *mapping)
 {
 	struct nfs_page *req;
 
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
+		nfs_clear_request_commit(req, mapping);
 		nfs_inode_remove_request(req);
 		nfs_unlock_request(req);
 	}
@@ -642,7 +643,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		spin_lock(&inode->i_lock);
 	}
 
-	if (nfs_clear_request_commit(req))
+	if (nfs_clear_request_commit(req, inode->i_mapping))
 		radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
 				req->wb_index, NFS_PAGE_TAG_COMMIT);
 
@@ -1352,7 +1353,7 @@ static void nfs_commit_release(void *calldata)
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
+		nfs_clear_request_commit(req, data->inode->i_mapping);
 
 		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
@@ -1449,7 +1450,7 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 			break;
 		if (how & FLUSH_INVALIDATE) {
 			spin_unlock(&inode->i_lock);
-			nfs_cancel_commit_list(&head);
+			nfs_cancel_commit_list(&head, mapping);
 			ret = pages;
 			spin_lock(&inode->i_lock);
 			continue;
-- 
1.6.3.3


--=-=-=--
