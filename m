From: Marcel Wiesweg <marcel.wiesweg@gmx.de>
Subject: Problem with NFS, Linux 2.6.2
Date: Wed, 4 Feb 2004 19:33:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402041933.52329.marcel.wiesweg@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoRrh-0000US-MK
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 10:35:09 -0800
Received: from pop.gmx.net ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AoRrg-0000KY-Jw
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 10:35:08 -0800
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

Hi,

after switching to 2.6 I noticed a strange bug which makes my NFS setup 
unusable.

Setup:
Client: 2.6.2, nfs-utils 1.0.6
Server: 2.4.20, nfs-utils 1.0.6

/etc/exports on server contains:
/          aldi(rw,sync)
("aldi" is the client)

When I try to copy files from client to server, it will result in "cp" or any 
other editor going to uninterruptable sleep when the directory is mounted 
"hard", or cp will fail because of an Input/Output error when it is mounted 
"soft".
Strangely, this only applies if the file is larger than 1332 byte (!).
A file filled with zeros of size 1332 copies nicely, one with 1333 bytes 
fails.

This is reproducable and does not occur if the client runs a 2.4 kernel.
Mount options according to /proc/mounts are 
rw,nosuid,nodev,noexec,v3,rsize=8192,wsize=8192,soft,intr,udp,lock,addr=vdr
("vdr" is the server machine)

Any suggestions?
Thanks,

Marcel



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
