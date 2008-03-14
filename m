From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] lockd: document use of mon_id argument in SM_MON requests
Date: Fri, 14 Mar 2008 14:25:53 -0400
Message-ID: <20080314182553.30171.9341.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44636 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbYCNS0I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:26:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: document the argument type that xdr_encode_common() is
marshalling by introducing a new function.  The new function will replace
xdr_encode_common() in just a sec.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 06216d6..3935d7b 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -202,6 +202,19 @@ static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
 	return p;
 }
 
+/*
+ * The "mon_id" argument specifies the non-private arguments
+ * of an SM_MON or SM_UNMON call.
+ */
+static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
+{
+	p = xdr_encode_mon_name(p, argp);
+	if (!p)
+		return ERR_PTR(-EIO);
+
+	return xdr_encode_my_id(p, argp);
+}
+
 static __be32 *
 xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {

