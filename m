From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/5] nfsd: return errors, not NULL,
	from export functions
Date: Wed, 18 Jul 2007 18:57:27 -0400
Message-ID: <11847994503243-git-send-email-bfields@fieldses.org>
References: <20070713114228.3c171a90.akpm@linux-foundation.org>
	<11847994502579-git-send-email-bfields@fieldses.org>
	<11847994502502-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, andros@citi.umich.edu,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBISc-0002vh-Bj
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:41 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBISf-0007TU-Td
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 15:57:38 -0700
In-Reply-To: <11847994502502-git-send-email-bfields@fieldses.org>
Message-Id: <278646972e4b7eaf86d648d8ee2ae879f8b6b680.1184798679.git.bfields@citi.umich.edu>
In-Reply-To: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
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

I converted the various export-returning functions to return -ENOENT
instead of NULL, but missed a few cases.

This particular case could cause actual bugs in the case of a krb5
client that doesn't match any ip-based client and that is trying to
access a filesystem not exported to krb5 clients.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c7bbf46..6ab8de4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1265,7 +1265,7 @@ struct svc_export *
 rqst_exp_get_by_name(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
-	struct svc_export *gssexp, *exp = NULL;
+	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
@@ -1288,7 +1288,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp && !IS_ERR(exp))
+	if (!IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }
@@ -1296,7 +1296,7 @@ gss:
 struct svc_export *
 rqst_exp_find(struct svc_rqst *rqstp, int fsid_type, u32 *fsidv)
 {
-	struct svc_export *gssexp, *exp = NULL;
+	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
@@ -1318,7 +1318,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp && !IS_ERR(exp))
+	if (!IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }
-- 
1.5.3.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
