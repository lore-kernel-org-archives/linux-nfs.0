From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: NFS4 + ticket handling
Date: Mon, 15 May 2006 17:09:23 +0200
Message-ID: <446899A3.1000402@vwi.tu-dresden.de>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FfehS-0002av-QR
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 08:09:34 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FfehS-0000pL-K3
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 08:09:34 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FfehR-0003es-3U
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 08:09:34 -0700
Received: from [127.0.0.1] (helo=localhost)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1FfehJ-0007BG-4d; Mon, 15 May 2006 17:09:25 +0200
Received: from mailgate.urz.tu-dresden.de ([127.0.0.1])
 by localhost (rks36 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 11131-344 for <nfs@lists.sourceforge.net>;
 Mon, 15 May 2006 17:09:24 +0200 (MEST)
Received: from [141.30.186.11] (helo=vwitme011.vwi.vkw.tu-dresden.de)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1FfehI-0007B6-Ji; Mon, 15 May 2006 17:09:24 +0200
Received: from vwitme048.vwi.vkw.tu-dresden.de ([141.30.186.48])
	by vwitme011.vwi.vkw.tu-dresden.de with esmtp (Exim 4.52)
	id 1Ffeh7-0004BK-Gs
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:09:13 +0200
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

I'm planing a migration from v3 to v4 on Debian 
(Server:AMD64+Client:i386) because of the 16+ groups problem.
So I would know something about the kerberos handling which was not 
found in docu.

@moment I'm using kerberos for user authentication on all systems 
against Win2003AD.
System things (e.g nssldap) are solved via a common princ for all 
systems "systemuser@realm" and not "systemuser/hostname@realm" because I 
don't like to build + manage a separate keytab for every service + every 
machine.
Ticket is updated to a special cache via kinit -k -c /etc/.cache

Is such a solution also working with nfs4 or I have to build a special 
keytab for nfs and every machine?


best regards
Steffen


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
