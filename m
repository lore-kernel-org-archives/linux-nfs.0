Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:54877 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751580AbdKGQxT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 11:53:19 -0500
To: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH RFC v1] nfs/write: Use common error handling code in
 nfs_lock_and_join_requests()
Message-ID: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
Date: Tue, 7 Nov 2017 17:53:10 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 7 Nov 2017 08:51:00 +0100

Add a jump target so that a bit of exception handling can be better reused
at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---

v1 - Request for comments:
I can offer another bit of information for a software development discussion. 💭

The affected source file can be compiled for the processor architecture “x86_64”
by a tool like “GCC 6.4.1+r251631-1.3” from the software distribution
“openSUSE Tumbleweed” with the following command example.

my_cc=/usr/bin/gcc-6 \
&& my_module=fs/nfs/write.o \
&& for XYZ in 0 s 3; do echo "   _____ $XYZ _____" \
&& my_extra="-O$XYZ" \
&& git checkout next-20171102 \
&& make -j4 CC="${my_cc}" HOSTCC="${my_cc}" EXTRA_CFLAGS="${my_extra}" allmodconfig "${my_module}" \
&& size "${my_module}" \
&& git checkout ':/^nfs/write: Use common error handling code in nfs_lock_and_join_requests' \
&& make -j4 CC="${my_cc}" HOSTCC="${my_cc}" EXTRA_CFLAGS="${my_extra}" allmodconfig "${my_module}" \
&& size "${my_module}"; done


🔮 Do you find the following differences worth for further clarification?

╔═════════╤══════╗
║ setting │ text ║
╠═════════╪══════╣
║   O0    │ ???  ║   Compilation failure?
║   Os    │ -17  ║
║   O3    │ -16  ║
╚═════════╧══════╝


 fs/nfs/write.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index babebbccae2a..5b5f464f6f2a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -487,10 +487,8 @@ nfs_lock_and_join_requests(struct page *page)
 	}
 
 	ret = nfs_page_group_lock(head);
-	if (ret < 0) {
-		nfs_unlock_and_release_request(head);
-		return ERR_PTR(ret);
-	}
+	if (ret < 0)
+		goto release_request;
 
 	/* lock each request in the page group */
 	total_bytes = head->wb_bytes;
@@ -515,8 +513,7 @@ nfs_lock_and_join_requests(struct page *page)
 			if (ret < 0) {
 				nfs_unroll_locks(inode, head, subreq);
 				nfs_release_request(subreq);
-				nfs_unlock_and_release_request(head);
-				return ERR_PTR(ret);
+				goto release_request;
 			}
 		}
 		/*
@@ -532,8 +529,8 @@ nfs_lock_and_join_requests(struct page *page)
 			nfs_page_group_unlock(head);
 			nfs_unroll_locks(inode, head, subreq);
 			nfs_unlock_and_release_request(subreq);
-			nfs_unlock_and_release_request(head);
-			return ERR_PTR(-EIO);
+			ret = -EIO;
+			goto release_request;
 		}
 	}
 
@@ -576,6 +573,10 @@ nfs_lock_and_join_requests(struct page *page)
 	/* still holds ref on head from nfs_page_find_head_request
 	 * and still has lock on head from lock loop */
 	return head;
+
+release_request:
+	nfs_unlock_and_release_request(head);
+	return ERR_PTR(ret);
 }
 
 static void nfs_write_error_remove_page(struct nfs_page *req)
-- 
2.15.0

