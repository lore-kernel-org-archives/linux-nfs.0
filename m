From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 20] knfsd: nfsd: use ip-address-based domain in
	secinfo case
Date: Tue, 10 Jul 2007 12:25:17 +1000
Message-ID: <1070710022517.13262@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Pk-0004sO-7y
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:25:48 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Pn-0003jj-4X
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:25:23 -0700
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


From: J. Bruce Fields <bfields@citi.umich.edu>

With this patch, we fall back on using the gss/pseudoflavor only if we
fail to find a matching auth_unix export that has a secinfo list.

As long as sec= options aren't used, there's still no change in behavior
here (except possibly for some additional auth_unix cache lookups, whose
results will be ignored).

The sec= option, however, is not actually enforced yet; later patches
will add the necessary checks.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 67 insertions(+), 9 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-07-10 11:35:37.000000000 +1000
+++ ./fs/nfsd/export.c	2007-07-10 11:37:38.000000000 +1000
@@ -1229,6 +1229,10 @@ exp_find(struct auth_domain *clp, int fs
 }
 
 /*
+ * Uses rq_client and rq_gssclient to find an export; uses rq_client (an
+ * auth_unix client) if it's available and has secinfo information;
+ * otherwise, will try to use rq_gssclient.
+ *
  * Called from functions that handle requests; functions that do work on
  * behalf of mountd are passed a single client name to use, and should
  * use exp_get_by_name() or exp_find().
@@ -1237,29 +1241,83 @@ struct svc_export *
 rqst_exp_get_by_name(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
-	struct auth_domain *clp;
+	struct svc_export *gssexp, *exp = NULL;
 
-	clp = rqstp->rq_gssclient ? rqstp->rq_gssclient : rqstp->rq_client;
-	return exp_get_by_name(clp, mnt, dentry, &rqstp->rq_chandle);
+	if (rqstp->rq_client == NULL)
+		goto gss;
+
+	/* First try the auth_unix client: */
+	exp = exp_get_by_name(rqstp->rq_client, mnt, dentry,
+						&rqstp->rq_chandle);
+	if (PTR_ERR(exp) == -ENOENT)
+		goto gss;
+	if (IS_ERR(exp))
+		return exp;
+	/* If it has secinfo, assume there are no gss/... clients */
+	if (exp->ex_nflavors > 0)
+		return exp;
+gss:
+	/* Otherwise, try falling back on gss client */
+	if (rqstp->rq_gssclient == NULL)
+		return exp;
+	gssexp = exp_get_by_name(rqstp->rq_gssclient, mnt, dentry,
+						&rqstp->rq_chandle);
+	if (PTR_ERR(gssexp) == -ENOENT)
+		return exp;
+	if (exp)
+		exp_put(exp);
+	return gssexp;
 }
 
 struct svc_export *
 rqst_exp_find(struct svc_rqst *rqstp, int fsid_type, u32 *fsidv)
 {
-	struct auth_domain *clp;
+	struct svc_export *gssexp, *exp = NULL;
 
-	clp = rqstp->rq_gssclient ? rqstp->rq_gssclient : rqstp->rq_client;
-	return exp_find(clp, fsid_type, fsidv, &rqstp->rq_chandle);
+	if (rqstp->rq_client == NULL)
+		goto gss;
+
+	/* First try the auth_unix client: */
+	exp = exp_find(rqstp->rq_client, fsid_type, fsidv, &rqstp->rq_chandle);
+	if (PTR_ERR(exp) == -ENOENT)
+		goto gss;
+	if (IS_ERR(exp))
+		return exp;
+	/* If it has secinfo, assume there are no gss/... clients */
+	if (exp->ex_nflavors > 0)
+		return exp;
+gss:
+	/* Otherwise, try falling back on gss client */
+	if (rqstp->rq_gssclient == NULL)
+		return exp;
+	gssexp = exp_find(rqstp->rq_gssclient, fsid_type, fsidv,
+						&rqstp->rq_chandle);
+	if (PTR_ERR(gssexp) == -ENOENT)
+		return exp;
+	if (exp)
+		exp_put(exp);
+	return gssexp;
 }
 
 struct svc_export *
 rqst_exp_parent(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
-	struct auth_domain *clp;
+	struct svc_export *exp;
+
+	dget(dentry);
+	exp = rqst_exp_get_by_name(rqstp, mnt, dentry);
 
-	clp = rqstp->rq_gssclient ? rqstp->rq_gssclient : rqstp->rq_client;
-	return exp_parent(rqstp->rq_client, mnt, dentry, &rqstp->rq_chandle);
+	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(dentry)) {
+		struct dentry *parent;
+
+		parent = dget_parent(dentry);
+		dput(dentry);
+		dentry = parent;
+		exp = rqst_exp_get_by_name(rqstp, mnt, dentry);
+	}
+	dput(dentry);
+	return exp;
 }
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
