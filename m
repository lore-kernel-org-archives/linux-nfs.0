From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/6] nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
Date: Fri, 14 Aug 2009 12:57:56 -0400
Message-ID: <1250269079-14629-4-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55282 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbZHNQ6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 12:58:05 -0400
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's currently a __be32, which isn't big enough to hold an IPv6 address.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c        |   32 +++++++++++++++++++-------------
 include/linux/nfsd/state.h |    2 +-
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9295c4b..bfc14d8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -55,6 +55,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/clnt.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -1220,13 +1221,15 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	int status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
+	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
-	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct sockaddr		*sa = svc_addr(rqstp);
 
+	rpc_ntop(sa, addr_str, sizeof(addr_str));
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
-		" ip_addr=%u flags %x, spa_how %d\n",
+		"ip_addr=%s flags %x, spa_how %d\n",
 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
-		ip_addr, exid->flags, exid->spa_how);
+		addr_str, exid->flags, exid->spa_how);
 
 	if (!check_name(exid->clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
 		return nfserr_inval;
@@ -1315,7 +1318,7 @@ out_new:
 
 	copy_verf(new, &verf);
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
-	new->cl_addr = ip_addr;
+	rpc_copy_addr((struct sockaddr *) &new->cl_addr, sa);
 	gen_clid(new);
 	gen_confirm(new);
 	add_to_unconfirmed(new, strhashval);
@@ -1389,7 +1392,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_create_session *cr_ses)
 {
-	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	int status = 0;
@@ -1417,7 +1420,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cs_slot->sl_seqid++;
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    (ip_addr != unconf->cl_addr)) {
+		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
 			goto out;
 		}
@@ -1564,7 +1567,7 @@ __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
-	struct sockaddr_in	*sin = svc_addr_in(rqstp);
+	struct sockaddr		*sa = svc_addr(rqstp);
 	struct xdr_netobj 	clname = { 
 		.len = setclid->se_namelen,
 		.data = setclid->se_name,
@@ -1596,8 +1599,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			dprintk("NFSD: setclientid: string in use by client"
-				" at %pI4\n", &conf->cl_addr);
+			char addr_str[INET6_ADDRSTRLEN];
+			rpc_ntop((struct sockaddr *) &conf->cl_addr, addr_str,
+				 sizeof(addr_str));
+			dprintk("NFSD: setclientid: string in use by client "
+				"at %s\n", addr_str);
 			goto out;
 		}
 	}
@@ -1659,7 +1665,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_clid(new);
 	}
 	copy_verf(new, &clverifier);
-	new->cl_addr = sin->sin_addr.s_addr;
+	rpc_copy_addr((struct sockaddr *) &new->cl_addr, sa);
 	new->cl_flavor = rqstp->rq_flavor;
 	princ = svc_gss_principal(rqstp);
 	if (princ) {
@@ -1693,7 +1699,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			 struct nfsd4_compound_state *cstate,
 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
-	struct sockaddr_in *sin = svc_addr_in(rqstp);
+	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
@@ -1712,9 +1718,9 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	unconf = find_unconfirmed_client(clid);
 
 	status = nfserr_clid_inuse;
-	if (conf && conf->cl_addr != sin->sin_addr.s_addr)
+	if (conf && !rpc_cmp_addr((struct sockaddr *) &conf->cl_addr, sa))
 		goto out;
-	if (unconf && unconf->cl_addr != sin->sin_addr.s_addr)
+	if (unconf && !rpc_cmp_addr((struct sockaddr *) &unconf->cl_addr, sa))
 		goto out;
 
 	/*
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 58bb197..3510ddd 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -200,7 +200,7 @@ struct nfs4_client {
 	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	time_t                  cl_time;        /* time of last lease renewal */
-	__be32			cl_addr; 	/* client ipaddress */
+	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
 	u32			cl_flavor;	/* setclientid pseudoflavor */
 	char			*cl_principal;	/* setclientid principal name */
 	struct svc_cred		cl_cred; 	/* setclientid principal */
-- 
1.6.0.6

