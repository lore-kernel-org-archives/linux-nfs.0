From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 26/38: SERVER: wipe out all evidence in fh_put()
Date: Tue, 13 Aug 2002 19:14:29 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131914090.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekrv-0001FQ-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:14:31 -0700
Received: from rastan.gpcc.itd.umich.edu (rastan.gpcc.itd.umich.edu [141.211.2.215])
        by donkeykong.gpcc.itd.umich.edu (8.8.8/4.3-mailhub) with ESMTP id TAA08517
        for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 19:14:29 -0400 (EDT)
Received: from localhost (kmsmith@localhost)
	by rastan.gpcc.itd.umich.edu (8.9.1a/5.1-client) with ESMTP id TAA29057
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 19:14:29 -0400 (EDT)
To: nfs@lists.sourceforge.net
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


When a filehandle is cleared with fh_put(), wipe out all traces by
clearing ->fh_pre_saved and ->fh_post_saved.  This prevents
fill_post_wcc() from complaining if the filehandle is later reused.
(This could happen to CURRENT_FH if, for example, LOOKUP LOOKUP
occurs in a COMPOUND.)

--- old/fs/nfsd/nfsfh.c	Tue Jul 30 21:50:32 2002
+++ new/fs/nfsd/nfsfh.c	Mon Jul 29 12:39:43 2002
@@ -438,6 +438,10 @@ fh_put(struct svc_fh *fhp)
 		fh_unlock(fhp);
 		fhp->fh_dentry = NULL;
 		dput(dentry);
+#ifdef CONFIG_NFSD_V3
+		fhp->fh_pre_saved = 0;
+		fhp->fh_post_saved = 0;
+#endif
 		nfsd_nr_put++;
 	}
 	return;



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
