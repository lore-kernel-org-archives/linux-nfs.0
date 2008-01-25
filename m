From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 090/112] NFS: nfs_write_end clean up
Date: Fri, 25 Jan 2008 11:37:56 -0500
Message-ID: <20080125163755.31887.57603.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14350 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092AbYAYQ7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:54 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlnv019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:53 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: commit 4899f9c8 added nfs_write_end(), which introduces a
conditional expression that returns an unsigned integer in one arm and
a signed integer in the other.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4560fc2..ef57a5a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -349,7 +349,9 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	unlock_page(page);
 	page_cache_release(page);
 
-	return status < 0 ? status : copied;
+	if (status < 0)
+		return status;
+	return copied;
 }
 
 static void nfs_invalidate_page(struct page *page, unsigned long offset)
