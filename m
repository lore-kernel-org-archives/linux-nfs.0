From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Testing tools
Date: Tue, 25 May 2004 17:16:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405251716.19098.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSdcR-0001ag-Ex
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 08:13:31 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSdcO-00055d-Sx
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 08:13:31 -0700
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id RAA12714
	for <nfs@lists.sourceforge.net>; Tue, 25 May 2004 17:14:22 +0200
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



Here is a little survey to know the most used/usefull tests suites for NFSv4
http://nfsv4.bullopensource.org/tools/sondage.php

with a short description of each tool here :
http://nfsv4.bullopensource.org/tools/testing_tools.html

I had modified the tools lists with suggered tools.
I did not propose object only tools because we can't use it too test NFSv4 on
various hardwares plateforms.

Idealy we need to tests:
-Robustness
-performances
-POSIX compliance
-RFC Compliance
-Interoperatiblity.

However we don't have ready tools to test POSIX compliance
-> OpenPosix do not have filesystems tests suites (It test IPC, timers
threads ...)

RFC compliance
-> SpecSFS : there is no version to test NFSv4... (and is object only)
-> PyNFS : maybe modified to test the RFC compliance ?


Cordialement,
Vincent

-------------------------------------------------------



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
