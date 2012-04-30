Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab2D3SAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:00:43 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/3] NFS: Ensure that we break out of read/write_schedule_segment on error
Date: Mon, 30 Apr 2012 14:00:39 -0400
Message-Id: <1335808841-11623-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we do break out of the for() loop, but we also need to
break out of the enclosing do {} while()...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d44de2f..5ce5c6b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -396,7 +396,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 			pos += req_len;
 			count -= req_len;
 		}
-	} while (count != 0);
+	} while (count != 0 && result >= 0);
 
 	kfree(pagevec);
 
@@ -689,6 +689,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 				nfs_release_request(req);
 				nfs_direct_release_pages(pagevec + i,
 							 npages - i);
+				break;
 			}
 			pgbase = 0;
 			bytes -= req_len;
@@ -697,7 +698,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			pos += req_len;
 			count -= req_len;
 		}
-	} while (count != 0);
+	} while (count != 0 && result >= 0);
 
 	kfree(pagevec);
 
-- 
1.7.7.6

