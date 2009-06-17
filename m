From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/4] nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
Date: Wed, 17 Jun 2009 14:15:40 -0400
Message-ID: <1245262541-9362-4-git-send-email-jlayton@redhat.com>
References: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60755 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767AbZFQSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 14:15:48 -0400
In-Reply-To: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's currently a __be32, which isn't big enough to hold an IPv6 address.
While we're at it, add some new routines for comparing and copying
cl_addr's, and a function for formatting a cl_addr into a string.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c        |   89 +++++++++++++++++++++++++++++++++++++-------
 include/linux/nfsd/state.h |    2 +-
 2 files changed, 76 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a12219..f1caddd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1198,6 +1198,62 @@ nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 	clid->flags = new->cl_exchange_flags;
 }
 
+/* Returns true if addresses are equal (ignoring port, scope, etc) */
+static bool
+cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
+{
+	struct sockaddr_in *a4, *b4;
+
+	if (a->sa_family != b->sa_family)
+		return false;
+
+	switch (a->sa_family) {
+	case AF_INET:
+		a4 = (struct sockaddr_in *) a;
+		b4 = (struct sockaddr_in *) b;
+		return (a4->sin_addr.s_addr == b4->sin_addr.s_addr);
+	}
+
+	/* not sure how to compare, so just return false */
+	return false;
+}
+
+/* Given a sockaddr, fill in the cl_addr -- ignore port, scope, etc */
+static void
+cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
+{
+	struct sockaddr_in *s4, *d4;
+
+	dst->sa_family = src->sa_family;
+
+	switch (dst->sa_family) {
+	case AF_INET:
+		s4 = (struct sockaddr_in *) src;
+		d4 = (struct sockaddr_in *) dst;
+		d4->sin_addr.s_addr = s4->sin_addr.s_addr;
+		return;
+	default:
+		dst->sa_family = AF_UNSPEC;
+	}
+}
+
+/* format the cl_addr as text and stuff it into buf. Don't go beyond size. */
+static void
+cl_addr_snprintf(char *buf, size_t size, struct sockaddr *sa)
+{
+	switch (sa->sa_family) {
+	case AF_INET:
+		snprintf(buf, size, "%pI4",
+			 &((struct sockaddr_in *) sa)->sin_addr.s_addr);
+		break;
+	default:
+		snprintf(buf, size, "(family=%hu)", sa->sa_family);
+	}
+
+	/* forcibly NULL terminate string, just in case */
+	buf[size - 1] = '\0';
+}
+
 __be32
 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
@@ -1207,13 +1263,15 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	int status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
+	char			addr_str[INET_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
-	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct sockaddr		*sa = svc_addr(rqstp);
 
+	cl_addr_snprintf(addr_str, INET_ADDRSTRLEN, sa);
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
-		" ip_addr=%u flags %x, spa_how %d\n",
+		"ip_addr=%s flags %x, spa_how %d\n",
 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
-		ip_addr, exid->flags, exid->spa_how);
+		addr_str, exid->flags, exid->spa_how);
 
 	if (!check_name(exid->clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
 		return nfserr_inval;
@@ -1261,7 +1319,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			expire_client(conf);
 			goto out_new;
 		}
-		if (ip_addr != conf->cl_addr &&
+		if (!cl_addr_equal((struct sockaddr *) &conf->cl_addr, sa) &&
 		    !(exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)) {
 			/* Client collision. 18.35.4 case 3 */
 			status = nfserr_clid_inuse;
@@ -1308,7 +1366,7 @@ out_new:
 
 	copy_verf(new, &verf);
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
-	new->cl_addr = ip_addr;
+	cl_addr_copy((struct sockaddr *) &new->cl_addr, sa);
 	gen_clid(new);
 	gen_confirm(new);
 	add_to_unconfirmed(new, strhashval);
@@ -1362,7 +1420,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_create_session *cr_ses)
 {
-	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_slot *slot = NULL;
@@ -1393,7 +1451,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    (ip_addr != unconf->cl_addr)) {
+		    !cl_addr_equal(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
 			goto out;
 		}
@@ -1541,7 +1599,7 @@ __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
-	struct sockaddr_in	*sin = svc_addr_in(rqstp);
+	struct sockaddr		*sa = svc_addr(rqstp);
 	struct xdr_netobj 	clname = { 
 		.len = setclid->se_namelen,
 		.data = setclid->se_name,
@@ -1573,8 +1631,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			dprintk("NFSD: setclientid: string in use by client"
-				" at %pI4\n", &conf->cl_addr);
+			char addr_str[INET_ADDRSTRLEN];
+			cl_addr_snprintf(addr_str, INET_ADDRSTRLEN,
+					 (struct sockaddr *) &conf->cl_addr);
+			dprintk("NFSD: setclientid: string in use by client "
+				"at %s\n", addr_str);
 			goto out;
 		}
 	}
@@ -1636,7 +1697,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_clid(new);
 	}
 	copy_verf(new, &clverifier);
-	new->cl_addr = sin->sin_addr.s_addr;
+	cl_addr_copy((struct sockaddr *) &new->cl_addr, sa);
 	new->cl_flavor = rqstp->rq_flavor;
 	princ = svc_gss_principal(rqstp);
 	if (princ) {
@@ -1670,7 +1731,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			 struct nfsd4_compound_state *cstate,
 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
-	struct sockaddr_in *sin = svc_addr_in(rqstp);
+	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
@@ -1689,9 +1750,9 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	unconf = find_unconfirmed_client(clid);
 
 	status = nfserr_clid_inuse;
-	if (conf && conf->cl_addr != sin->sin_addr.s_addr)
+	if (conf && !cl_addr_equal((struct sockaddr *) &conf->cl_addr, sa))
 		goto out;
-	if (unconf && unconf->cl_addr != sin->sin_addr.s_addr)
+	if (unconf && !cl_addr_equal((struct sockaddr *) &unconf->cl_addr, sa))
 		goto out;
 
 	/*
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 95a925c..d9728b9 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -179,7 +179,7 @@ struct nfs4_client {
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

