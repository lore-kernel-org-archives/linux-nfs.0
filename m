From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] lockd: refactor SM_MON mon_name argument encoder
Date: Fri, 14 Mar 2008 14:25:39 -0400
Message-ID: <20080314182539.30171.4746.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44527 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbYCNSZ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:25:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: introduce a new XDR encoder specifically for the mon_name
argument of SM_MON requests.  This will be updated later to support IPv6
addresses in addition to IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 84fd84c..87bd4e4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,6 +18,8 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
+#define XDR_ADDRBUF_LEN		(20)
+
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
@@ -158,6 +160,29 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
 	return xdr_encode_opaque(p, string, len);
 }
 
+/*
+ * "mon_name" specifies the host to be monitored.
+ *
+ * Linux uses a text version of the IP address of the remote
+ * host as the host identifier (the "mon_name" argument).
+ *
+ * Linux statd always looks up the canonical hostname first for
+ * whatever remote hostname it receives, so this works alright.
+ */
+static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
+{
+	char	buffer[XDR_ADDRBUF_LEN + 1];
+	char	*name = argp->mon_name;
+
+	if (!nsm_use_hostnames) {
+		snprintf(buffer, XDR_ADDRBUF_LEN,
+			 NIPQUAD_FMT, NIPQUAD(argp->addr));
+		name = buffer;
+	}
+
+	return xdr_encode_nsm_string(p, name);
+}
+
 static __be32 *
 xdr_encode_common(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {

