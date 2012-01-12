Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:51485 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab2ALHHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 02:07:41 -0500
Date: Thu, 12 Jan 2012 10:07:35 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: cleanup endian type in decode_ds_addr()
Message-ID: <20120112070735.GB2975@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

port is supposed to be a __be16 here.  The existing code should work
fine, but this is a cleanup.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index ed388aa..8ae9190 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -382,7 +382,7 @@ decode_ds_addr(struct xdr_stream *streamp, gfp_t gfp_flags)
 {
 	struct nfs4_pnfs_ds_addr *da = NULL;
 	char *buf, *portstr;
-	u32 port;
+	__be16 port;
 	int nlen, rlen;
 	int tmp[2];
 	__be32 *p;
