From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 25/38: SERVER: wipe out all evidence in fh_put()
Date: Wed, 14 Aug 2002 16:48:35 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141648180.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f54R-0006yb-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:48:47 -0700
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


When a filehandle is cleared with fh_put(), wipe out all traces by
clearing ->fh_pre_saved and ->fh_post_saved.  This prevents
fill_post_wcc() from complaining if the filehandle is later reused.
(This could happen to CURRENT_FH if, for example, LOOKUP LOOKUP
occurs in a COMPOUND.)

--- old/fs/nfsd/nfsfh.c	Sun Aug 11 22:54:17 2002
+++ new/fs/nfsd/nfsfh.c	Sun Aug 11 22:55:44 2002
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
