From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 910137: fsid export option broken in 2.6
Date: Fri, 27 Feb 2004 20:55:40 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403F141C.6617C2C4@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwelE-0001L3-6o
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 01:58:24 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aweiu-0000ZU-7Y
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 01:56:00 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

G'day,

This patch against 2.6.3 fixes a bug where the fsid= export option
is ignored if the export point is on a device with an old dev_t.


--- linux.base/fs/nfsd/nfsfh.c	Wed Feb 18 14:57:25 2004
+++ linux/fs/nfsd/nfsfh.c	Fri Feb 27 20:37:27 2004
@@ -344,6 +344,9 @@ fh_compose(struct svc_fh *fhp, struct sv
 		ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
 		if (!(exp->ex_flags & NFSEXP_FSID) || ref_fh_fsid_type == 2)
 			ref_fh_fsid_type = 0;
+	} else if (exp->ex_flags & NFSEXP_FSID) {
+		ref_fh_version = 1;
+		ref_fh_fsid_type = 1;
 	}
 	if (ref_fh == fhp)
 		fh_put(ref_fh);


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
