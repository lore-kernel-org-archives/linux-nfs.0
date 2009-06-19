From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] nfsd: populate sin6_scope_id on callback address with scopeid from rq_addr on SETCLIENTID call
Date: Fri, 19 Jun 2009 14:43:01 -0400
Message-ID: <1245436981-11806-6-git-send-email-jlayton@redhat.com>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Cc: bfields@fieldses.org, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:45946 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbZFSSnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 14:43:02 -0400
In-Reply-To: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a SETCLIENTID call comes in, one of the args given is the svc_rqst.
This struct contains an rq_addr field which holds the address that sent
the call. If this is an IPv6 address, then we can use the sin6_scope_id
field in this address to populate the sin6_scope_id field in the
callback address.

AFAICT, the rq_addr.sin6_scope_id is non-zero if and only if the client
mounted the server's link-local address.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4e9d5d9..d98d95c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1019,7 +1019,7 @@ parse_ipv6(unsigned int addrlen, char *addr, struct sockaddr_in6 *s6)
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 
 static void
-gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
+gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 
@@ -1037,6 +1037,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 				se->se_callback_addr_val,
 				(struct sockaddr_in6 *) &cb->cb_addr))
 			goto out_err;
+		((struct sockaddr_in6 *) &cb->cb_addr)->sin6_scope_id = scopeid;
 		cb->cb_addrlen = sizeof(struct sockaddr_in6);
 	} else {
 		goto out_err;
@@ -1652,6 +1653,15 @@ out:
 	return status;
 }
 
+static u32
+get_scope_id(struct sockaddr *sa)
+{
+	if (sa->sa_family != AF_INET6)
+		return 0;
+
+	return ((struct sockaddr_in6 *) sa)->sin6_scope_id;
+}
+
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
@@ -1766,7 +1776,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
 	gen_confirm(new);
-	gen_callback(new, setclid);
+	gen_callback(new, setclid, get_scope_id(sa));
 	add_to_unconfirmed(new, strhashval);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
-- 
1.6.0.6

