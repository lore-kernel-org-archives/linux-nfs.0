From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 036/112] NFS: Ensure nfs_wcc_update_inode always converts
	file size to loff_t
Date: Fri, 25 Jan 2008 11:37:33 -0500
Message-ID: <20080125163733.31887.58369.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755010AbYAYRAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:17 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Hg010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:15 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The nfs_wcc_update_inode() function omits logic to convert the type of
the NFS on-the-wire value of a file's size (__u64) to the type of file
size value stored in struct inode (loff_t, which is signed).

Everywhere else in the NFS client I checked already correctly converts the
file size type.

This effects only very large files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index db5d96d..cd0e57f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -814,8 +814,9 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if (S_ISDIR(inode->i_mode))
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		}
-		if (inode->i_size == fattr->pre_size && nfsi->npages == 0)
-			inode->i_size = fattr->size;
+		if (inode->i_size == nfs_size_to_loff_t(fattr->pre_size) &&
+		    nfsi->npages == 0)
+			inode->i_size = nfs_size_to_loff_t(fattr->size);
 	}
 }
 
