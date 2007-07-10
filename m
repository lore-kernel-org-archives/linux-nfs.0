From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 20] knfsd: nfsd4: simplify exp_pseudoroot arguments
Date: Tue, 10 Jul 2007 12:24:01 +1000
Message-ID: <1070710022401.13066@suse.de>
References: <20070710121949.12548.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762179AbXGJCYg@vger.kernel.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: J "." Bruce Fields <bfields@citi.umich.edu>
Cc: Neil Brown <neilb@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: J. Bruce Fields <bfields@citi.umich.edu>

We're passing three arguments to exp_pseudoroot, two of which are just
fields of the svc_rqst.  Soon we'll want to pass in a third field as
well.  So let's just give up and pass in the whole struct svc_rqst.

Also sneak in some minor style cleanups while we're at it.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |    5 ++---
 ./fs/nfsd/nfs4proc.c          |    7 +++----
 ./fs/nfsd/nfs4xdr.c           |    2 +-
 ./include/linux/nfsd/export.h |    2 +-
 4 files changed, 7 insertions(+), 9 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-07-10 11:33:27.000000000 +1000
+++ ./fs/nfsd/export.c	2007-07-10 11:33:32.000000000 +1000
@@ -1235,8 +1235,7 @@ exp_find(struct auth_domain *clp, int fs
  * export point with fsid==0
  */
 __be32
-exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp,
-	       struct cache_req *creq)
+exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 {
 	struct svc_export *exp;
 	__be32 rv;
@@ -1244,7 +1243,7 @@ exp_pseudoroot(struct auth_domain *clp, 
 
 	mk_fsid(FSID_NUM, fsidv, 0, 0, 0, NULL);
 
-	exp = exp_find(clp, FSID_NUM, fsidv, creq);
+	exp = exp_find(rqstp->rq_client, FSID_NUM, fsidv, rqstp->rq_chandle);
 	if (PTR_ERR(exp) == -ENOENT)
 		return nfserr_perm;
 	if (IS_ERR(exp))

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2007-07-10 11:19:58.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2007-07-10 11:33:32.000000000 +1000
@@ -286,8 +286,7 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, 
 	__be32 status;
 
 	fh_put(&cstate->current_fh);
-	status = exp_pseudoroot(rqstp->rq_client, &cstate->current_fh,
-			      &rqstp->rq_chandle);
+	status = exp_pseudoroot(rqstp, &cstate->current_fh);
 	return status;
 }
 
@@ -474,8 +473,8 @@ nfsd4_lookupp(struct svc_rqst *rqstp, st
 	__be32 ret;
 
 	fh_init(&tmp_fh, NFS4_FHSIZE);
-	if((ret = exp_pseudoroot(rqstp->rq_client, &tmp_fh,
-			      &rqstp->rq_chandle)) != 0)
+	ret = exp_pseudoroot(rqstp, &tmp_fh);
+	if (ret)
 		return ret;
 	if (tmp_fh.fh_dentry == cstate->current_fh.fh_dentry) {
 		fh_put(&tmp_fh);

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-07-10 11:19:58.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2007-07-10 11:33:32.000000000 +1000
@@ -1296,7 +1296,7 @@ static char *nfsd4_path(struct svc_rqst 
 	char *path, *rootpath;
 
 	fh_init(&tmp_fh, NFS4_FHSIZE);
-	*stat = exp_pseudoroot(rqstp->rq_client, &tmp_fh, &rqstp->rq_chandle);
+	*stat = exp_pseudoroot(rqstp, &tmp_fh);
 	if (*stat)
 		return NULL;
 	rootpath = tmp_fh.fh_export->ex_path;

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-07-10 11:29:02.000000000 +1000
+++ ./include/linux/nfsd/export.h	2007-07-10 11:33:32.000000000 +1000
@@ -135,7 +135,7 @@ struct svc_export *	exp_parent(struct au
 				   struct cache_req *reqp);
 int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
-__be32			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp, struct cache_req *creq);
+__be32			exp_pseudoroot(struct svc_rqst *, struct svc_fh *);
 __be32			nfserrno(int errno);
 
 extern struct cache_detail svc_export_cache;
