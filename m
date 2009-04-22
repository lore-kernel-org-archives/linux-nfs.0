From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] Change prognum, versnum, minvers, and maxvers in progping
	to u_int32_t from u_long
Date: Wed, 22 Apr 2009 14:45:48 -0700
Message-ID: <1240436748.2246.9.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>
To: NFS List <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:50526 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756076AbZDVVkH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 17:40:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MLZYCi015601
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 17:35:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MLe66W194678
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 17:40:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MLe60e001951
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 17:40:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a problem where "rpcinfo -T transport host prognum" fails on a PPC64
because CLNT_CONTROL expects the version number to be a 32 bit quantity. u_long
probably works fine on little endian machines, but won't work on big endian
machines.


Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 src/rpcinfo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/rpcinfo.c b/src/rpcinfo.c
index 0170f65..698f4ca 100644
--- a/src/rpcinfo.c
+++ b/src/rpcinfo.c
@@ -1591,7 +1591,7 @@ progping (netid, argc, argv)
   CLIENT *client;
   struct timeval to;
   enum clnt_stat rpc_stat;
-  u_long prognum, versnum, minvers, maxvers;
+  u_int32_t prognum, versnum, minvers, maxvers;
   struct rpc_err rpcerr;
   int failure = 0;
   struct netconfig *nconf;
-- 
1.5.2.2



