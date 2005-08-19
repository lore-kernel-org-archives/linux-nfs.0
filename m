From: Christophe Thommeret <hftom@free.fr>
Subject: Reading a growing file.
Date: Fri, 19 Aug 2005 16:10:21 +0200
Message-ID: <200508191610.21897.hftom@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E67YE-0001R9-OL
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 07:08:54 -0700
Received: from smtp8.wanadoo.fr ([193.252.22.23])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E67YB-0007FQ-9X
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 07:08:54 -0700
Received: from me-wanadoo.net (unknown [127.0.0.1])
	by mwinf0812.wanadoo.fr (SMTP Server) with ESMTP id 2C7A51C00218
	for <nfs@lists.sourceforge.net>; Fri, 19 Aug 2005 16:08:43 +0200 (CEST)
Received: from anantes-252-1-64-70.w82-126.abo.wanadoo.fr (ANantes-252-1-64-70.w82-126.abo.wanadoo.fr [82.126.70.70])
	by mwinf0812.wanadoo.fr (SMTP Server) with ESMTP id 0AB441C00208
	for <nfs@lists.sourceforge.net>; Fri, 19 Aug 2005 16:08:43 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi list,

My lan server runs linux 2.6.9 and shares audio and video files via readonly 
nfs. Video files are mostly DVB records, up to 5~6 GB.

# /etc/exports: NFS file systems being exported.  See exports(5).
/partage        192.168.0.0/24(ro,async,root_squash)

Reading a fixed size file on a client rocks, whatever kernel version.
However, reading a growing file (being recorded) works like a charm when the 
client runs a 2.4.x kernel but fails with a 2.6.x one. It starts reading  for 
a short time then stops, whatever the actual file size.

Any tips ?

Thanx.
-- 
Christophe Thommeret



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
