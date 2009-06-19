From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/5] nfsd: add support for NFSv4 callbacks over IPv6
Date: Fri, 19 Jun 2009 14:43:00 -0400
Message-ID: <1245436981-11806-5-git-send-email-jlayton@redhat.com>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Cc: bfields@fieldses.org, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:45928 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbZFSSnA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 14:43:00 -0400
In-Reply-To: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The framework to add this is all in place. Now, add the code to allow
support for establishing a callback channel on an IPv6 socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   76 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c50f020..4e9d5d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -55,6 +55,8 @@
 #include <linux/lockd/bind.h>
 #include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/inet.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -988,19 +990,58 @@ parse_ipv4(unsigned int addrlen, char *addr, struct sockaddr_in *s4)
 	return parse_port(addrlen, addr, &s4->sin_port);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int
+parse_ipv6(unsigned int addrlen, char *addr, struct sockaddr_in6 *s6)
+{
+	char *dot;
+
+	s6->sin6_family = AF_INET6;
+
+	if (!in6_pton(addr, addrlen, (u8 *) &s6->sin6_addr.s6_addr, '.',
+		      (const char **) &dot))
+		return 0;
+
+	if ((addr + addrlen) <= dot)
+		return 0;
+
+	if (*dot++ != '.')
+		return 0;
+
+	return parse_port(addrlen - (dot - addr), dot, &s6->sin6_port);
+}
+#else /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+static int
+parse_ipv6(unsigned int addrlen, char *addr, struct sockaddr_in6 *s6)
+{
+	return 0;
+}
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 
-	/* Currently, we only support tcp for the callback channel */
-	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
+	/* Currently, we only support tcp and tcp6 for the callback channel */
+	if (se->se_callback_netid_len == 3 &&
+	    !memcmp(se->se_callback_netid_val, "tcp", 3)) {
+		if (!parse_ipv4(se->se_callback_addr_len,
+				se->se_callback_addr_val,
+				(struct sockaddr_in *) &cb->cb_addr))
+			goto out_err;
+		cb->cb_addrlen = sizeof(struct sockaddr_in);
+	} else if (se->se_callback_netid_len == 4 &&
+		   !memcmp(se->se_callback_netid_val, "tcp6", 4)) {
+		if (!parse_ipv6(se->se_callback_addr_len,
+				se->se_callback_addr_val,
+				(struct sockaddr_in6 *) &cb->cb_addr))
+			goto out_err;
+		cb->cb_addrlen = sizeof(struct sockaddr_in6);
+	} else {
 		goto out_err;
+	}
 
-	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
-			  (struct sockaddr_in *) &cb->cb_addr)))
-		goto out_err;
-	cb->cb_addrlen = sizeof(struct sockaddr_in);
 	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
@@ -1209,6 +1250,7 @@ static bool
 cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 {
 	struct sockaddr_in *a4, *b4;
+	struct sockaddr_in6 *a6, *b6;
 
 	if (a->sa_family != b->sa_family)
 		return false;
@@ -1218,6 +1260,10 @@ cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 		a4 = (struct sockaddr_in *) a;
 		b4 = (struct sockaddr_in *) b;
 		return (a4->sin_addr.s_addr == b4->sin_addr.s_addr);
+	case AF_INET6:
+		a6 = (struct sockaddr_in6 *) a;
+		b6 = (struct sockaddr_in6 *) b;
+		return ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr);
 	}
 
 	/* not sure how to compare, so just return false */
@@ -1229,6 +1275,7 @@ static void
 cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
 {
 	struct sockaddr_in *s4, *d4;
+	struct sockaddr_in6 *s6, *d6;
 
 	dst->sa_family = src->sa_family;
 
@@ -1238,6 +1285,11 @@ cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
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
@@ -1252,6 +1304,10 @@ cl_addr_snprintf(char *buf, size_t size, struct sockaddr *sa)
 		snprintf(buf, size, "%pI4",
 			 &((struct sockaddr_in *) sa)->sin_addr.s_addr);
 		break;
+	case AF_INET6:
+		snprintf(buf, size, "%pI6",
+			 &((struct sockaddr_in6 *) sa)->sin6_addr.s6_addr);
+		break;
 	default:
 		snprintf(buf, size, "(family=%hu)", sa->sa_family);
 	}
@@ -1269,11 +1325,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	int status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
-	char			addr_str[INET_ADDRSTRLEN];
+	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
 
-	cl_addr_snprintf(addr_str, INET_ADDRSTRLEN, sa);
+	cl_addr_snprintf(addr_str, INET6_ADDRSTRLEN, sa);
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
 		"ip_addr=%s flags %x, spa_how %d\n",
 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
@@ -1632,8 +1688,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			char addr_str[INET_ADDRSTRLEN];
-			cl_addr_snprintf(addr_str, INET_ADDRSTRLEN,
+			char addr_str[INET6_ADDRSTRLEN];
+			cl_addr_snprintf(addr_str, INET6_ADDRSTRLEN,
 					 (struct sockaddr *) &conf->cl_addr);
 			dprintk("NFSD: setclientid: string in use by client "
 				"at %s\n", addr_str);
-- 
1.6.0.6

