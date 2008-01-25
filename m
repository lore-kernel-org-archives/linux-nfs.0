From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 099/112] NFS: NFS version number is unsigned
Date: Fri, 25 Jan 2008 11:37:59 -0500
Message-ID: <20080125163759.31887.60552.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14345 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286AbYAYQ7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:50 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdtE010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:49 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

RPC protocol version numbers are unsigned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/nfs_xdr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d342ae5..f301d0b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -774,7 +774,7 @@ struct nfs_access_entry;
  * RPC procedure vector for NFSv2/NFSv3 demuxing
  */
 struct nfs_rpc_ops {
-	int	version;		/* Protocol version */
+	u32	version;		/* Protocol version */
 	struct dentry_operations *dentry_ops;
 	const struct inode_operations *dir_inode_ops;
 	const struct inode_operations *file_inode_ops;
