From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 19 of 34 - correct rename error returns.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006JT-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xW-BJ
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqe-0005he-13
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


unlike v2/v3, nfsv4 returns nfserr_exist in some situations
where the underlying filesystem returns nfserr_isdir, nfserr_notdir.

on rename, nfsv4 returns nfserr_notdir instead of nfserr_symlink.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |   12 ++++++++++++
 1 files changed, 12 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:33.000000000 +1100
@@ -476,6 +476,18 @@ nfsd4_rename(struct svc_rqst *rqstp, str
 	status = nfsd_rename(rqstp, save_fh, rename->rn_sname,
 			     rename->rn_snamelen, current_fh,
 			     rename->rn_tname, rename->rn_tnamelen);
+
+	/* the underlying filesystem returns different error's than required
+	 * by NFSv4. both save_fh and current_fh have been verified.. */
+	if (status == nfserr_isdir) 
+		status = nfserr_exist;
+	else if ((status == nfserr_notdir) && 
+                  (S_ISDIR(save_fh->fh_dentry->d_inode->i_mode) && 
+                   S_ISDIR(current_fh->fh_dentry->d_inode->i_mode)))
+		status = nfserr_exist;
+	else if (status == nfserr_symlink)
+		status = nfserr_notdir;
+
 	if (!status) {
 		set_change_info(&rename->rn_sinfo, current_fh);
 		set_change_info(&rename->rn_tinfo, save_fh);


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
