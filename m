From: Greg Banks <gnb@sgi.com>
Subject: [patch 12/29] knfsd: Update per-client & per-export stats from NFSv4
Date: Wed, 01 Apr 2009 07:28:12 +1100
Message-ID: <20090331202942.142229000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22578 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755992AbZCaVCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add instrumentation to the NFSv4 server procedures.

Contains code based on a patch from Harshula Jayasuriya <harshula@sgi.com>.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfs4proc.c  |   40 +++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c |   34 ++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4xdr.c   |    7 +++++++
 3 files changed, 72 insertions(+), 9 deletions(-)

Index: bfields/fs/nfsd/nfs4proc.c
===================================================================
--- bfields.orig/fs/nfsd/nfs4proc.c
+++ bfields/fs/nfsd/nfs4proc.c
@@ -192,6 +192,9 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	   struct nfsd4_open *open)
 {
 	__be32 status;
+
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_stateowner);
@@ -350,12 +353,16 @@ static __be32
 nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_access *access)
 {
+	__be32 status;
+
 	if (access->ac_req_access & ~NFS3_ACCESS_FULL)
 		return nfserr_inval;
 
 	access->ac_resp_access = access->ac_req_access;
-	return nfsd_access(rqstp, &cstate->current_fh, &access->ac_resp_access,
-			   &access->ac_supported);
+	status = nfsd_access(rqstp, &cstate->current_fh, &access->ac_resp_access,
+			     &access->ac_supported);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+	return status;
 }
 
 static __be32
@@ -372,6 +379,7 @@ nfsd4_commit(struct svc_rqst *rqstp, str
 			     commit->co_count);
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_COMMIT);
 	return status;
 }
 
@@ -452,6 +460,8 @@ nfsd4_create(struct svc_rqst *rqstp, str
 		status = nfserr_badtype;
 	}
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_MKINODE);
+
 	if (!status) {
 		fh_unlock(&cstate->current_fh);
 		set_change_info(&create->cr_cinfo, &cstate->current_fh);
@@ -480,6 +490,7 @@ nfsd4_getattr(struct svc_rqst *rqstp, st
 	getattr->ga_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
 
 	getattr->ga_fhp = &cstate->current_fh;
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_GETATTR);
 	return nfs_ok;
 }
 
@@ -495,6 +506,7 @@ nfsd4_link(struct svc_rqst *rqstp, struc
 			   link->li_name, link->li_namelen, &cstate->save_fh);
 	if (!status)
 		set_change_info(&link->li_cinfo, &cstate->current_fh);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_MKINODE);
 	return status;
 }
 
@@ -514,17 +526,22 @@ nfsd4_lookupp(struct svc_rqst *rqstp, st
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
-	return nfsd_lookup(rqstp, &cstate->current_fh,
-			   "..", 2, &cstate->current_fh);
+	ret = nfsd_lookup(rqstp, &cstate->current_fh,
+			  "..", 2, &cstate->current_fh);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_LOOKUP);
+	return ret;
 }
 
 static __be32
 nfsd4_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_lookup *lookup)
 {
-	return nfsd_lookup(rqstp, &cstate->current_fh,
-			   lookup->lo_name, lookup->lo_len,
-			   &cstate->current_fh);
+	__be32 status;
+	status = nfsd_lookup(rqstp, &cstate->current_fh,
+			     lookup->lo_name, lookup->lo_len,
+			     &cstate->current_fh);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_LOOKUP);
+	return status;
 }
 
 static __be32
@@ -604,6 +621,7 @@ nfsd4_remove(struct svc_rqst *rqstp, str
 		return nfserr_grace;
 	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
 			     remove->rm_name, remove->rm_namelen);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_REMOVE);
 	if (status == nfserr_symlink)
 		return nfserr_notdir;
 	if (!status) {
@@ -628,6 +646,8 @@ nfsd4_rename(struct svc_rqst *rqstp, str
 			     rename->rn_snamelen, &cstate->current_fh,
 			     rename->rn_tname, rename->rn_tnamelen);
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_MKINODE);
+
 	/* the underlying filesystem returns different error's than required
 	 * by NFSv4. both save_fh and current_fh have been verified.. */
 	if (status == nfserr_isdir)
@@ -667,6 +687,7 @@ nfsd4_secinfo(struct svc_rqst *rqstp, st
 	} else
 		secinfo->si_exp = exp;
 	dput(dentry);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_FSINFO);
 	return err;
 }
 
@@ -700,6 +721,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 		goto out;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
 				0, (time_t)0);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_SETATTR);
 out:
 	mnt_drop_write(cstate->current_fh.fh_export->ex_path.mnt);
 	return status;
@@ -751,6 +773,8 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
+	nfsd_stats_update_write(rqstp, &cstate->current_fh, write->wr_bytes_written,
+				write->wr_how_written);
 	return status;
 }
 
@@ -809,6 +833,8 @@ _nfsd4_verify(struct svc_rqst *rqstp, st
 	if (!memcmp(p, verify->ve_attrval, verify->ve_attrlen))
 		status = nfserr_same;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+
 out_kfree:
 	kfree(buf);
 	return status;
Index: bfields/fs/nfsd/nfs4state.c
===================================================================
--- bfields.orig/fs/nfsd/nfs4state.c
+++ bfields/fs/nfsd/nfs4state.c
@@ -1217,6 +1217,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp
 		.data = exid->id,
 	};
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
 		" ip_addr=%u flags %x, spa_how %d\n",
 		__func__, rqstp, exid, clname.len, clname.data,
@@ -1368,6 +1370,8 @@ nfsd4_create_session(struct svc_rqst *rq
 	struct nfsd4_slot *slot = NULL;
 	int status = 0;
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&cr_ses->clientid);
 	conf = find_confirmed_client(&cr_ses->clientid);
@@ -1456,6 +1460,8 @@ nfsd4_destroy_session(struct svc_rqst *r
 	struct nfsd4_session *ses;
 	u32 status = nfserr_badsession;
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	/* Notes:
 	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
 	 * - Should we return nfserr_back_chan_busy if waiting for
@@ -1493,6 +1499,9 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_slot *slot;
 	int status;
 
+	/* No nfsd_stats_update() call here, for the same reasons
+	 * as for PUTFH and GETFH */
+
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
 
@@ -1560,7 +1569,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	__be32 			status;
 	char			*princ;
 	char                    dname[HEXDIR_LEN];
-	
+
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	if (!check_name(clname))
 		return nfserr_inval;
 
@@ -1684,6 +1695,8 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
 	__be32 status;
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	if (STALE_CLIENTID(clid))
 		return nfserr_stale_clientid;
 	/* 
@@ -2629,6 +2642,8 @@ nfsd4_renew(struct svc_rqst *rqstp, stru
 	struct nfs4_client *clp;
 	__be32 status;
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
+
 	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
@@ -3057,6 +3072,8 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	struct nfs4_stateowner *sop;
 	struct nfs4_stateid *stp;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+
 	dprintk("NFSD: nfsd4_open_confirm on file %.*s\n",
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
@@ -3129,6 +3146,8 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	unsigned int share_access;
 	int flags = OPEN_STATE;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
@@ -3188,6 +3207,8 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	struct nfs4_stateid *stp;
 	int flags = OPEN_STATE | CLOSE_STATE;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_ACCESS);
+
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
@@ -3259,6 +3280,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp
 	renew_client(dp->dl_client);
 
 	unhash_delegation(dp);
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_FSINFO);
 out:
 	nfs4_unlock_state();
 
@@ -3517,6 +3539,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	unsigned int cmd;
 	int err, flags = 0;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_LOCKD);
+
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
 		(long long) lock->lk_offset,
 		(long long) lock->lk_length);
@@ -3695,6 +3719,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	int error;
 	__be32 status;
 
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_LOCKD);
+
 	if (locks_in_grace())
 		return nfserr_grace;
 
@@ -3768,7 +3794,9 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	struct file_lock file_lock;
 	__be32 status;
 	int err, flags = LOCK_STATE;
-						        
+
+	nfsd_stats_update(rqstp, &cstate->current_fh, NFSD_STATS_OP_LOCKD);
+
 	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
 		(long long) locku->lu_offset,
 		(long long) locku->lu_length);
@@ -3865,6 +3893,8 @@ nfsd4_release_lockowner(struct svc_rqst 
 	int i;
 	__be32 status;
 
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_LOCKD);
+
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
 
Index: bfields/fs/nfsd/nfs4xdr.c
===================================================================
--- bfields.orig/fs/nfsd/nfs4xdr.c
+++ bfields/fs/nfsd/nfs4xdr.c
@@ -2641,6 +2641,8 @@ nfsd4_encode_read(struct nfsd4_compoundr
 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
 			&maxcount);
 
+	nfsd_stats_update_read(read->rd_rqstp, read->rd_fhp, maxcount);
+
 	if (nfserr == nfserr_symlink)
 		nfserr = nfserr_inval;
 	if (nfserr)
@@ -2692,6 +2694,7 @@ nfsd4_encode_readlink(struct nfsd4_compo
 	 * assume that truncation occurred, and return NFS4ERR_RESOURCE.
 	 */
 	nfserr = nfsd_readlink(readlink->rl_rqstp, readlink->rl_fhp, page, &maxcount);
+	nfsd_stats_update_read(readlink->rl_rqstp, readlink->rl_fhp, maxcount);
 	if (nfserr == nfserr_isdir)
 		return nfserr_inval;
 	if (nfserr)
@@ -2764,6 +2767,10 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	nfserr = nfsd_readdir(readdir->rd_rqstp, readdir->rd_fhp,
 			      &offset,
 			      &readdir->common, nfsd4_encode_dirent);
+
+	nfsd_stats_update(readdir->rd_rqstp, readdir->rd_fhp,
+			  NFSD_STATS_OP_READDIRP);
+
 	if (nfserr == nfs_ok &&
 	    readdir->common.err == nfserr_toosmall &&
 	    readdir->buffer == page) 

--
Greg
