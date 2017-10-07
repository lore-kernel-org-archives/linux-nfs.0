Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:44220 "EHLO
        www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753123AbdJGOYK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Oct 2017 10:24:10 -0400
Subject: [PATCH] nfsd: Fix bool initialization/comparison
From: Thomas Meyer <thomas@m3y3r.de>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Message-ID: <1507383097084-1148425660-11-diffsplit-thomas@m3y3r.de>
References: <1507383097081-778026979-0-diffsplit-thomas@m3y3r.de>
In-Reply-To: <1507383097081-778026979-0-diffsplit-thomas@m3y3r.de>
Date: Sat, 07 Oct 2017 16:02:21 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bool initializations should use true and false. Bool tests don't need
comparisons.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -230,7 +230,7 @@ do_open_lookup(struct svc_rqst *rqstp, s
 	if (!*resfh)
 		return nfserr_jukebox;
 	fh_init(*resfh, NFS4_FHSIZE);
-	open->op_truncate = 0;
+	open->op_truncate = false;
 
 	if (open->op_create) {
 		/* FIXME: check session persistence and pnfs flags.
@@ -360,7 +360,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
-	open->op_created = 0;
+	open->op_created = false;
 	/*
 	 * RFC5661 18.51.3
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
@@ -1108,8 +1108,8 @@ nfsd4_copy(struct svc_rqst *rqstp, struc
 	else {
 		copy->cp_res.wr_bytes_written = bytes;
 		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
-		copy->cp_consecutive = 1;
-		copy->cp_synchronous = 1;
+		copy->cp_consecutive = true;
+		copy->cp_synchronous = true;
 		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
 		status = nfs_ok;
 	}
@@ -2476,7 +2476,7 @@ bool nfsd4_spo_must_allow(struct svc_rqs
 	if (!cstate->minorversion)
 		return false;
 
-	if (cstate->spo_must_allowed == true)
+	if (cstate->spo_must_allowed)
 		return true;
 
 	opiter = resp->opcnt;
diff -u -p a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -292,7 +292,7 @@ static int nfsd_startup_net(int nrservs,
 		ret = lockd_up(net);
 		if (ret)
 			goto out_socks;
-		nn->lockd_up = 1;
+		nn->lockd_up = true;
 	}
 
 	ret = nfs4_state_start_net(net);
@@ -305,7 +305,7 @@ static int nfsd_startup_net(int nrservs,
 out_lockd:
 	if (nn->lockd_up) {
 		lockd_down(net);
-		nn->lockd_up = 0;
+		nn->lockd_up = false;
 	}
 out_socks:
 	nfsd_shutdown_generic();
@@ -319,7 +319,7 @@ static void nfsd_shutdown_net(struct net
 	nfs4_state_shutdown_net(net);
 	if (nn->lockd_up) {
 		lockd_down(net);
-		nn->lockd_up = 0;
+		nn->lockd_up = false;
 	}
 	nn->nfsd_net_up = false;
 	nfsd_shutdown_generic();
diff -u -p a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1379,7 +1379,7 @@ do_nfsd_create(struct svc_rqst *rqstp, s
 			    && d_inode(dchild)->i_atime.tv_sec == v_atime
 			    && d_inode(dchild)->i_size  == 0 ) {
 				if (created)
-					*created = 1;
+					*created = true;
 				break;
 			}
 		case NFS4_CREATE_EXCLUSIVE4_1:
@@ -1387,7 +1387,7 @@ do_nfsd_create(struct svc_rqst *rqstp, s
 			    && d_inode(dchild)->i_atime.tv_sec == v_atime
 			    && d_inode(dchild)->i_size  == 0 ) {
 				if (created)
-					*created = 1;
+					*created = true;
 				goto set_attr;
 			}
 			 /* fallthru */
@@ -1404,7 +1404,7 @@ do_nfsd_create(struct svc_rqst *rqstp, s
 		goto out_nfserr;
 	}
 	if (created)
-		*created = 1;
+		*created = true;
 
 	nfsd_check_ignore_resizing(iap);
 
