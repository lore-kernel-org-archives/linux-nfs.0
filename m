From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 20] knfsd: nfsd4: return nfserr_wrongsec
Date: Tue, 10 Jul 2007 12:25:55 +1000
Message-ID: <1070710022555.13335@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Andy Adamson <andros@citi.umich.edu>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85QN-0004to-Ha
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:26:02 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85QP-0000ua-9e
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:26:02 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: andros@citi.umich.edu <andros@citi.umich.edu>

Make the first actual use of the secinfo information by using it to
return nfserr_wrongsec when an export is found that doesn't allow the
flavor used on this request.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |   26 ++++++++++++++++++++++++++
 ./fs/nfsd/nfsfh.c             |    6 ++++++
 ./fs/nfsd/nfssvc.c            |   10 ++++++++++
 ./fs/nfsd/vfs.c               |    4 ++++
 ./include/linux/nfsd/export.h |    1 +
 ./include/linux/nfsd/nfsd.h   |    1 +
 6 files changed, 48 insertions(+)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-07-10 11:37:38.000000000 +1000
+++ ./fs/nfsd/export.c	2007-07-10 11:39:34.000000000 +1000
@@ -1228,6 +1228,28 @@ exp_find(struct auth_domain *clp, int fs
 	return exp;
 }
 
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
+{
+	struct exp_flavor_info *f;
+	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
+
+	/* legacy gss-only clients are always OK: */
+	if (exp->ex_client == rqstp->rq_gssclient)
+		return 0;
+	/* ip-address based client; check sec= export option: */
+	for (f = exp->ex_flavors; f < end; f++) {
+		if (f->pseudoflavor == rqstp->rq_flavor)
+			return 0;
+	}
+	/* defaults in absence of sec= options: */
+	if (exp->ex_nflavors == 0) {
+		if (rqstp->rq_flavor == RPC_AUTH_NULL ||
+		    rqstp->rq_flavor == RPC_AUTH_UNIX)
+			return 0;
+	}
+	return nfserr_wrongsec;
+}
+
 /*
  * Uses rq_client and rq_gssclient to find an export; uses rq_client (an
  * auth_unix client) if it's available and has secinfo information;
@@ -1340,6 +1362,10 @@ exp_pseudoroot(struct svc_rqst *rqstp, s
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 	rv = fh_compose(fhp, exp, exp->ex_dentry, NULL);
+	if (rv)
+		goto out;
+	rv = check_nfsd_access(exp, rqstp);
+out:
 	exp_put(exp);
 	return rv;
 }

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-07-10 11:35:37.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-07-10 11:39:34.000000000 +1000
@@ -20,6 +20,7 @@
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svcauth_gss.h>
 #include <linux/nfsd/nfsd.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_FH
@@ -248,6 +249,11 @@ fh_verify(struct svc_rqst *rqstp, struct
 	if (error)
 		goto out;
 
+	/* Check security flavor */
+	error = check_nfsd_access(exp, rqstp);
+	if (error)
+		goto out;
+
 	/* Finally, check access permissions. */
 	error = nfsd_permission(exp, dentry, access);
 

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2007-07-10 11:19:56.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2007-07-10 11:39:34.000000000 +1000
@@ -494,6 +494,15 @@ out:
 	module_put_and_exit(0);
 }
 
+static __be32 map_new_errors(u32 vers, __be32 nfserr)
+{
+	if (nfserr == nfserr_jukebox && vers == 2)
+		return nfserr_dropit;
+	if (nfserr == nfserr_wrongsec && vers < 4)
+		return nfserr_acces;
+	return nfserr;
+}
+
 int
 nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 {
@@ -536,6 +545,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __
 
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
 	if (nfserr == nfserr_jukebox && rqstp->rq_vers == 2)
 		nfserr = nfserr_dropit;
 	if (nfserr == nfserr_dropit) {

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-07-10 11:38:15.000000000 +1000
+++ ./fs/nfsd/vfs.c	2007-07-10 11:39:34.000000000 +1000
@@ -240,6 +240,9 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
+	err = check_nfsd_access(exp, rqstp);
+	if (err)
+		goto out;
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -247,6 +250,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && !dentry->d_inode)
 		err = nfserr_noent;
+out:
 	dput(dentry);
 	exp_put(exp);
 	return err;

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-07-10 11:34:22.000000000 +1000
+++ ./include/linux/nfsd/export.h	2007-07-10 11:39:34.000000000 +1000
@@ -116,6 +116,7 @@ struct svc_expkey {
 #define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
 
 /*
  * Function declarations

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-07-10 11:19:56.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2007-07-10 11:39:34.000000000 +1000
@@ -236,6 +236,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_badname		__constant_htonl(NFSERR_BADNAME)
 #define	nfserr_cb_path_down	__constant_htonl(NFSERR_CB_PATH_DOWN)
 #define	nfserr_locked		__constant_htonl(NFSERR_LOCKED)
+#define	nfserr_wrongsec		__constant_htonl(NFSERR_WRONGSEC)
 #define	nfserr_replay_me	__constant_htonl(NFSERR_REPLAY_ME)
 
 /* error codes for internal use */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
