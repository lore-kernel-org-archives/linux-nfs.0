From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 089/112] NFS: Fix minor mixed sign comparison in NFS
	client's write logic
Date: Fri, 25 Jan 2008 11:37:55 -0500
Message-ID: <20080125163755.31887.34017.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14332 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754532AbYAYQ7p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:45 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdsu010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:44 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: PAGE_CACHE_SIZE is unsigned, and nfs_pageio_init() takes a size_t.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fbd64f2..5ac5b27 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -939,7 +939,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
-	int wsize = NFS_SERVER(inode)->wsize;
+	size_t wsize = NFS_SERVER(inode)->wsize;
 
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
