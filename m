From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: NFSv4 stability: export unused a night
Date: Thu, 5 Feb 2004 14:07:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402051407.54703.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AojDB-0007pn-3t
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 05:06:29 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AojD9-00027s-DV
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 05:06:28 -0800
Received: from roquetav.frec.bull.fr (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id OAA14324
	for <nfs@lists.sourceforge.net>; Thu, 5 Feb 2004 14:07:09 +0100
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

1/

When I lived yesterday server computer test was up, configured with 1 export 
partition.
This export was moutable from the client side.

Threre was no reboot of the server this night.
This morning, I was unable to mount the exported directory.

After reboot, all was OK.



2/
Yesterday, : 
Feb  4 17:10:54 roquetav kernel: nfs: server 172.16.109.31 not responding, 
still trying

->I was not able to kill and restart the nfsd. All was right after reboot.
Nota this has occured using the python nfs4 test suite.


3/

Using pynfs suite tests. 
minors installs bugs fixes.



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
