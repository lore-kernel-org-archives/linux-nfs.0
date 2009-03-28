From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 34/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 11:34:08 +0300
Message-ID: <1238229248-11329-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:17509 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755307AbZC1IeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:34:17 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Note:  Both the NFSv4.1 client and server use this pointer.

The client uses cl_private to determine the minorversion
(via a struct nfs_client *) to be set in the compound header,
and to know when to generate a SEQUENCE op.
Similarly, the server puts a struct nfs4_callback * in
there for callback compounds' CB_COMPOUND and CB_SEQUENCE.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/clnt.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c39a210..928c547 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -53,6 +53,7 @@ struct rpc_clnt {
 	char			cl_pathname[30];/* Path in rpc_pipe_fs */
 	struct vfsmount *	cl_vfsmnt;
 	struct dentry *		cl_dentry;	/* inode */
+	void			*cl_private;	/* private data */
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
-- 
1.6.2.1

