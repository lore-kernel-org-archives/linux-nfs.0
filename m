From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 34/38: SERVER: new routine exp_pseudoroot() [trivial
 for now]
Date: Wed, 14 Aug 2002 16:53:04 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141652420.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f58c-0007yc-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:53:06 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This patch defines exp_pseudoroot(), which is used to set the filehandle
for the root of the pseudofs.  Right now, we just use the root of an
arbitrarily-selected export.  This is just a placeholder until the
pseudofs is properly implemented in 2.5.

--- old/fs/nfsd/export.c	Thu Aug  1 16:16:28 2002
+++ new/fs/nfsd/export.c	Sun Aug 11 23:11:06 2002
@@ -498,6 +498,24 @@ out:
 	return err;
 }

+/*
+ * Called when we need the filehandle for the root of the pseudofs,
+ * for a given NFSv4 client.  XXX: For the moment, we just use the
+ * root dentry of an arbitarily-selected export.  A real implementation
+ * of the NFSv4 pseudofs will come in a subsequent patch.
+ */
+int
+exp_pseudoroot(struct svc_client *clp, struct svc_fh *fhp)
+{
+	struct svc_export *exp;
+
+	if (!clp || list_empty(&clp->cl_list))
+		return nfserr_perm;
+
+	exp = list_entry(clp->cl_list.next, struct svc_export, ex_list);
+	dget(exp->ex_dentry);
+	return fh_compose(fhp, exp, exp->ex_dentry, NULL);
+}

 /*
  * Find a valid client given an inet address. We always move the most
--- old/include/linux/nfsd/export.h	Thu Aug  1 16:16:01 2002
+++ new/include/linux/nfsd/export.h	Sun Aug 11 23:11:06 2002
@@ -101,6 +101,7 @@ struct svc_export *	exp_get_by_name(stru
 					struct dentry *dentry);
 int			exp_rootfh(struct svc_client *,
 					char *path, struct knfsd_fh *, int maxsize);
+int			exp_pseudoroot(struct svc_client *, struct svc_fh *fhp);
 int			nfserrno(int errno);
 void			exp_nlmdetach(void);




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
