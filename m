From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 12 - NFSv4: wipe out all evidence in fh_put()
Date: Thu, 22 Aug 2002 10:34:58 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwA-00051L-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwS-00006h-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:16 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:08 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

From:	"Kendrick M. Smith" <kmsmith@umich.edu>

When a filehandle is cleared with fh_put(), wipe out all traces by
clearing ->fh_pre_saved and ->fh_post_saved.  This prevents
fill_post_wcc() from complaining if the filehandle is later reused.
(This could happen in NFSv4 to CURRENT_FH if, for example, LOOKUP LOOKUP
occurs in a COMPOUND.)



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    4 ++++
 1 files changed, 4 insertions(+)

--- ./fs/nfsd/nfsfh.c	2002/08/21 23:23:09	1.4
+++ ./fs/nfsd/nfsfh.c	2002/08/21 23:23:26	1.5
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
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
