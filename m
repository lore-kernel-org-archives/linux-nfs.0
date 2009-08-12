From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 7/7] nfsd: populate sin6_scope_id on callback address with scopeid from rq_addr on SETCLIENTID call
Date: Wed, 12 Aug 2009 07:57:06 -0400
Message-ID: <1250078226-10511-8-git-send-email-jlayton@redhat.com>
References: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35944 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206AbZHLL7L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 07:59:11 -0400
In-Reply-To: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
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
 fs/nfsd/nfs4state.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ec0ca1..3e8478b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -898,7 +898,7 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 }
 
 static void
-gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
+gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	unsigned short expected_family;
@@ -921,6 +921,9 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if (!cb->cb_addrlen || cb->cb_addr.ss_family != expected_family)
 		goto out_err;
 
+	if (cb->cb_addr.ss_family == AF_INET6)
+		((struct sockaddr_in6 *) &cb->cb_addr)->sin6_scope_id = scopeid;
+
 	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
@@ -1507,6 +1510,15 @@ out:
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
@@ -1621,7 +1633,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

