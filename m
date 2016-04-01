Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:41549 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbcDAUTr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 16:19:47 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv3: Ignore wcc before ctime attribute
Date: Fri, 1 Apr 2016 16:19:43 -0400
Message-ID: <1459541983-21301-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 7c2dad99d60c86ec686b3bfdcb787c450a7ea89f
"Don't let the ctime override attribute barriers" introduced a problem
of invalidating the cache when receiving in-order WRITE replies. Because
ctime is no longer checked then attributes are not updated appropriately
and then leads to mismatch of received "before" with what's stored.

Given that sending the wcc attributes is not mandatory (and linux
server doesn't), we can ignore the received "before" ctime. It fixes
the current problem and also help when we receive out-of-order WRITEs.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs3xdr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 267126d..feca07f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -732,14 +732,12 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 		goto out_overflow;
 
 	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
-		| NFS_ATTR_FATTR_PRECHANGE
 		| NFS_ATTR_FATTR_PREMTIME
 		| NFS_ATTR_FATTR_PRECTIME;
 
 	p = xdr_decode_size3(p, &fattr->pre_size);
 	p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
 	xdr_decode_nfstime3(p, &fattr->pre_ctime);
-	fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);
 
 	return 0;
 out_overflow:
-- 
1.8.3.1

