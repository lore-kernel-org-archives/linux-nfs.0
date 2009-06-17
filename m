From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 14:15:41 -0400
Message-ID: <1245262541-9362-5-git-send-email-jlayton@redhat.com>
References: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60753 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757486AbZFQSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 14:15:48 -0400
In-Reply-To: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The framework to add this is all in place. Now, add the code to allow
support for establishing a callback channel on an IPv6 socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   88 +++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 78 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f1caddd..6c6799d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -55,6 +55,8 @@
 #include <linux/lockd/bind.h>
 #include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/inet.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -73,6 +75,12 @@ static u64 current_sessionid = 1;
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#define ADDR_STRLEN INET6_ADDRSTRLEN
+#else /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#define ADDR_STRLEN INET_ADDRSTRLEN
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+
 /* forward declarations */
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
@@ -983,19 +991,58 @@ parse_ipv4(unsigned int addrlen, char *addr, struct sockaddr_in *s4)
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
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	return;
@@ -1203,6 +1250,7 @@ static bool
 cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 {
 	struct sockaddr_in *a4, *b4;
+	struct sockaddr_in6 *a6, *b6;
 
 	if (a->sa_family != b->sa_family)
 		return false;
@@ -1212,6 +1260,12 @@ cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
 		a4 = (struct sockaddr_in *) a;
 		b4 = (struct sockaddr_in *) b;
 		return (a4->sin_addr.s_addr == b4->sin_addr.s_addr);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		a6 = (struct sockaddr_in6 *) a;
+		b6 = (struct sockaddr_in6 *) b;
+		return ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr);
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	}
 
 	/* not sure how to compare, so just return false */
@@ -1223,6 +1277,7 @@ static void
 cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
 {
 	struct sockaddr_in *s4, *d4;
+	struct sockaddr_in6 *s6, *d6;
 
 	dst->sa_family = src->sa_family;
 
@@ -1232,6 +1287,13 @@ cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
 		d4 = (struct sockaddr_in *) dst;
 		d4->sin_addr.s_addr = s4->sin_addr.s_addr;
 		return;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		s6 = (struct sockaddr_in6 *) src;
+		d6 = (struct sockaddr_in6 *) dst;
+		ipv6_addr_copy(&d6->sin6_addr, &s6->sin6_addr);
+		return;
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	default:
 		dst->sa_family = AF_UNSPEC;
 	}
@@ -1246,6 +1308,12 @@ cl_addr_snprintf(char *buf, size_t size, struct sockaddr *sa)
 		snprintf(buf, size, "%pI4",
 			 &((struct sockaddr_in *) sa)->sin_addr.s_addr);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		snprintf(buf, size, "%pI6",
+			 &((struct sockaddr_in6 *) sa)->sin6_addr.s6_addr);
+		break;
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	default:
 		snprintf(buf, size, "(family=%hu)", sa->sa_family);
 	}
@@ -1263,11 +1331,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	int status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
-	char			addr_str[INET_ADDRSTRLEN];
+	char			addr_str[ADDR_STRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
 
-	cl_addr_snprintf(addr_str, INET_ADDRSTRLEN, sa);
+	cl_addr_snprintf(addr_str, ADDR_STRLEN, sa);
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
 		"ip_addr=%s flags %x, spa_how %d\n",
 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
@@ -1631,8 +1699,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			char addr_str[INET_ADDRSTRLEN];
-			cl_addr_snprintf(addr_str, INET_ADDRSTRLEN,
+			char addr_str[ADDR_STRLEN];
+			cl_addr_snprintf(addr_str, ADDR_STRLEN,
 					 (struct sockaddr *) &conf->cl_addr);
 			dprintk("NFSD: setclientid: string in use by client "
 				"at %s\n", addr_str);
-- 
1.6.0.6

