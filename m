From: Peter Astrand <peter@cendio.se>
Subject: clnt_max_conns ?
Date: Wed, 12 May 2004 22:11:40 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405122206570.22744-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BO04s-00011c-KC
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 13:11:42 -0700
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BO04s-00072w-6l
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 13:11:42 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id E732B25DA3D
	for <nfs@lists.sourceforge.net>; Wed, 12 May 2004 22:11:40 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


How many TCP connections are initiated by the Linux NFS client when using 
TCP? Solaris, for example, seems to have a parameter called 
"clnt_max_conns" that controls this. Is there anything similiar for Linux? 
Does the number of TCP connections depend on the number of mounts?


-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00




-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
