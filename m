From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 20] knfsd: nfsd: factor nfsd_lookup into 2
	pieces
Date: Tue, 10 Jul 2007 12:25:37 +1000
Message-ID: <1070710022537.13297@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Q2-0004sW-Tz
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:25:48 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Q5-0000nG-Qs
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:25:42 -0700
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

Factor nfsd_lookup into nfsd_lookup_dentry, which finds the right dentry
and export, and a second part which composes the filehandle (and which
will later check the security flavor on the new export).

No change in behavior.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |   55 ++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 36 insertions(+), 19 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-07-10 11:34:22.000000000 +1000
+++ ./fs/nfsd/vfs.c	2007-07-10 11:38:15.000000000 +1000
@@ -135,21 +135,10 @@ out:
 	return err;
 }
 
-/*
- * Look up one component of a pathname.
- * N.B. After this call _both_ fhp and resfh need an fh_put
- *
- * If the lookup would cross a mountpoint, and the mounted filesystem
- * is exported to the client with NFSEXP_NOHIDE, then the lookup is
- * accepted as it stands and the mounted directory is
- * returned. Otherwise the covered directory is returned.
- * NOTE: this mountpoint crossing is not supported properly by all
- *   clients and is explicitly disallowed for NFSv3
- *      NeilBrown <neilb@cse.unsw.edu.au>
- */
 __be32
-nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
-					int len, struct svc_fh *resfh)
+nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		   const char *name, int len,
+		   struct svc_export **exp_ret, struct dentry **dentry_ret)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent;
@@ -219,6 +208,38 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			}
 		}
 	}
+	*dentry_ret = dentry;
+	*exp_ret = exp;
+	return 0;
+
+out_nfserr:
+	exp_put(exp);
+	return nfserrno(host_err);
+}
+
+/*
+ * Look up one component of a pathname.
+ * N.B. After this call _both_ fhp and resfh need an fh_put
+ *
+ * If the lookup would cross a mountpoint, and the mounted filesystem
+ * is exported to the client with NFSEXP_NOHIDE, then the lookup is
+ * accepted as it stands and the mounted directory is
+ * returned. Otherwise the covered directory is returned.
+ * NOTE: this mountpoint crossing is not supported properly by all
+ *   clients and is explicitly disallowed for NFSv3
+ *      NeilBrown <neilb@cse.unsw.edu.au>
+ */
+__be32
+nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
+					int len, struct svc_fh *resfh)
+{
+	struct svc_export	*exp;
+	struct dentry		*dentry;
+	__be32 err;
+
+	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
+	if (err)
+		return err;
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -227,15 +248,11 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	if (!err && !dentry->d_inode)
 		err = nfserr_noent;
 	dput(dentry);
-out:
 	exp_put(exp);
 	return err;
-
-out_nfserr:
-	err = nfserrno(host_err);
-	goto out;
 }
 
+
 /*
  * Set various file attributes.
  * N.B. After this call fhp needs an fh_put

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
