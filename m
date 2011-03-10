Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53636 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab1CJJmp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Mar 2011 04:42:45 -0500
Message-ID: <4D789D49.7090407@cn.fujitsu.com>
Date: Thu, 10 Mar 2011 17:43:37 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs41: make sure nfs server return right ca_maxresponsesize_cached
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

According to rfc5661, 
  
  ca_maxresponsesize_cached:

     Like ca_maxresponsesize, but the maximum size of a reply that
     will be stored in the reply cache (Section 2.10.6.1).  For each
     channel, the server MAY decrease this value, but MUST NOT
     increase it.
 
the latest kernel(2.6.38-rc8) may increase the value for ignoring 
request's ca_maxresponsesize_cached value. We should not ignore it.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 54b60bf..96edd02 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -608,7 +608,8 @@ static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4
 	u32 maxrpc = nfsd_serv->sv_max_mesg;
 
 	new->maxreqs = numslots;
-	new->maxresp_cached = slotsize + NFSD_MIN_HDR_SEQ_SZ;
+	new->maxresp_cached = min_t(u32, req->maxresp_cached, 
+					slotsize + NFSD_MIN_HDR_SEQ_SZ);
 	new->maxreq_sz = min_t(u32, req->maxreq_sz, maxrpc);
 	new->maxresp_sz = min_t(u32, req->maxresp_sz, maxrpc);
 	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
-- 
1.7.4.1



