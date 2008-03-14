From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] lockd: Ensure NSM strings aren't longer than protocol
	allows
Date: Fri, 14 Mar 2008 14:25:32 -0400
Message-ID: <20080314182531.30171.73471.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44462 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572AbYCNSZt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:25:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a special helper function to check the length of NSM strings
before they are placed on the wire.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 908b23f..84fd84c 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -149,6 +149,15 @@ nsm_create(void)
  * XDR functions for NSM.
  */
 
+static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
+{
+	size_t len = strlen(string);
+
+	if (len > SM_MAXSTRLEN)
+		len = SM_MAXSTRLEN;
+	return xdr_encode_opaque(p, string, len);
+}
+
 static __be32 *
 xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {

