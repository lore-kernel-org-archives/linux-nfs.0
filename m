Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:59791 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754865Ab3EVKAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 06:00:07 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id C02E02800D9
	for <linux-nfs@vger.kernel.org>; Wed, 22 May 2013 12:00:05 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 712761215
	for <linux-nfs@vger.kernel.org>; Wed, 22 May 2013 12:00:03 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Tabd885058183a961601220@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Wed, 22 May 2013 12:00:03 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs: include invalid uid/gid in the error message
Date: Wed, 22 May 2013 11:59:54 +0200
Message-Id: <1369216794-18044-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

if client receives an invalid uid/gid debug message is generated.
Unfortunately the actual invalid value is not included.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/nfs2xdr.c | 4 ++--
 fs/nfs/nfs3xdr.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 62db136..85c0646 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -319,10 +319,10 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	return 0;
 out_uid:
-	dprintk("NFS: returned invalid uid\n");
+	dprintk("NFS: returned invalid uid %d\n", fattr->uid);
 	return -EINVAL;
 out_gid:
-	dprintk("NFS: returned invalid gid\n");
+	dprintk("NFS: returned invalid gid %d\n", fattr->gid);
 	return -EINVAL;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index fa6d721..cd52069 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -680,10 +680,10 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	fattr->valid |= NFS_ATTR_FATTR_V3;
 	return 0;
 out_uid:
-	dprintk("NFS: returned invalid uid\n");
+	dprintk("NFS: returned invalid uid %d\n", fattr->uid);
 	return -EINVAL;
 out_gid:
-	dprintk("NFS: returned invalid gid\n");
+	dprintk("NFS: returned invalid gid %d\n", fattr->gid);
 	return -EINVAL;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-- 
1.8.1.4

