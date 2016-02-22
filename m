Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbcBVSJN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 13:09:13 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 0B77B7EBA4
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2016 18:09:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1MI9CIP017897
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2016 13:09:12 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: use correct byte order on rdma port.
Date: Mon, 22 Feb 2016 13:09:10 -0500
Message-Id: <1456164550-6369-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The returned port from getservbyname() is in
network order. Convert the port to host order
before writing it to the portlist file.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfssvc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index e8efd06..dcb430a 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -282,7 +282,7 @@ nfssvc_set_rdmaport(const char *port)
 	int fd;
 
 	if (sv)
-		nport = sv->s_port;
+		nport = ntohs(sv->s_port);
 	else {
 		char *ep;
 		nport = strtol(port, &ep, 10);
-- 
2.5.0

