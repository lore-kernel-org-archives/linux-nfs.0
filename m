Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507Ab2D3SAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:00:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/3] NFS: Simplify O_DIRECT page referencing
Date: Mon, 30 Apr 2012 14:00:41 -0400
Message-Id: <1335808841-11623-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335808841-11623-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1335808841-11623-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335808841-11623-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The O_DIRECT code shouldn't need to hold 2 references to each page. The
reference held by the struct nfs_page should suffice.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 450ba54..31d0624 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -268,10 +268,9 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 			}
 			bytes += req->wb_bytes;
 			nfs_list_remove_request(req);
-			nfs_direct_readpage_release(req);
 			if (!PageCompound(page))
 				set_page_dirty(page);
-			page_cache_release(page);
+			nfs_direct_readpage_release(req);
 		}
 	} else {
 		while (!list_empty(&hdr->pages)) {
@@ -281,7 +280,6 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 				if (!PageCompound(req->wb_page))
 					set_page_dirty(req->wb_page);
 			bytes += req->wb_bytes;
-			page_cache_release(req->wb_page);
 			nfs_list_remove_request(req);
 			nfs_direct_readpage_release(req);
 		}
@@ -375,8 +373,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 						 pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
-				nfs_direct_release_pages(pagevec + i,
-							 npages - i);
 				result = PTR_ERR(req);
 				break;
 			}
@@ -385,8 +381,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 			if (!nfs_pageio_add_request(desc, req)) {
 				result = desc->pg_error;
 				nfs_release_request(req);
-				nfs_direct_release_pages(pagevec + i,
-							 npages - i);
 				break;
 			}
 			pgbase = 0;
@@ -396,6 +390,8 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 			pos += req_len;
 			count -= req_len;
 		}
+		/* The nfs_page now hold references to these pages */
+		nfs_direct_release_pages(pagevec, npages);
 	} while (count != 0 && result >= 0);
 
 	kfree(pagevec);
@@ -509,7 +505,6 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	nfs_pageio_complete(&desc);
 
 	while (!list_empty(&failed)) {
-		page_cache_release(req->wb_page);
 		nfs_release_request(req);
 		nfs_unlock_request(req);
 	}
@@ -542,10 +537,8 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
 			/* Note the rewrite will go through mds */
 			nfs_mark_request_commit(req, NULL, &cinfo);
-		} else {
-			page_cache_release(req->wb_page);
+		} else
 			nfs_release_request(req);
-		}
 		nfs_unlock_request(req);
 	}
 
@@ -675,8 +668,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 						 pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
-				nfs_direct_release_pages(pagevec + i,
-							 npages - i);
 				result = PTR_ERR(req);
 				break;
 			}
@@ -687,8 +678,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 				result = desc->pg_error;
 				nfs_unlock_request(req);
 				nfs_release_request(req);
-				nfs_direct_release_pages(pagevec + i,
-							 npages - i);
 				break;
 			}
 			pgbase = 0;
@@ -698,6 +687,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			pos += req_len;
 			count -= req_len;
 		}
+		/* The nfs_page now hold references to these pages */
+		nfs_direct_release_pages(pagevec, npages);
 	} while (count != 0 && result >= 0);
 
 	kfree(pagevec);
@@ -760,7 +751,6 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
 			break;
 		default:
-			page_cache_release(req->wb_page);
 			nfs_release_request(req);
 		}
 		nfs_unlock_request(req);
-- 
1.7.7.6

