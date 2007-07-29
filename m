From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fs/nfsd/export.c: make 3 functions static
Date: Sun, 29 Jul 2007 16:57:57 +0200
Message-ID: <20070729145757.GS16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFADt-0002ok-Cc
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 07:58:21 -0700
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailhub.stusta.mhn.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFADw-0006DY-Sr
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 07:58:25 -0700
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

This patch makes the following needlessly global functions static:
- exp_get_by_name()
- exp_parent()
- exp_find()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 fs/nfsd/export.c            |   17 ++++++++---------
 include/linux/nfsd/export.h |   11 -----------
 2 files changed, 8 insertions(+), 20 deletions(-)

--- linux-2.6.23-rc1-mm1/include/linux/nfsd/export.h.old	2007-07-26 14:31:53.000000000 +0200
+++ linux-2.6.23-rc1-mm1/include/linux/nfsd/export.h	2007-07-26 15:04:52.000000000 +0200
@@ -127,17 +127,9 @@
 void			nfsd_export_flush(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
-struct svc_export *	exp_get_by_name(struct auth_domain *clp,
-					struct vfsmount *mnt,
-					struct dentry *dentry,
-					struct cache_req *reqp);
 struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
 					     struct vfsmount *,
 					     struct dentry *);
-struct svc_export *	exp_parent(struct auth_domain *clp,
-				   struct vfsmount *mnt,
-				   struct dentry *dentry,
-				   struct cache_req *reqp);
 struct svc_export *	rqst_exp_parent(struct svc_rqst *,
 					struct vfsmount *mnt,
 					struct dentry *dentry);
@@ -157,9 +149,6 @@
 {
 	cache_get(&exp->h);
 }
-extern struct svc_export *
-exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
-	 struct cache_req *reqp);
 struct svc_export * rqst_exp_find(struct svc_rqst *, int, u32 *);
 
 #endif /* __KERNEL__ */
--- linux-2.6.23-rc1-mm1/fs/nfsd/export.c.old	2007-07-26 14:32:17.000000000 +0200
+++ linux-2.6.23-rc1-mm1/fs/nfsd/export.c	2007-07-26 14:36:58.000000000 +0200
@@ -860,9 +860,9 @@
 	return exp_find_key(clp, FSID_NUM, fsidv, NULL);
 }
 
-svc_export *
-exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry,
-		struct cache_req *reqp)
+static svc_export *exp_get_by_name(svc_client *clp, struct vfsmount *mnt,
+				   struct dentry *dentry,
+				   struct cache_req *reqp)
 {
 	struct svc_export *exp, key;
 	int err;
@@ -886,9 +886,9 @@
 /*
  * Find the export entry for a given dentry.
  */
-struct svc_export *
-exp_parent(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry,
-	   struct cache_req *reqp)
+static struct svc_export *exp_parent(svc_client *clp, struct vfsmount *mnt,
+				     struct dentry *dentry,
+				     struct cache_req *reqp)
 {
 	svc_export *exp;
 
@@ -1213,9 +1213,8 @@
 	return err;
 }
 
-struct svc_export *
-exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
-	 struct cache_req *reqp)
+static struct svc_export *exp_find(struct auth_domain *clp, int fsid_type,
+				   u32 *fsidv, struct cache_req *reqp)
 {
 	struct svc_export *exp;
 	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv, reqp);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
