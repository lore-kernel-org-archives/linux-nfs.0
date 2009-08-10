From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Mon, 10 Aug 2009 18:09:17 -0400
Message-ID: <1249942157-12613-5-git-send-email-jlayton@redhat.com>
References: <1249942157-12613-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34414 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521AbZHJWJ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2009 18:09:27 -0400
In-Reply-To: <1249942157-12613-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The framework to add this is all in place. Now, add the code to allow
support for establishing a callback channel on an IPv6 socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d294b1d..578e48c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -56,6 +56,7 @@
 #include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/clnt.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -901,9 +902,16 @@ static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
-
-	/* Currently, we only support tcp for the callback channel */
-	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
+	unsigned short expected_family;
+
+	/* Currently, we only support tcp and tcp6 for the callback channel */
+	if (se->se_callback_netid_len == 3 &&
+	    !memcmp(se->se_callback_netid_val, "tcp", 3))
+		expected_family = AF_INET;
+	else if (se->se_callback_netid_len == 4 &&
+		 !memcmp(se->se_callback_netid_val, "tcp6", 4))
+		expected_family = AF_INET6;
+	else
 		goto out_err;
 
 	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
@@ -911,7 +919,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 					    (struct sockaddr *) &cb->cb_addr,
 					    sizeof(cb->cb_addr));
 
-	if (cb->cb_addr.ss_family != AF_INET)
+	if (cb->cb_addr.ss_family != expected_family)
 		goto out_err;
 	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
@@ -1153,6 +1161,7 @@ static bool
 cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 {
 	struct sockaddr_in *a4, *b4;
+	struct sockaddr_in6 *a6, *b6;
 
 	if (a->sa_family != b->sa_family)
 		return false;
@@ -1162,6 +1171,10 @@ cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 		a4 = (struct sockaddr_in *) a;
 		b4 = (struct sockaddr_in *) b;
 		return (a4->sin_addr.s_addr == b4->sin_addr.s_addr);
+	case AF_INET6:
+		a6 = (struct sockaddr_in6 *) a;
+		b6 = (struct sockaddr_in6 *) b;
+		return ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr);
 	}
 
 	/* not sure how to compare, so just return false */
@@ -1173,6 +1186,7 @@ static void
 cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
 {
 	struct sockaddr_in *s4, *d4;
+	struct sockaddr_in6 *s6, *d6;
 
 	dst->sa_family = src->sa_family;
 
@@ -1182,6 +1196,11 @@ cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
 		d4 = (struct sockaddr_in *) dst;
 		d4->sin_addr.s_addr = s4->sin_addr.s_addr;
 		return;
+	case AF_INET6:
+		s6 = (struct sockaddr_in6 *) src;
+		d6 = (struct sockaddr_in6 *) dst;
+		ipv6_addr_copy(&d6->sin6_addr, &s6->sin6_addr);
+		return;
 	default:
 		dst->sa_family = AF_UNSPEC;
 	}
@@ -1196,7 +1215,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	int status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
-	char			addr_str[INET_ADDRSTRLEN];
+	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
 
@@ -1574,7 +1593,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			char addr_str[INET_ADDRSTRLEN];
+			char addr_str[INET6_ADDRSTRLEN];
 			rpc_ntop((struct sockaddr *) &conf->cl_addr, addr_str,
 				 sizeof(addr_str));
 			dprintk("NFSD: setclientid: string in use by client "
-- 
1.6.0.6

