From: Oren Held <oren-8uj5FFcqMgc+JF/nGntIXQ@public.gmane.org>
Subject: [NFS] A quick manpage typo fix
Date: Tue, 6 May 2008 11:16:53 +0300
Message-ID: <200805061116.53778.oren@held.org.il>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_1PBIIl/U1chP86H"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33320 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755129AbYEFIR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 04:17:28 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JtIMU-0000Pp-V2
	for linux-nfs@vger.kernel.org; Tue, 06 May 2008 18:17:23 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Boundary-00=_1PBIIl/U1chP86H
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

The exportfs manpage has a small typo, attached is a fix: 
(changes "djando"->"django"):

 - Oren

--Boundary-00=_1PBIIl/U1chP86H
Content-Type: text/x-diff;
  charset="utf-8";
  name="exportfs.man.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="exportfs.man.patch"

--- exportfs.man.orig	2008-05-06 11:12:48.000000000 +0300
+++ exportfs.man	2008-05-06 11:12:55.000000000 +0300
@@ -198,7 +198,7 @@
 To export the
 .B /usr/tmp
 directory to host 
-.BR djando ,
+.BR django ,
 allowing asynchronous writes, one would do this:
 .P
 .nf

--Boundary-00=_1PBIIl/U1chP86H
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
--Boundary-00=_1PBIIl/U1chP86H
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--Boundary-00=_1PBIIl/U1chP86H--


