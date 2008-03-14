From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] lockd: refactor SM_MON my_id argument encoder
Date: Fri, 14 Mar 2008 14:25:46 -0400
Message-ID: <20080314182546.30171.83469.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44610 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbYCNS0E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:26:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: introduce a new XDR encoder specifically for the my_id
argument of SM_MON requests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 87bd4e4..06216d6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -183,6 +183,25 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 	return xdr_encode_nsm_string(p, name);
 }
 
+/*
+ * The "my_id" argument specifies the hostname and RPC procedure
+ * to be called when the status manager receives notification
+ * (via the SM_NOTIFY call) that the state of host "mon_name"
+ * has changed.
+ */
+static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
+{
+	p = xdr_encode_nsm_string(p, utsname()->nodename);
+	if (!p)
+		return ERR_PTR(-EIO);
+
+	*p++ = htonl(argp->prog);
+	*p++ = htonl(argp->vers);
+	*p++ = htonl(argp->proc);
+
+	return p;
+}
+
 static __be32 *
 xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {

