From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 6 - Honour SUN NFSv2 hack for "set times to server time.
Date: Fri, 16 Jan 2004 12:27:23 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AhIlf-0002nn-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhIlp-0007NA-EQ
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:33 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AhIlp-0008Dr-1j
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 16 Jan 2004 12:27:26 +1100
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


>From  Greg Banks <gnb@melbourne.sgi.com>,
see comment in code.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsxdr.c |   11 +++++++++++
 1 files changed, 11 insertions(+)

diff ./fs/nfsd/nfsxdr.c~current~ ./fs/nfsd/nfsxdr.c
--- ./fs/nfsd/nfsxdr.c~current~	2004-01-13 14:56:17.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2004-01-16 12:21:43.000000000 +1100
@@ -130,6 +130,17 @@ decode_sattr(u32 *p, struct iattr *iap)
 		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
 		iap->ia_mtime.tv_sec = tmp;
 		iap->ia_mtime.tv_nsec = tmp1 * 1000; 
+		/*
+		 * Passing the invalid value useconds=1000000 for mtime
+		 * is a Sun convention for "set both mtime and atime to
+		 * current server time".  It's needed to make permissions
+		 * checks for the "touch" program across v2 mounts to
+		 * Solaris and Irix boxes work correctly. See description of
+		 * sattr in section 6.1 of "NFS Illustrated" by
+		 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
+		 */
+		if (tmp1 == 1000000)
+			iap->ia_valid &= ~(ATTR_ATIME_SET|ATTR_MTIME_SET);
 	}
 	return p;
 }


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
