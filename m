From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 10/35] nfsd41: exchange_id operation
Date: Fri,  3 Apr 2009 08:28:01 +0300
Message-ID: <1238736481-17389-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26141 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754713AbZDCF2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:07 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the exchange_id operation confoming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-28

Based on the client provided name, hash a client id.
If a confirmed one is found, compare the op's creds and
verifier.  If the creds match and the verifier is different
then expire the old client (client re-incarnated), otherwise,
if both match, assume it's a replay and ignore it.

If an unconfirmed client is found, then copy the new creds
and verifer if need update, otherwise assume replay.

The client is moved to a confirmed state on create_session.

In the nfs41 branch set the exchange_id flags to
EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_SUPP_MOVED_REFER
(pNFS is not supported, Referrals are supported,
Migration is not.).

Address various scenarios from section 18.35 of the spec:

1. Check for EXCHGID4_FLAG_UPD_CONFIRMED_REC_A and set
   EXCHGID4_FLAG_CONFIRMED_R as appropriate.

2. Return error codes per 18.35.4 scenarios.

3. Update client records or generate new client ids depending on
   scenario.

Note: 18.35.4 case 3 probably still needs revisiting.  The handling
seems not quite right.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamosn <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use utsname for major_id (and copy to server_scope)]
[nfsd41: fix handling of various exchange id scenarios]
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: reverse use of EXCHGID4_INVAL_FLAG_MASK_A]
[simplify nfsd4_encode_exchange_id error handling]
[nfsd41: embed an xdr_netobj in nfsd4_exchange_id]
[nfsd41: return nfserr_serverfault for spa_how == SP4_MACH_CRED]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |  142 ++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c          |  147 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfsd/state.h |    2 +
 include/linux/nfsd/xdr4.h  |    7 ++-
 4 files changed, 292 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cfc01f4..4f963e9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -832,12 +832,152 @@ out_err:
 	return;
 }
 
+/*
+ * Set the exchange_id flags returned by the server.
+ */
+static void
+nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
+{
+	/* pNFS is not supported */
+	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
+
+	/* Referrals are supported, Migration is not. */
+	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
+
+	/* set the wire flags to return to client. */
+	clid->flags = new->cl_exchange_flags;
+}
+
 __be32
 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
 		  struct nfsd4_exchange_id *exid)
 {
-	return -1;	/* stub */
+	struct nfs4_client *unconf, *conf, *new;
+	int status;
+	unsigned int		strhashval;
+	char			dname[HEXDIR_LEN];
+	nfs4_verifier		verf = exid->verifier;
+	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+
+	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
+		" ip_addr=%u flags %x, spa_how %d\n",
+		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
+		ip_addr, exid->flags, exid->spa_how);
+
+	if (!check_name(exid->clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
+		return nfserr_inval;
+
+	/* Currently only support SP4_NONE */
+	switch (exid->spa_how) {
+	case SP4_NONE:
+		break;
+	case SP4_SSV:
+		return nfserr_encr_alg_unsupp;
+	default:
+		BUG();				/* checked by xdr code */
+	case SP4_MACH_CRED:
+		return nfserr_serverfault;	/* no excuse :-/ */
+	}
+
+	status = nfs4_make_rec_clidname(dname, &exid->clname);
+
+	if (status)
+		goto error;
+
+	strhashval = clientstr_hashval(dname);
+
+	nfs4_lock_state();
+	status = nfs_ok;
+
+	conf = find_confirmed_client_by_str(dname, strhashval);
+	if (conf) {
+		if (!same_verf(&verf, &conf->cl_verifier)) {
+			/* 18.35.4 case 8 */
+			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+				status = nfserr_not_same;
+				goto out;
+			}
+			/* Client reboot: destroy old state */
+			expire_client(conf);
+			goto out_new;
+		}
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
+			/* 18.35.4 case 9 */
+			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+				status = nfserr_perm;
+				goto out;
+			}
+			expire_client(conf);
+			goto out_new;
+		}
+		if (ip_addr != conf->cl_addr &&
+		    !(exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)) {
+			/* Client collision. 18.35.4 case 3 */
+			status = nfserr_clid_inuse;
+			goto out;
+		}
+		/*
+		 * Set bit when the owner id and verifier map to an already
+		 * confirmed client id (18.35.3).
+		 */
+		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+
+		/*
+		 * Falling into 18.35.4 case 2, possible router replay.
+		 * Leave confirmed record intact and return same result.
+		 */
+		copy_verf(conf, &verf);
+		new = conf;
+		goto out_copy;
+	} else {
+		/* 18.35.4 case 7 */
+		if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+			status = nfserr_noent;
+			goto out;
+		}
+	}
+
+	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
+	if (unconf) {
+		/*
+		 * Possible retry or client restart.  Per 18.35.4 case 4,
+		 * a new unconfirmed record should be generated regardless
+		 * of whether any properties have changed.
+		 */
+		expire_client(unconf);
+	}
+
+out_new:
+	/* Normal case */
+	new = create_client(exid->clname, dname);
+	if (new == NULL) {
+		status = nfserr_resource;
+		goto out;
+	}
+
+	copy_verf(new, &verf);
+	copy_cred(&new->cl_cred, &rqstp->rq_cred);
+	new->cl_addr = ip_addr;
+	gen_clid(new);
+	gen_confirm(new);
+	add_to_unconfirmed(new, strhashval);
+out_copy:
+	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
+	exid->clientid.cl_id = new->cl_clientid.cl_id;
+
+	new->cl_seqid = exid->seqid = 1;
+	nfsd4_set_ex_flags(new, exid);
+
+	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
+		new->cl_seqid, new->cl_exchange_flags);
+	status = nfs_ok;
+
+out:
+	nfs4_unlock_state();
+error:
+	dprintk("nfsd4_exchange_id returns %d\n", ntohl(status));
+	return status;
 }
 
 __be32
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6973d61..bebf6d2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -45,6 +45,7 @@
 #include <linux/fs.h>
 #include <linux/namei.h>
 #include <linux/vfs.h>
