From: Perceval Anichini <perceval.anichini@laposte.net>
Subject: NFS : open is failing too slowly...
Date: 23 Jan 2004 10:58:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074851927.599.176.camel@ambre>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ajy7b-0004b6-4o
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 02:01:03 -0800
Received: from avelizy-105-1-1-5.w80-11.abo.wanadoo.fr ([80.11.79.5] helo=ambre.maneex)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1Ajy7a-0007gR-Gj
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 02:01:02 -0800
Received: from ambre.maneex
	([127.0.0.1] helo=localhost.localdomain ident=corwin)
	by ambre.maneex with esmtp (Exim 3.35 #1 (Debian))
	id 1Ajy5P-0000So-00
	for <nfs@lists.sourceforge.net>; Fri, 23 Jan 2004 10:58:47 +0100
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

  Hello !

Here is my problem :
	I have an application which job is to record an ip stream on a
NFS server. If the write () fails, the application continue to record
on a local disk.

	When the application is recording to the local disk, it stills
have to check wether or not the main filesystem is back. To perform
that operation, I try to open () a file on the main filesystem
regularly.

  My problem is that open () is taking far too much time to fail
(~0.3s) which lead the application to loose datas.

So my question is : Is their a fast way to know (ioctl, or whatever) if
a nfs server is available or in timeout mode ?

For infos : I am running redhat 9.0 with a kernel 2.6.1 compiled
	   "by hand"
	The filesystem is mounted with options nfsvers=3 soft timeo=1 retrans=1

	(Soft mode because I don't want my process to hang when the
server is stuck, and timeo,retrans = 1 in order to reduce the timeout
as much as possible. Tell me if i'm wrong...)

	Thanks a lot !

Perceval Anichini.



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