+#include <linux/utsname.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
@@ -998,9 +999,100 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
 
 static __be32
 nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
-			 struct nfsd4_exchange_id *clid)
+			 struct nfsd4_exchange_id *exid)
 {
-	return nfserr_opnotsupp;	/* stub */
+	int dummy;
+	DECODE_HEAD;
+
+	READ_BUF(NFS4_VERIFIER_SIZE);
+	COPYMEM(exid->verifier.data, NFS4_VERIFIER_SIZE);
+
+	READ_BUF(4);
+	READ32(exid->clname.len);
+
+	READ_BUF(exid->clname.len);
+	SAVEMEM(exid->clname.data, exid->clname.len);
+
+	READ_BUF(4);
+	READ32(exid->flags);
+
+	/* Ignore state_protect4_a */
+	READ_BUF(4);
+	READ32(exid->spa_how);
+	switch (exid->spa_how) {
+	case SP4_NONE:
+		break;
+	case SP4_MACH_CRED:
+		/* spo_must_enforce */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy * 4);
+		p += dummy;
+
+		/* spo_must_allow */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy * 4);
+		p += dummy;
+		break;
+	case SP4_SSV:
+		/* ssp_ops */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy * 4);
+		p += dummy;
+
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy * 4);
+		p += dummy;
+
+		/* ssp_hash_algs<> */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy);
+		p += XDR_QUADLEN(dummy);
+
+		/* ssp_encr_algs<> */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy);
+		p += XDR_QUADLEN(dummy);
+
+		/* ssp_window and ssp_num_gss_handles */
+		READ_BUF(8);
+		READ32(dummy);
+		READ32(dummy);
+		break;
+	default:
+		goto xdr_error;
+	}
+
+	/* Ignore Implementation ID */
+	READ_BUF(4);    /* nfs_impl_id4 array length */
+	READ32(dummy);
+
+	if (dummy > 1)
+		goto xdr_error;
+
+	if (dummy == 1) {
+		/* nii_domain */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy);
+		p += XDR_QUADLEN(dummy);
+
+		/* nii_name */
+		READ_BUF(4);
+		READ32(dummy);
+		READ_BUF(dummy);
+		p += XDR_QUADLEN(dummy);
+
+		/* nii_date */
+		READ_BUF(12);
+		p += 3;
+	}
+	DECODE_TAIL;
 }
 
 static __be32
@@ -2665,8 +2757,55 @@ static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 			 struct nfsd4_exchange_id *exid)
 {
-	/* stub */
-	return nfserr;
+	ENCODE_HEAD;
+	char *major_id;
+	char *server_scope;
+	int major_id_sz;
+	int server_scope_sz;
+	uint64_t minor_id = 0;
+
+	if (nfserr)
+		return nfserr;
+
+	major_id = utsname()->nodename;
+	major_id_sz = strlen(major_id);
+	server_scope = utsname()->nodename;
+	server_scope_sz = strlen(server_scope);
+
+	RESERVE_SPACE(
+		8 /* eir_clientid */ +
+		4 /* eir_sequenceid */ +
+		4 /* eir_flags */ +
+		4 /* spr_how (SP4_NONE) */ +
+		8 /* so_minor_id */ +
+		4 /* so_major_id.len */ +
+		(XDR_QUADLEN(major_id_sz) * 4) +
+		4 /* eir_server_scope.len */ +
+		(XDR_QUADLEN(server_scope_sz) * 4) +
+		4 /* eir_server_impl_id.count (0) */);
+
+	WRITEMEM(&exid->clientid, 8);
+	WRITE32(exid->seqid);
+	WRITE32(exid->flags);
+
+	/* state_protect4_r. Currently only support SP4_NONE */
+	BUG_ON(exid->spa_how != SP4_NONE);
+	WRITE32(exid->spa_how);
+
+	/* The server_owner struct */
+	WRITE64(minor_id);      /* Minor id */
+	/* major id */
+	WRITE32(major_id_sz);
+	WRITEMEM(major_id, major_id_sz);
+
+	/* Server scope */
+	WRITE32(server_scope_sz);
+	WRITEMEM(server_scope, server_scope_sz);
+
+	/* Implementation id */
+	WRITE32(0);	/* zero length nfs_impl_id4 array */
+	ADJUST_ARGS();
+	return 0;
 }
 
 static __be32
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 5b3a666..8d0b101 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -173,6 +173,8 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
+	u32			cl_seqid;       /* seqid for create_session */
+	u32			cl_exchange_flags;
 };
 
 /* struct nfs4_client_reset
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 294940c..33ee71e 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -345,7 +345,12 @@ struct nfsd4_write {
 };
 
 struct nfsd4_exchange_id {
-	int	foo;	/* stub */
+	nfs4_verifier	verifier;
+	struct xdr_netobj clname;
+	u32		flags;
+	clientid_t	clientid;
+	u32		seqid;
+	int		spa_how;
 };
 
 struct nfsd4_create_session {
-- 
1.6.2.1

